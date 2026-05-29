import {
	BadRequestException,
	Injectable,
	InternalServerErrorException,
	NotFoundException,
} from "@nestjs/common"
import crypto from "node:crypto"
import { mkdir, writeFile } from "node:fs/promises"
import { extname, join } from "node:path"
import { and, eq } from "drizzle-orm"

import { rawCaptures } from "@repo/db/schema"

import { db } from "@/common/database/database.client"
import { JobsService } from "@/common/jobs/jobs.service"
import { type V1Inputs } from "@/config/contract-types"

type CreateCaptureInput = V1Inputs["capture"]["create"]
type UpdateTranscriptInput = V1Inputs["capture"]["patchTranscript"]
type UploadedAudioFile = {
	buffer: Buffer
	originalname: string
	mimetype: string
	size: number
}

const MAX_AUDIO_BYTES = 25 * 1024 * 1024
const ALLOWED_AUDIO_MIME_TYPES = new Set([
	"audio/aac",
	"audio/mp4",
	"audio/mpeg",
	"audio/ogg",
	"audio/wav",
	"audio/webm",
	"audio/x-m4a",
	"video/mp4",
])

@Injectable()
export class CapturesService {
	constructor(private readonly jobs: JobsService) {}

	async saveAudioUpload({
		file,
		userId,
		baseUrl,
	}: {
		file: UploadedAudioFile | undefined
		userId: string
		baseUrl: string
	}) {
		if (!file) throw new BadRequestException("Audio file is required")
		if (file.size > MAX_AUDIO_BYTES) {
			throw new BadRequestException("Audio file must be 25 MB or smaller")
		}
		if (!ALLOWED_AUDIO_MIME_TYPES.has(file.mimetype)) {
			throw new BadRequestException("Unsupported audio file type")
		}

		const safeUserId = userId.replace(/[^a-zA-Z0-9_-]/g, "_")
		const rawExt = extname(file.originalname).toLowerCase()
		const extension = rawExt && rawExt.length <= 8 ? rawExt : ".m4a"
		const filename = `${Date.now()}-${crypto.randomUUID()}${extension}`
		const relativePath = join("audio", safeUserId, filename)
		const uploadRoot = join(process.cwd(), "uploads")
		const absolutePath = join(uploadRoot, relativePath)

		await mkdir(join(uploadRoot, "audio", safeUserId), { recursive: true })
		await writeFile(absolutePath, file.buffer)

		const normalizedPath = relativePath.replace(/\\/g, "/")
		return {
			audioUrl: `${baseUrl.replace(/\/$/, "")}/uploads/${normalizedPath}`,
			size: file.size,
			mimeType: file.mimetype,
		}
	}

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
