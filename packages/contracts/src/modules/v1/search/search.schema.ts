import { z } from "zod"

import { MemorySchema } from "../memories/memories.schema.js"

export const SearchInputSchema = z.object({
	query: z.string().min(1).max(2000),
	limit: z.coerce.number().int().positive().max(50).default(10),
})

export const SearchResultSchema = z.object({
	memory: MemorySchema,
	score: z.number(),
})

export const SearchOutputSchema = z.object({
	results: z.array(SearchResultSchema),
})

export const AskInputSchema = z.object({
	question: z.string().min(1).max(2000),
	limit: z.coerce.number().int().positive().max(20).default(8),
})

export const AskOutputSchema = z.object({
	answer: z.string(),
	citations: z.array(
		z.object({
			memoryId: z.string().uuid(),
			title: z.string(),
		})
	),
})

export type SearchInput = z.infer<typeof SearchInputSchema>
export type AskInput = z.infer<typeof AskInputSchema>
export type AskOutput = z.infer<typeof AskOutputSchema>
