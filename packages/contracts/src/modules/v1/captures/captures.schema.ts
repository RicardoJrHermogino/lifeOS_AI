import { z } from "zod"

// ============================================================================
// ENUMS
// ============================================================================
export const CaptureTypeSchema = z.enum(["voice", "text"])
export const CaptureStatusSchema = z.enum([
	"pending",
	"transcribing",
	"extracting",
	"done",
	"failed",
])

const dateField = z
	.union([z.date(), z.string()])
	.transform(val => (typeof val === "string" ? new Date(val) : val))

// ============================================================================
// SCHEMAS
// ============================================================================
export const CaptureSchema = z.object({
	id: z.string().uuid(),
	userId: z.string(),
	type: CaptureTypeSchema,
	body: z.string().nullable(),
	audioUrl: z.string().nullable(),
	transcript: z.string().nullable(),
	transcriptCorrected: z.boolean(),
	mood: z.string().nullable(),
	status: CaptureStatusSchema,
	syncId: z.string().nullable(),
	capturedAt: dateField,
	createdAt: dateField,
	updatedAt: dateField,
})

export const CaptureIdSchema = z.object({
	id: z.string().uuid(),
})

export const CreateCaptureSchema = z
	.object({
		type: CaptureTypeSchema,
		body: z.string().min(1).max(50_000).optional(),
		audioUrl: z.string().url().optional(),
		mood: z.string().max(64).optional(),
		syncId: z.string().max(128).optional(),
		capturedAt: z
			.union([z.date(), z.string()])
			.optional()
			.transform(val =>
				val === undefined ? undefined : typeof val === "string" ? new Date(val) : val
			),
	})
	.refine(d => (d.type === "text" ? !!d.body : !!d.audioUrl), {
		message: "text captures require body; voice captures require audioUrl",
	})

export const UpdateTranscriptSchema = CaptureIdSchema.extend({
	transcript: z.string().min(1).max(50_000),
})

// ============================================================================
// TYPES
// ============================================================================
export type Capture = z.infer<typeof CaptureSchema>
export type CreateCaptureInput = z.infer<typeof CreateCaptureSchema>
export type UpdateTranscriptInput = z.infer<typeof UpdateTranscriptSchema>
