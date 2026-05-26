import { z } from "zod"

// ============================================================================
// ENUMS
// ============================================================================
export const MemoryStatusSchema = z.enum(["candidate", "saved", "archived", "deleted"])

const dateField = z
	.union([z.date(), z.string()])
	.transform(val => (typeof val === "string" ? new Date(val) : val))

const stringArray = z.array(z.string())

// ============================================================================
// SCHEMAS
// ============================================================================
export const MemorySchema = z.object({
	id: z.string().uuid(),
	userId: z.string(),
	rawCaptureId: z.string().uuid().nullable(),
	title: z.string(),
	summary: z.string(),
	eventDate: dateField,
	emotions: stringArray,
	people: stringArray,
	places: stringArray,
	topics: stringArray,
	goals: stringArray,
	decisions: stringArray,
	actions: stringArray,
	sensitivity: z.string().nullable(),
	confidence: z.record(z.string(), z.number()),
	status: MemoryStatusSchema,
	isUserCorrected: z.boolean(),
	createdAt: dateField,
	updatedAt: dateField,
})

export const MemoryIdSchema = z.object({
	id: z.string().uuid(),
})

export const UpdateMemorySchema = MemoryIdSchema.extend({
	title: z.string().min(1).max(255).optional(),
	summary: z.string().min(1).max(10_000).optional(),
	eventDate: z
		.union([z.date(), z.string()])
		.optional()
		.transform(val =>
			val === undefined ? undefined : typeof val === "string" ? new Date(val) : val
		),
	emotions: stringArray.optional(),
	people: stringArray.optional(),
	places: stringArray.optional(),
	topics: stringArray.optional(),
	goals: stringArray.optional(),
	decisions: stringArray.optional(),
	actions: stringArray.optional(),
	sensitivity: z.string().nullable().optional(),
})

export const CandidatesQuerySchema = z.object({
	limit: z.coerce.number().int().positive().max(100).default(20),
	cursor: z.string().uuid().optional(),
})

// ============================================================================
// TYPES
// ============================================================================
export type Memory = z.infer<typeof MemorySchema>
export type UpdateMemoryInput = z.infer<typeof UpdateMemorySchema>
export type CandidatesQuery = z.infer<typeof CandidatesQuerySchema>
