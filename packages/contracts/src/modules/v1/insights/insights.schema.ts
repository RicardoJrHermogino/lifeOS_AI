import { z } from "zod"

const dateField = z
	.union([z.date(), z.string()])
	.transform(val => (typeof val === "string" ? new Date(val) : val))

export const InsightEvidenceSchema = z.enum(["weak", "moderate", "strong"])
export const InsightStatusSchema = z.enum(["active", "saved", "dismissed", "deleted"])
export const InsightFeedbackSchema = z.enum(["helpful", "not_helpful", "wrong"])

export const InsightSchema = z.object({
	id: z.string().uuid(),
	userId: z.string(),
	type: z.string(),
	title: z.string(),
	body: z.string(),
	sourceMemoryIds: z.array(z.string().uuid()),
	evidence: InsightEvidenceSchema,
	status: InsightStatusSchema,
	feedback: InsightFeedbackSchema.nullable(),
	createdAt: dateField,
	updatedAt: dateField,
})

export const InsightIdSchema = z.object({
	id: z.string().uuid(),
})

export const InsightFeedbackInputSchema = InsightIdSchema.extend({
	feedback: InsightFeedbackSchema,
})

export type Insight = z.infer<typeof InsightSchema>
