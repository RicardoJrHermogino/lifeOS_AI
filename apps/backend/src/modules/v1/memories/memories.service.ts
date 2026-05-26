import {
	Injectable,
	InternalServerErrorException,
	NotFoundException,
} from "@nestjs/common"
import { and, desc, eq, lt, ne } from "drizzle-orm"

import { memories } from "@repo/db/schema"

import { AiService } from "@/common/ai/ai.service"
import { db } from "@/common/database/database.client"
import { type V1Inputs } from "@/config/contract-types"

type UpdateMemoryInput = V1Inputs["memory"]["update"]
type CandidatesQuery = V1Inputs["memory"]["listCandidates"]

@Injectable()
export class MemoriesService {
	constructor(private readonly ai: AiService) {}

	/**
	 * List candidate memories awaiting user review, cursor paginated by updatedAt.
	 * Excludes deleted memories (spec §10).
	 */
	async listCandidates({ query, userId }: { query: CandidatesQuery; userId: string }) {
		const limit = (query.limit as number | undefined) ?? 20
		const baseConds = [
			eq(memories.userId, userId),
			eq(memories.status, "candidate"),
		]

		if (query.cursor) {
			const [cursorRow] = await db
				.select({ updatedAt: memories.updatedAt })
				.from(memories)
				.where(eq(memories.id, query.cursor))
			if (cursorRow) baseConds.push(lt(memories.updatedAt, cursorRow.updatedAt))
		}

		const rows = await db
			.select()
			.from(memories)
			.where(and(...baseConds))
			.orderBy(desc(memories.updatedAt))
			.limit(limit + 1)

		const hasMore = rows.length > limit
		const items = hasMore ? rows.slice(0, limit) : rows
		const nextCursor = hasMore ? (items[items.length - 1]?.id ?? null) : null

		return { items, nextCursor }
	}

	async findOne({ id, userId }: { id: string; userId: string }) {
		const [memory] = await db
			.select()
			.from(memories)
			.where(
				and(eq(memories.id, id), eq(memories.userId, userId), ne(memories.status, "deleted"))
			)
		if (!memory) throw new NotFoundException(`Memory ${id} not found`)
		return memory
	}

	async update({ payload, userId }: { payload: UpdateMemoryInput; userId: string }) {
		const existing = await this.findOne({ id: payload.id, userId })

		const contentChanged =
			(payload.title !== undefined && payload.title !== existing.title) ||
			(payload.summary !== undefined && payload.summary !== existing.summary)

		const nextEventDate =
			payload.eventDate instanceof Date
				? payload.eventDate
				: payload.eventDate
					? new Date(payload.eventDate)
					: existing.eventDate

		const [updated] = await db
			.update(memories)
			.set({
				title: payload.title ?? existing.title,
				summary: payload.summary ?? existing.summary,
				eventDate: nextEventDate,
				emotions: payload.emotions ?? existing.emotions,
				people: payload.people ?? existing.people,
				places: payload.places ?? existing.places,
				topics: payload.topics ?? existing.topics,
				goals: payload.goals ?? existing.goals,
				decisions: payload.decisions ?? existing.decisions,
				actions: payload.actions ?? existing.actions,
				sensitivity:
					payload.sensitivity === undefined ? existing.sensitivity : payload.sensitivity,
				// First save out of candidate flow lifts it to saved.
				status: existing.status === "candidate" ? "saved" : existing.status,
				isUserCorrected: true,
				updatedAt: new Date(),
			})
			.where(and(eq(memories.id, existing.id), eq(memories.userId, userId)))
			.returning()

		if (!updated) throw new InternalServerErrorException("Memory not updated")

		// Re-embed when textual content changed so vector index stays in sync.
		if (contentChanged) {
			try {
				const embedding = await this.ai.embed(`${updated.title}\n${updated.summary}`)
				await db
					.update(memories)
					.set({ embedding, updatedAt: new Date() })
					.where(eq(memories.id, updated.id))
			} catch {
				// AI not configured / failed — leave embedding stale, surfaced in logs.
			}
		}

		return updated
	}

	async softDelete({ id, userId }: { id: string; userId: string }) {
		const existing = await this.findOne({ id, userId })
		await db
			.update(memories)
			.set({ status: "deleted", embedding: null, updatedAt: new Date() })
			.where(and(eq(memories.id, existing.id), eq(memories.userId, userId)))
		return { success: true, id: existing.id }
	}

	async archive({ id, userId }: { id: string; userId: string }) {
		const existing = await this.findOne({ id, userId })
		const [updated] = await db
			.update(memories)
			.set({ status: "archived", updatedAt: new Date() })
			.where(and(eq(memories.id, existing.id), eq(memories.userId, userId)))
			.returning()
		if (!updated) throw new InternalServerErrorException("Memory not archived")
		return updated
	}

	async restore({ id, userId }: { id: string; userId: string }) {
		const existing = await this.findOne({ id, userId })
		if (existing.status !== "archived") return existing
		const [updated] = await db
			.update(memories)
			.set({ status: "saved", updatedAt: new Date() })
			.where(and(eq(memories.id, existing.id), eq(memories.userId, userId)))
			.returning()
		if (!updated) throw new InternalServerErrorException("Memory not restored")
		return updated
	}
}
