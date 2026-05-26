import { Logger } from "@nestjs/common"
import { Worker } from "bullmq"
import { and, eq } from "drizzle-orm"

import { rawCaptures } from "@repo/db/schema"

import { type AiService } from "@/common/ai/ai.service"
import { db } from "@/common/database/database.client"
import { env } from "@/config/env.config"

import type { JobsService } from "../jobs.service"
import type { TranscriptionJob } from "../jobs.types"

const logger = new Logger("TranscriptionWorker")

export function startTranscriptionWorker(ai: AiService, jobs: JobsService): Worker | null {
	if (!env.REDIS_URL) return null

	const worker = new Worker<TranscriptionJob>(
		"transcription",
		async job => {
			const { captureId, userId } = job.data
			logger.log(`Transcribing capture ${captureId}`)

			await db
				.update(rawCaptures)
				.set({ status: "transcribing", updatedAt: new Date() })
				.where(and(eq(rawCaptures.id, captureId), eq(rawCaptures.userId, userId)))

			const [capture] = await db
				.select()
				.from(rawCaptures)
				.where(and(eq(rawCaptures.id, captureId), eq(rawCaptures.userId, userId)))

			if (!capture || !capture.audioUrl) {
				throw new Error(`Capture ${captureId} missing audio URL`)
			}

			const audioResp = await fetch(capture.audioUrl)
			if (!audioResp.ok) {
				throw new Error(`Audio fetch failed: ${audioResp.status}`)
			}
			const buf = Buffer.from(await audioResp.arrayBuffer())

			const transcript = await ai.transcribe(buf)

			await db
				.update(rawCaptures)
				.set({
					transcript,
					status: "extracting",
					updatedAt: new Date(),
				})
				.where(and(eq(rawCaptures.id, captureId), eq(rawCaptures.userId, userId)))

			await jobs.enqueue("extraction", { captureId, userId })
		},
		{ connection: { url: env.REDIS_URL } }
	)

	worker.on("failed", (job, err) => {
		void (async () => {
			if (!job) return
			logger.error(`Transcription failed for ${job.data.captureId}: ${err.message}`)
			await db
				.update(rawCaptures)
				.set({ status: "failed", updatedAt: new Date() })
				.where(eq(rawCaptures.id, job.data.captureId))
		})()
	})

	return worker
}
