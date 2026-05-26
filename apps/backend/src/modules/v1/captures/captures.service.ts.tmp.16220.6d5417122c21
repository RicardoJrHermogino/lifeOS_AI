import {
	Injectable,
	InternalServerErrorException,
	NotFoundException,
} from "@nestjs/common"
import { and, eq } from "drizzle-orm"

import { rawCaptures } from "@repo/db/schema"

import { db } from "@/common/database/database.client"
import { JobsService } from "@/common/jobs/jobs.service"
import { type V1Inputs } from "@/config/contract-types"

type CreateCaptureInput = V1Inputs["capture"]["create"]
type UpdateTranscriptInput = V1Inputs["capture"]["patchTranscript"]

@Injectable()
export class CapturesService {
	constructor(private readonly jobs: JobsService) {}

	async create({ payload, userId }: { payload: CreateCaptureInput; userId: string }) {
		// Idempotency on syncId: if a capture already exists for this user+sync_id,
		// return it instead of creating a duplicate (offline-sync support).
		if (payload.syncId) {
			const [existing] = await db
				.select()
				.from(rawCaptures)
				.where(and(eq(rawCaptures.userId, userId), eq(rawCaptures.syncId, payload.syncId)))
			if (existing) return existing
		}

		const capturedAt =
			payload.capturedAt instanceof Date
				? payload.capturedAt
				: payload.capturedAt
					? new Date(payload.capturedAt)
					: new Date()

		const [capture] = await db
			.insert(rawCaptures)
			.values({
				userId,
				type: payload.type,
				body: payload.body ?? null,
				audioUrl: payload.audioUrl ?? null,
				mood: payload.mood ?? null,
				syncId: payload.syncId ?? null,
				capturedAt,
				status: "pending",
			})
			.returning()

		if (!capture) throw new InternalServerErrorException("Capture not created")

		// Voice → transcription pipeline; text → straight to extraction.
		if (capture.type === "voice") {
			await this.jobs.enqueue("transcription", { captureId: capture.id, userId })
		} else {
			await this.jobs.enqueue("extraction", { captureId: capture.id, userId })
		}

		return capture
	}

	async findOne({ id, userId }: { id: string; userId: string }) {
		const [capture] = await db
			.select()
			.from(rawCaptures)
			.where(and(eq(rawCaptures.id, id), eq(rawCaptures.userId, userId)))
		if (!capture) throw new NotFoundException(`Capture ${id} not found`)
		return capture
	}

	async patchTranscript({ payload, userId }: { payload: UpdateTranscriptInput; userId: string }) {
		const existing = await this.findOne({ id: payload.id, userId })

		const [updated] = await db
			.update(rawCaptures)
			.set({
				transcript: payload.transcript,
				transcriptCorrected: true,
				updatedAt: new Date(),
			})
			.where(and(eq(rawCaptures.id, existing.id), eq(rawCaptures.userId, userId)))
			.returning()

		if (!updated) throw new InternalServerErrorException("Capture transcript not updated")

		// Re-extract memory fields from the corrected transcript.
		await this.jobs.enqueue("extraction", { captureId: updated.id, userId })

		return updated
	}
}
