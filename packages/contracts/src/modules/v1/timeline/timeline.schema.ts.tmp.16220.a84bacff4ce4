import { z } from "zod"

import { MemorySchema } from "../memories/memories.schema.js"

const dateInput = z
	.union([z.date(), z.string()])
	.optional()
	.transform(val =>
		val === undefined ? undefined : typeof val === "string" ? new Date(val) : val
	)

export const TimelineQuerySchema = z.object({
	cursor: z.string().optional(),
	limit: z.coerce.number().int().positive().max(100).default(20),
	mood: z.string().optional(),
	person: z.string().optional(),
	topic: z.string().optional(),
	from: dateInput,
	to: dateInput,
})

export const TimelineGroupSchema = z.object({
	date: z.string(), // YYYY-MM-DD
	memories: z.array(MemorySchema),
})

export const TimelinePageSchema = z.object({
	groups: z.array(TimelineGroupSchema),
	nextCursor: z.string().nullable(),
})

export type TimelineQuery = z.infer<typeof TimelineQuerySchema>
export type TimelinePage = z.infer<typeof TimelinePageSchema>
