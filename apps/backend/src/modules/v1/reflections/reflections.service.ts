import { Injectable, InternalServerErrorException, NotFoundException } from "@nestjs/common"
import { and, eq, gte, lt, ne } from "drizzle-orm"

import { memories, reflections } from "@repo/db/schema"

import { AiService } from "@/common/ai/ai.service"
import { db } from "@/common/database/database.client"
import { getEffectiveSettings } from "@/common/settings/user-settings"
import { type V1Inputs } from "@/config/contract-types"

type UpdateReflectionInput = V1Inputs["reflection"]["update"]
type FeedbackInput = V1Inputs["reflection"]["feedback"]

function toIsoDate(d: Date): string {
	return d.toISOString().slice(0, 10)
}

function dayBounds(dateStr: string): { start: Date; end: Date } {
	const start = new Date(`${dateStr}T00:00:00.000Z`)
	const end = new Date(start.getTime() + 24 * 60 * 60 * 1000)
	return { start, end }
}

@Injectable()
export class ReflectionsService {
	constructor(private readonly ai: AiService) {}

	async getOrGenerateForDate({ date, userId }: { date: string; userId: string }) {
		const [existing] = await db
			.select()
			.from(reflections)
			.where(and(eq(reflections.userId, userId), eq(reflections.date, date)))
		if (existing) return existing

		const settings = await getEffectiveSettings(userId)

		// Consent gate: do not run AI generation when the user disabled it.
		if (!settings.aiProcessingConsent) {
			const [created] = await db
				.insert(reflections)
				.values({
					userId,
					date,
					content:
						"AI reflections are turned off. Enable AI processing in Settings to generate daily reflections.",
					sourceMemoryIds: [],
				})
				.returning()
			if (!created) throw new InternalServerErrorException("Reflection not created")
			return created
		}

		const { start, end } = dayBounds(date)
		const todays = await db
			.select()
			.from(memories)
			.where(
				and(
					eq(memories.userId, userId),
					ne(memories.status, "deleted"),
					gte(memories.eventDate, start),
					lt(memories.eventDate, end)
				)
			)

		const content = await this.ai.generateReflection(
			todays.map(m => ({
				id: m.id,
				title: m.title,
				summary: m.summary,
				eventDate: m.eventDate,
			})),
			{ tone: settings.reflectionTone, personalize: settings.aiPersonalization }
		)

		const [created] = await db
			.insert(reflections)
			.values({
				userId,
				date,
				content,
				sourceMemoryIds: todays.map(m => m.id),
			})
			.returning()

		if (!created) throw new InternalServerErrorException("Reflection not created")
		return created
	}

	async today({ userId }: { userId: string }) {
		return this.getOrGenerateForDate({ date: toIsoDate(new Date()), userId })
	}

	async getByDate({ date, userId }: { date: string; userId: string }) {
		const [existing] = await db
			.select()
			.from(reflections)
			.where(and(eq(reflections.userId, userId), eq(reflections.date, date)))
		if (!existing) throw new NotFoundException(`Reflection for ${date} not found`)
		return existing
	}

	async update({ payload, userId }: { payload: UpdateReflectionInput; userId: string }) {
		const [updated] = await db
			.update(reflections)
			.set({
				content: payload.content,
				isUserEdited: true,
				updatedAt: new Date(),
			})
			.where(and(eq(reflections.id, payload.id), eq(reflections.userId, userId)))
			.returning()
		if (!updated) throw new NotFoundException(`Reflection ${payload.id} not found`)
		return updated
	}

	async feedback({ payload, userId }: { payload: FeedbackInput; userId: string }) {
		const [updated] = await db
			.update(reflections)
			.set({ feedback: payload.feedback, updatedAt: new Date() })
			.where(and(eq(reflections.id, payload.id), eq(reflections.userId, userId)))
			.returning()
		if (!updated) throw new NotFoundException(`Reflection ${payload.id} not found`)
		return updated
	}
}
