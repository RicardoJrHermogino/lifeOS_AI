import { describe, expect, it } from "vitest"

import {
	ReflectionDateSchema,
	ReflectionFeedbackInputSchema,
	ReflectionSchema,
	UpdateReflectionSchema,
} from "./reflections.schema"

const reflection = {
	id: "11111111-1111-4111-8111-111111111111",
	userId: "user-1",
	date: "2026-05-28",
	content: "A calm day.",
	sourceMemoryIds: ["22222222-2222-4222-8222-222222222222"],
	isUserEdited: false,
	feedback: null,
	createdAt: "2026-05-28T00:00:00.000Z",
	updatedAt: "2026-05-28T01:00:00.000Z",
}

describe("ReflectionSchema", () => {
	it("parses a valid reflection and coerces dates", () => {
		const result = ReflectionSchema.parse(reflection)
		expect(result.createdAt).toBeInstanceOf(Date)
		expect(result.sourceMemoryIds).toHaveLength(1)
	})

	it("rejects an invalid source memory id", () => {
		const result = ReflectionSchema.safeParse({ ...reflection, sourceMemoryIds: ["bad-id"] })
		expect(result.success).toBe(false)
		if (!result.success) {
			expect(result.error.issues[0]!.path).toEqual(["sourceMemoryIds", 0])
			expect(result.error.issues[0]!.code).toBe("invalid_format")
		}
	})

	it("rejects a missing content field", () => {
		const result = ReflectionSchema.safeParse({ ...reflection, content: undefined })
		expect(result.success).toBe(false)
		if (!result.success) {
			expect(result.error.issues[0]!.path).toEqual(["content"])
			expect(result.error.issues[0]!.code).toBe("invalid_type")
		}
	})
})

describe("ReflectionDateSchema", () => {
	it("parses a YYYY-MM-DD date", () => {
		const result = ReflectionDateSchema.parse({ date: "2026-05-28" })
		expect(result.date).toBe("2026-05-28")
	})

	it("rejects an invalid date format", () => {
		const result = ReflectionDateSchema.safeParse({ date: "05/28/2026" })
		expect(result.success).toBe(false)
		if (!result.success) {
			expect(result.error.issues[0]!.path).toEqual(["date"])
			expect(result.error.issues[0]!.code).toBe("invalid_format")
		}
	})
})

describe("UpdateReflectionSchema", () => {
	it("parses content updates", () => {
		const result = UpdateReflectionSchema.parse({ id: reflection.id, content: "Updated" })
		expect(result.content).toBe("Updated")
	})

	it("rejects empty content", () => {
		const result = UpdateReflectionSchema.safeParse({ id: reflection.id, content: "" })
		expect(result.success).toBe(false)
		if (!result.success) {
			expect(result.error.issues[0]!.path).toEqual(["content"])
			expect(result.error.issues[0]!.code).toBe("too_small")
		}
	})
})

describe("ReflectionFeedbackInputSchema", () => {
	it("parses feedback", () => {
		const result = ReflectionFeedbackInputSchema.parse({
			id: reflection.id,
			feedback: "helpful",
		})
		expect(result.feedback).toBe("helpful")
	})
})
