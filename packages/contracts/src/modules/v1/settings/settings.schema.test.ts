import { describe, expect, it } from "vitest"

import { SettingsSchema, UpdateSettingsSchema } from "./settings.schema"

describe("SettingsSchema", () => {
	it("parses valid settings and coerces date strings", () => {
		const result = SettingsSchema.parse({
			userId: "user-1",
			aiProcessingConsent: true,
			aiPersonalization: true,
			proactiveInsights: false,
			reflectionTone: "warm",
			sensitiveTopics: ["work"],
			dailyReminder: true,
			reminderTime: "08:30",
			appLock: false,
			createdAt: "2026-05-28T00:00:00.000Z",
			updatedAt: "2026-05-28T01:00:00.000Z",
		})
		expect(result.createdAt).toBeInstanceOf(Date)
		expect(result.updatedAt).toBeInstanceOf(Date)
	})

	it("rejects an invalid reflection tone", () => {
		const result = SettingsSchema.safeParse({
			userId: "user-1",
			aiProcessingConsent: true,
			aiPersonalization: true,
			proactiveInsights: false,
			reflectionTone: "loud",
			sensitiveTopics: [],
			dailyReminder: false,
			reminderTime: null,
			appLock: false,
			createdAt: new Date(),
			updatedAt: new Date(),
		})
		expect(result.success).toBe(false)
		if (!result.success) {
			expect(result.error.issues[0]!.path).toEqual(["reflectionTone"])
			expect(result.error.issues[0]!.code).toBe("invalid_value")
		}
	})

	it("rejects a missing required field", () => {
		const result = SettingsSchema.safeParse({ userId: "user-1" })
		expect(result.success).toBe(false)
		if (!result.success) {
			expect(result.error.issues[0]!.path).toEqual(["aiProcessingConsent"])
			expect(result.error.issues[0]!.code).toBe("invalid_type")
		}
	})
})

describe("UpdateSettingsSchema", () => {
	it("accepts a partial patch", () => {
		const result = UpdateSettingsSchema.parse({
			proactiveInsights: true,
			reflectionTone: "direct",
		})
		expect(result.proactiveInsights).toBe(true)
		expect(result.reflectionTone).toBe("direct")
	})

	it("accepts a nullable reminder time", () => {
		const result = UpdateSettingsSchema.parse({ reminderTime: null })
		expect(result.reminderTime).toBeNull()
	})

	it("rejects an invalid reminder time", () => {
		const result = UpdateSettingsSchema.safeParse({ reminderTime: "25:00" })
		expect(result.success).toBe(false)
		if (!result.success) {
			expect(result.error.issues[0]!.path).toEqual(["reminderTime"])
			expect(result.error.issues[0]!.code).toBe("invalid_format")
		}
	})

	it("rejects too many sensitive topics", () => {
		const result = UpdateSettingsSchema.safeParse({
			sensitiveTopics: Array.from({ length: 51 }, (_, i) => `topic-${i}`),
		})
		expect(result.success).toBe(false)
		if (!result.success) {
			expect(result.error.issues[0]!.path).toEqual(["sensitiveTopics"])
			expect(result.error.issues[0]!.code).toBe("too_big")
		}
	})
})
