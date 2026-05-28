import { Injectable } from "@nestjs/common"
import { and, eq, inArray, ne, sql } from "drizzle-orm"

import { memories } from "@repo/db/schema"

import { AiService } from "@/common/ai/ai.service"
import { db } from "@/common/database/database.client"
import { getEffectiveSettings } from "@/common/settings/user-settings"
import { type V1Inputs } from "@/config/contract-types"

type SearchInput = V1Inputs["search"]["search"]
type AskInput = V1Inputs["search"]["ask"]

@Injectable()
export class SearchService {
	constructor(private readonly ai: AiService) {}

	/**
	 * kNN semantic search. Returns memories ordered by cosine distance.
	 * Filters: user owns memory, status != deleted, status != archived.
	 */
	async search({ payload, userId }: { payload: SearchInput; userId: string }) {
		const embedding = await this.ai.embed(payload.query)
		const literal = `[${embedding.join(",")}]`

		// Cosine distance via pgvector `<=>` operator.
		const rows = await db
			.select({
				memory: memories,
				distance: sql<number>`${memories.embedding} <=> ${literal}::vector`.as("distance"),
			})
			.from(memories)
			.where(
				and(
					eq(memories.userId, userId),
					ne(memories.status, "deleted"),
					ne(memories.status, "archived"),
					sql`${memories.embedding} IS NOT NULL`
				)
			)
			.orderBy(sql`distance ASC`)
			.limit((payload.limit as number | undefined) ?? 10)

		return {
			results: rows.map(r => ({ memory: r.memory, score: 1 - r.distance })),
		}
	}

	async ask({ payload, userId }: { payload: AskInput; userId: string }) {
		const settings = await getEffectiveSettings(userId)

		// Consent gate: questions are answered by AI, so require AI processing consent.
		if (!settings.aiProcessingConsent) {
			return {
				answer:
					"AI features are turned off. Enable AI processing in Settings to ask questions about your memories.",
				citations: [],
			}
		}

		const { results } = await this.search({
			payload: { query: payload.question, limit: (payload.limit as number | undefined) ?? 8 },
			userId,
		})
		const refs = results.map(r => ({
			id: r.memory.id,
			title: r.memory.title,
			summary: r.memory.summary,
			eventDate: r.memory.eventDate,
		}))
		const answer = await this.ai.answerQuestion(payload.question, refs, {
			sensitiveTopics: settings.sensitiveTopics,
		})
		// Re-fetch citations from canonical rows to guarantee they're not stale/deleted.
		if (answer.citations.length === 0) return answer
		const citedIds = answer.citations.map(c => c.memoryId)
		const live = await db
			.select({ id: memories.id, title: memories.title, status: memories.status })
			.from(memories)
			.where(
				and(eq(memories.userId, userId), inArray(memories.id, citedIds), ne(memories.status, "deleted"))
			)
		const liveById = new Map(live.map(m => [m.id, m]))
		return {
			answer: answer.answer,
			citations: answer.citations
				.filter(c => liveById.has(c.memoryId))
				.map(c => ({
					memoryId: c.memoryId,
					title: liveById.get(c.memoryId)?.title ?? c.title,
				})),
		}
	}
}
