import { Injectable, InternalServerErrorException, NotFoundException } from "@nestjs/common"
import { eq } from "drizzle-orm"

import { userSettings } from "@repo/db/schema"

import { db } from "@/common/database/database.client"
import { type V1Inputs } from "@/config/contract-types"

type UpdateSettingsInput = V1Inputs["settings"]["update"]

@Injectable()
export class SettingsService {
	/**
	 * Returns the user's settings row, creating it with defaults on first access.
	 */
	async getOrCreate({ userId }: { userId: string }) {
		const [existing] = await db
			.select()
			.from(userSettings)
			.where(eq(userSettings.userId, userId))
		if (existing) return existing

		const [created] = await db.insert(userSettings).values({ userId }).returning()
		if (!created) throw new InternalServerErrorException("Settings not created")
		return created
	}

	async update({ payload, userId }: { payload: UpdateSettingsInput; userId: string }) {
		// Ensure a row exists before patching.
		await this.getOrCreate({ userId })

		const [updated] = await db
			.update(userSettings)
			.set({ ...payload, updatedAt: new Date() })
			.where(eq(userSettings.userId, userId))
			.returning()
		if (!updated) throw new NotFoundException("Settings not found")
		return updated
	}
}
