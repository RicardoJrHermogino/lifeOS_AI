import { eq } from "drizzle-orm"

import { userSettings } from "@repo/db/schema"

import { db } from "@/common/database/database.client"

import type { ReflectionTone } from "@/common/ai/ai.types"

/**
 * The subset of user settings that gates or shapes AI processing.
 */
export interface EffectiveSettings {
	aiProcessingConsent: boolean
	aiPersonalization: boolean
	proactiveInsights: boolean
	reflectionTone: ReflectionTone
	sensitiveTopics: string[]
}

/**
 * Privacy-safe defaults used when a user has no settings row yet. Mirrors the
 * column defaults in `user_settings`.
 */
const DEFAULTS: EffectiveSettings = {
	aiProcessingConsent: true,
	aiPersonalization: true,
	proactiveInsights: false,
	reflectionTone: "warm",
	sensitiveTopics: [],
}

/**
 * Loads the AI-relevant settings for a user. Read-only and DI-free so it can be
 * used from both Nest services and standalone BullMQ workers.
 */
export async function getEffectiveSettings(userId: string): Promise<EffectiveSettings> {
	const [row] = await db.select().from(userSettings).where(eq(userSettings.userId, userId))
	if (!row) return DEFAULTS
	return {
		aiProcessingConsent: row.aiProcessingConsent,
		aiPersonalization: row.aiPersonalization,
		proactiveInsights: row.proactiveInsights,
		reflectionTone: row.reflectionTone,
		sensitiveTopics: row.sensitiveTopics,
	}
}
