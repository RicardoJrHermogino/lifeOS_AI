import { describe, expect, it } from "vitest"

import { MemoryIdSchema, MemorySchema, UpdateMemorySchema } from "./memories.schema"

const memory = {
	id: "11111111-1111-4111-8111-111111111111",
	userId: "user-1",
	rawCaptureId: null,
	title: "Dinner",
	summary: "Dinner with Sam",
	eventDate: "2026-05-28T00:00:00.000Z",
	emotions: ["happy"],
	people: ["Sam"],
	places: ["Home"],
	topics: ["family"],
	goals: [],
	decisions: [],
	actions: [],
	sensitivity: null,
	confidence: { title: 0.9 },
	status: "saved",
	isUserCorrected: false,
	createdAt: "2026-05-28T01:00:00.000Z",
	updatedAt: "2026-05-28T02:00:00.000Z",
}

describe("MemorySchema", () => {
	it("parses a valid memory and coerces dates", () => {
		const result = MemorySchema.parse(memory)
		expect(result.eventDate).toBeInstanceOf(Date)
		expect(result.sensitivity).toBeNull()
	})

	it("rejects an invalid id", () => {
		const result = MemorySchema.safeParse({ ...memory, id: "bad-id" })
		expect(result.success).toBe(false)
		if (!result.success) {
			expect(result.error.issues[0]!.path).toEqual(["id"])
			expect(result.error.issues[0]!.code).toBe("invalid_format")
		}
	})

	it("rejects an invalid status", () => {
		const result = MemorySchema.safeParse({ ...memory, status: "pending" })
		expect(result.success).toBe(false)
		if (!result.success) {
			expect(result.error.issues[0]!.path).toEqual(["status"])
			expect(result.error.issues[0]!.code).toBe("invalid_value")
		}
	})

	it("rejects a missing required field", () => {
		const result = MemorySchema.safeParse({ ...memory, title: undefined })
		expect(result.success).toBe(false)
		if (!result.success) {
			expect(result.error.issues[0]!.path).toEqual(["title"])
			expect(result.error.issues[0]!.code).toBe("invalid_type")
		}
	})
})

describe("MemoryIdSchema", () => {
	it("parses a valid uuid", () => {
		const result = MemoryIdSchema.parse({ id: memory.id })
		expect(result.id).toBe(memory.id)
	})

	it("rejects a missing id", () => {
		const result = MemoryIdSchema.safeParse({})
		expect(result.success).toBe(false)
		if (!result.success) {
			expect(result.error.issues[0]!.path).toEqual(["id"])
			expect(result.error.issues[0]!.code).toBe("invalid_type")
		}
	})
})

describe("UpdateMemorySchema", () => {
	it("parses a partial update and coerces eventDate", () => {
		const result = UpdateMemorySchema.parse({
			id: memory.id,
			title: "Updated",
			eventDate: "2026-05-29T00:00:00.000Z",
			sensitivity: null,
		})
		expect(result.eventDate).toBeInstanceOf(Date)
		expect(result.sensitivity).toBeNull()
	})

	it("rejects an empty title", () => {
		const result = UpdateMemorySchema.safeParse({ id: memory.id, title: "" })
		expect(result.success).toBe(false)
		if (!result.success) {
			expect(result.error.issues[0]!.path).toEqual(["title"])
			expect(result.error.issues[0]!.code).toBe("too_small")
		}
	})
})
