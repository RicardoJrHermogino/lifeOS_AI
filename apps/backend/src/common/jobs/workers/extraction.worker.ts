import { Logger } from "@nestjs/common"
import { Worker } from "bullmq"
import { and, eq } from "drizzle-orm"

import { memories, rawCaptures } from "@repo/db/schema"

import { type AiService } from "@/common/ai/ai.service"
import { db } from "@/common/database/database.client"
import { getEffectiveSettings } from "@/common/settings/user-settings"
import { env } from "@/config/env.config"

import type { ExtractionJob } from "../jobs.types"

const logger = new Logger("ExtractionWorker")

export function startExtractionWorker(ai: AiService): Worker | null {
	if (!env.REDIS_URL) return null

	const worker = new Worker<ExtractionJob>(
		"extraction",
		async job => {
			const { captureId, userId } = job.data
			logger.log(`Extracting memory for capture ${captureId}`)

			// Consent gate: skip AI extraction if the user disabled AI processing.
			const settings = await getEffectiveSettings(userId)
			if (!settings.aiProcessingConsent) {
				logger.log(`Skipping extraction for ${captureId}: AI processing consent disabled`)
				await db
					.update(rawCaptures)
					.set({ status: "done", updatedAt: new Date() })
					.where(and(eq(rawCaptures.id, captureId), eq(rawCaptures.userId, userId)))
				return
			}

			await db
				.update(rawCaptures)
				.set({ status: "extracting", updatedAt: new Date() })
				.where(and(eq(rawCaptures.id, captureId), eq(rawCaptures.userId, userId)))

			const [capture] = await db
				.select()
				.from(rawCaptures)
				.where(and(eq(rawCaptures.id, captureId), eq(rawCaptures.userId, userId)))

			if (!capture) throw new Error(`Capture ${captureId} not found`)

			const sourceText =
				(capture.transcriptCorrected ? capture.transcript : null) ??
				capture.transcript ??
				capture.body ??
				""

			if (!sourceText.trim()) {
				throw new Error(`Capture ${captureId} has no source text`)
			}

			const extracted = await ai.extractMemory(sourceText, {
				sensitiveTopics: settings.sensitiveTopics,
			})
			const embedding = await ai.embed(`${extracted.title}\n${extracted.summary}`)

			const [existing] = await db
				.select()
				.from(memories)
				.where(eq(memories.rawCaptureId, captureId))

			if (existing) {
				await db
					.update(memories)
					.set({
						title: extracted.title,
						summary: extracted.summary,
						eventDate: extracted.eventDate,
						emotions: extracted.emotions,
						people: extracted.people,
						places: extracted.places,
						topics: extracted.topics,
						goals: extracted.goals,
						decisions: extracted.decisions,
						actions: extracted.actions,
						sensitivity: extracted.sensitivity,
						confidence: extracted.confidence,
						embedding,
						updatedAt: new Date(),
					})
					.where(eq(memories.id, existing.id))
			} else {
				await db.insert(memories).values({
					userId,
					rawCaptureId: captureId,
					title: extracted.title,
					summary: extracted.summary,
					eventDate: extracted.eventDate,
					emotions: extracted.emotions,
					people: extracted.people,
					places: extracted.places,
					topics: extracted.topics,
					goals: extracted.goals,
					decisions: extracted.decisions,
					actions: extracted.actions,
					sensitivity: extracted.sensitivity,
					confidence: extracted.confidence,
					embedding,
					status: "candidate",
				})
			}

			await db
				.update(rawCaptures)
				.set({ status: "done", updatedAt: new Date() })
				.where(and(eq(rawCaptures.id, captureId), eq(rawCaptures.userId, userId)))
		},
		{ connection: { url: env.REDIS_URL } }
	)

	worker.on("failed", (job, err) => {
		void (async () => {
			if (!job) return
			logger.error(`Extraction failed for ${job.data.captureId}: ${err.message}`)
			await db
				.update(rawCaptures)
				.set({ status: "failed", updatedAt: new Date() })
				.where(eq(rawCaptures.id, job.data.captureId))
		})()
	})

	return worker
}
