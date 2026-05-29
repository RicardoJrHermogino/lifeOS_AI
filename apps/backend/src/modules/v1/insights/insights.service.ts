import { Injectable, NotFoundException } from "@nestjs/common"
import { and, desc, eq, inArray } from "drizzle-orm"

import { insights, memories } from "@repo/db/schema"

import { AiService } from "@/common/ai/ai.service"
import { db } from "@/common/database/database.client"
import { getEffectiveSettings } from "@/common/settings/user-settings"
import { type V1Inputs } from "@/config/contract-types"

type IdInput = V1Inputs["insight"]["save"]
type FeedbackInput = V1Inputs["insight"]["feedback"]

@Injectable()
export class InsightsService {
	constructor(private readonly ai: AiService) {}

	/** Active + saved insights, newest first. Dismissed/deleted excluded. */
	async list({ userId }: { userId: string }) {
		return db
			.select()
			.from(insights)
			.where(and(eq(insights.userId, userId), inArray(insights.status, ["active", "saved"])))
			.orderBy(desc(insights.createdAt))
	}

	/**
	 * Generates grounded insights from the user's saved memories. Gated on AI
	 * processing consent; needs at least a few saved memories to be meaningful.
	 */
	async generate({ userId }: { userId: string }) {
		const settings = await getEffectiveSettings(userId)
		if (!settings.aiProcessingConsent) return []

		const saved = await db
			.select()
			.from(memories)
			.where(and(eq(memories.userId, userId), eq(memories.status, "saved")))
			.orderBy(desc(memories.eventDate))
			.limit(50)

		if (saved.length < 3) return []

		const generated = await this.ai.generateInsights(
			saved.map(m => ({
				id: m.id,
				title: m.title,
				summary: m.summary,
				eventDate: m.eventDate,
			}))
		)
		if (generated.length === 0) return []

		return db
			.insert(insights)
			.values(
				generated.map(g => ({
					userId,
					type: g.type,
					title: g.title,
					body: g.body,
					sourceMemoryIds: g.sourceMemoryIds,
					evidence: g.evidence,
				}))
			)
			.returning()
	}

	async save({ payload, userId }: { payload: IdInput; userId: string }) {
		return this.setStatus(payload.id, userId, "saved")
	}

	async dismiss({ payload, userId }: { payload: IdInput; userId: string }) {
		return this.setStatus(payload.id, userId, "dismissed")
	}

	async feedback({ payload, userId }: { payload: FeedbackInput; userId: string }) {
		const [updated] = await db
			.update(insights)
			.set({ feedback: payload.feedback, updatedAt: new Date() })
			.where(and(eq(insights.id, payload.id), eq(insights.userId, userId)))
			.returning()
		if (!updated) throw new NotFoundException(`Insight ${payload.id} not found`)
		return updated
	}

	private async setStatus(id: string, userId: string, status: "saved" | "dismissed") {
		const [updated] = await db
			.update(insights)
			.set({ status, updatedAt: new Date() })
			.where(and(eq(insights.id, id), eq(insights.userId, userId)))
			.returning()
		if (!updated) throw new NotFoundException(`Insight ${id} not found`)
		return updated
	}
}
