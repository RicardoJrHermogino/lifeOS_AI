import { Injectable } from "@nestjs/common"
import { and, desc, eq, gte, lt, lte, ne, sql, SQL } from "drizzle-orm"

import { memories } from "@repo/db/schema"

import { db } from "@/common/database/database.client"
import { type V1Inputs } from "@/config/contract-types"

type TimelineQuery = V1Inputs["timeline"]["list"]

type MemoryRow = typeof memories.$inferSelect

function toDate(value: unknown): Date | undefined {
	if (value === undefined || value === null) return undefined
	if (value instanceof Date) return value
	if (typeof value === "string") {
		const d = new Date(value)
		return Number.isNaN(d.getTime()) ? undefined : d
	}
	return undefined
}

@Injectable()
export class TimelineService {
	async list({ query, userId }: { query: TimelineQuery; userId: string }) {
		const limit = (query.limit as number | undefined) ?? 20

		const conds: SQL[] = [
			eq(memories.userId, userId),
			eq(memories.status, "saved"),
			ne(memories.status, "deleted"),
		]

		const fromDate = toDate(query.from)
		const toDateValue = toDate(query.to)
		if (fromDate) conds.push(gte(memories.eventDate, fromDate))
		if (toDateValue) conds.push(lte(memories.eventDate, toDateValue))

		// Cursor is an ISO timestamp of the previous page's last eventDate.
		if (query.cursor) {
			const cursorDate = new Date(query.cursor)
			if (!Number.isNaN(cursorDate.getTime())) {
				conds.push(lt(memories.eventDate, cursorDate))
			}
		}

		// JSON array containment for metadata filters.
		if (query.mood) {
			conds.push(sql`${memories.emotions} @> ${JSON.stringify([query.mood])}::jsonb`)
		}
		if (query.person) {
			conds.push(sql`${memories.people} @> ${JSON.stringify([query.person])}::jsonb`)
		}
		if (query.topic) {
			conds.push(sql`${memories.topics} @> ${JSON.stringify([query.topic])}::jsonb`)
		}

		const rows = await db
			.select()
			.from(memories)
			.where(and(...conds))
			.orderBy(desc(memories.eventDate))
			.limit(limit + 1)

		const hasMore = rows.length > limit
		const page = hasMore ? rows.slice(0, limit) : rows
		const last = page[page.length - 1]
		const nextCursor = hasMore && last ? last.eventDate.toISOString() : null

		// Group by YYYY-MM-DD descending.
		const groups = new Map<string, MemoryRow[]>()
		for (const row of page) {
			const key = row.eventDate.toISOString().slice(0, 10)
			const bucket = groups.get(key)
			if (bucket) bucket.push(row)
			else groups.set(key, [row])
		}

		return {
			groups: Array.from(groups.entries()).map(([date, mems]) => ({ date, memories: mems })),
			nextCursor,
		}
	}
}
