import { Logger } from "@nestjs/common"
import { Worker } from "bullmq"
import { eq } from "drizzle-orm"

import { dataExports, memories, rawCaptures, reflections, users } from "@repo/db/schema"

import { db } from "@/common/database/database.client"
import { env } from "@/config/env.config"

import type { ExportJob } from "../jobs.types"

const logger = new Logger("ExportWorker")

export function startExportWorker(): Worker | null {
	if (!env.REDIS_URL) return null

	const worker = new Worker<ExportJob>(
		"export",
		async job => {
			const { exportId, userId } = job.data
			logger.log(`Building export ${exportId} for user ${userId}`)

			const [user] = await db.select().from(users).where(eq(users.id, userId))
			const userCaptures = await db.select().from(rawCaptures).where(eq(rawCaptures.userId, userId))
			const userMemories = await db.select().from(memories).where(eq(memories.userId, userId))
			const userReflections = await db
				.select()
				.from(reflections)
				.where(eq(reflections.userId, userId))

			const payload = {
				account: user ?? null,
				captures: userCaptures,
				memories: userMemories.map(m => ({ ...m, embedding: undefined })),
				reflections: userReflections,
				generatedAt: new Date().toISOString(),
			}

			// In production: upload to S3 and return signed URL. For now, inline a data URL.
			const json = JSON.stringify(payload, null, 2)
			const downloadUrl = `data:application/json;base64,${Buffer.from(json).toString("base64")}`
			const expiresAt = new Date(Date.now() + 24 * 60 * 60 * 1000)

			await db
				.update(dataExports)
				.set({ status: "ready", downloadUrl, expiresAt })
				.where(eq(dataExports.id, exportId))
		},
		{ connection: { url: env.REDIS_URL } }
	)

	worker.on("failed", (job, err) => {
		void (async () => {
			if (!job) return
			logger.error(`Export failed for ${job.data.exportId}: ${err.message}`)
			await db
				.update(dataExports)
				.set({ status: "failed" })
				.where(eq(dataExports.id, job.data.exportId))
		})()
	})

	return worker
}
