import { describe, expect, it } from "vitest"

import {
	TimelineGroupSchema,
	TimelinePageSchema,
	TimelineQuerySchema,
} from "./timeline.schema"

const memory = {
	id: "11111111-1111-4111-8111-111111111111",
	userId: "user-1",
	rawCaptureId: null,
	title: "Dinner",
	summary: "Dinner with Sam",
	eventDate: "2026-05-28T00:00:00.000Z",
	emotions: [],
	people: [],
	places: [],
	topics: [],
	goals: [],
	decisions: [],
	actions: [],
	sensitivity: null,
	confidence: {},
	status: "saved",
	isUserCorrected: false,
	createdAt: "2026-05-28T01:00:00.000Z",
	updatedAt: "2026-05-28T02:00:00.000Z",
}

describe("TimelineQuerySchema", () => {
	it("parses defaults and filter passthroughs", () => {
		const result = TimelineQuerySchema.parse({
			mood: "happy",
			person: "Sam",
			topic: "family",
			from: "2026-05-01T00:00:00.000Z",
			to: "2026-05-28T00:00:00.000Z",
		})
		expect(result.limit).toBe(20)
		expect(result.from).toBeInstanceOf(Date)
		expect(result.topic).toBe("family")
	})

	it("coerces limit from string", () => {
		const result = TimelineQuerySchema.parse({ limit: "5" })
		expect(result.limit).toBe(5)
	})

	it("rejects a limit above the maximum", () => {
		const result = TimelineQuerySchema.safeParse({ limit: 101 })
		expect(result.success).toBe(false)
		if (!result.success) {
			expect(result.error.issues[0]!.path).toEqual(["limit"])
			expect(result.error.issues[0]!.code).toBe("too_big")
		}
	})
})

describe("TimelineGroupSchema", () => {
	it("parses a group with a YYYY-MM-DD date string", () => {
		const result = TimelineGroupSchema.parse({ date: "2026-05-28", memories: [memory] })
		expect(result.date).toBe("2026-05-28")
		expect(result.memories[0]!.eventDate).toBeInstanceOf(Date)
	})

	it("rejects missing memories", () => {
		const result = TimelineGroupSchema.safeParse({ date: "2026-05-28" })
		expect(result.success).toBe(false)
		if (!result.success) {
			expect(result.error.issues[0]!.path).toEqual(["memories"])
			expect(result.error.issues[0]!.code).toBe("invalid_type")
		}
	})
})

describe("TimelinePageSchema", () => {
	it("parses a page with a nullable cursor", () => {
		const result = TimelinePageSchema.parse({
			groups: [{ date: "2026-05-28", memories: [memory] }],
			nextCursor: null,
		})
		expect(result.nextCursor).toBeNull()
	})

	it("rejects a missing groups field", () => {
		const result = TimelinePageSchema.safeParse({ nextCursor: null })
		expect(result.success).toBe(false)
		if (!result.success) {
			expect(result.error.issues[0]!.path).toEqual(["groups"])
			expect(result.error.issues[0]!.code).toBe("invalid_type")
		}
	})
})
