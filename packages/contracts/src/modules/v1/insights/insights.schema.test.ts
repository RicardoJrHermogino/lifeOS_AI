import { describe, expect, it } from "vitest"

import {
	InsightFeedbackInputSchema,
	InsightFeedbackSchema,
	InsightIdSchema,
	InsightSchema,
} from "./insights.schema"

const insight = {
	id: "11111111-1111-4111-8111-111111111111",
	userId: "user-1",
	type: "pattern",
	title: "Sleep pattern",
	body: "You sleep better after exercise.",
	sourceMemoryIds: ["22222222-2222-4222-8222-222222222222"],
	evidence: "strong",
	status: "active",
	feedback: null,
	createdAt: "2026-05-28T00:00:00.000Z",
	updatedAt: "2026-05-28T01:00:00.000Z",
}

describe("InsightSchema", () => {
	it("parses a valid insight and coerces date strings", () => {
		const result = InsightSchema.parse(insight)
		expect(result.createdAt).toBeInstanceOf(Date)
		expect(result.updatedAt).toBeInstanceOf(Date)
	})

	it("rejects an invalid evidence enum", () => {
		const result = InsightSchema.safeParse({ ...insight, evidence: "certain" })
		expect(result.success).toBe(false)
		if (!result.success) {
			expect(result.error.issues[0]!.path).toEqual(["evidence"])
			expect(result.error.issues[0]!.code).toBe("invalid_value")
		}
	})

	it("rejects an invalid status enum", () => {
		const result = InsightSchema.safeParse({ ...insight, status: "queued" })
		expect(result.success).toBe(false)
		if (!result.success) {
			expect(result.error.issues[0]!.path).toEqual(["status"])
			expect(result.error.issues[0]!.code).toBe("invalid_value")
		}
	})

	it("rejects an invalid source memory id", () => {
		const result = InsightSchema.safeParse({ ...insight, sourceMemoryIds: ["bad-id"] })
		expect(result.success).toBe(false)
		if (!result.success) {
			expect(result.error.issues[0]!.path).toEqual(["sourceMemoryIds", 0])
			expect(result.error.issues[0]!.code).toBe("invalid_format")
		}
	})
})

describe("InsightIdSchema", () => {
	it("parses a valid id", () => {
		const result = InsightIdSchema.parse({ id: insight.id })
		expect(result.id).toBe(insight.id)
	})

	it("rejects a missing id", () => {
		const result = InsightIdSchema.safeParse({})
		expect(result.success).toBe(false)
		if (!result.success) {
			expect(result.error.issues[0]!.path).toEqual(["id"])
			expect(result.error.issues[0]!.code).toBe("invalid_type")
		}
	})
})

describe("InsightFeedbackSchema", () => {
	it("parses valid feedback", () => {
		expect(InsightFeedbackSchema.parse("helpful")).toBe("helpful")
	})

	it("rejects invalid feedback", () => {
		const result = InsightFeedbackSchema.safeParse("maybe")
		expect(result.success).toBe(false)
		if (!result.success) {
			expect(result.error.issues[0]!.path).toEqual([])
			expect(result.error.issues[0]!.code).toBe("invalid_value")
		}
	})
})

describe("InsightFeedbackInputSchema", () => {
	it("parses valid feedback input", () => {
		const result = InsightFeedbackInputSchema.parse({
			id: insight.id,
			feedback: "not_helpful",
		})
		expect(result.feedback).toBe("not_helpful")
	})
})
