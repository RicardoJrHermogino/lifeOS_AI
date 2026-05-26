import { z } from "zod"

const dateField = z
	.union([z.date(), z.string()])
	.transform(val => (typeof val === "string" ? new Date(val) : val))

export const ReflectionFeedbackSchema = z.enum(["helpful", "inaccurate"])

export const ReflectionSchema = z.object({
	id: z.string().uuid(),
	userId: z.string(),
	date: z.string(), // YYYY-MM-DD
	content: z.string(),
	sourceMemoryIds: z.array(z.string().uuid()),
	isUserEdited: z.boolean(),
	feedback: ReflectionFeedbackSchema.nullable(),
	createdAt: dateField,
	updatedAt: dateField,
})

export const ReflectionIdSchema = z.object({
	id: z.string().uuid(),
})

export const ReflectionDateSchema = z.object({
	date: z.string().regex(/^\d{4}-\d{2}-\d{2}$/, "date must be YYYY-MM-DD"),
})

export const UpdateReflectionSchema = ReflectionIdSchema.extend({
	content: z.string().min(1).max(20_000),
})

export const ReflectionFeedbackInputSchema = ReflectionIdSchema.extend({
	feedback: ReflectionFeedbackSchema,
})

export type Reflection = z.infer<typeof ReflectionSchema>
