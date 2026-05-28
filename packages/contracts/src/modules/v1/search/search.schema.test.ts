import { describe, expect, it } from "vitest"

import { AskInputSchema, AskOutputSchema, SearchInputSchema, SearchOutputSchema } from "./search.schema"

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

describe("SearchInputSchema", () => {
	it("parses a non-empty query and default limit", () => {
		const result = SearchInputSchema.parse({ query: "family" })
		expect(result.query).toBe("family")
		expect(result.limit).toBe(10)
	})

	it("coerces a string limit", () => {
		const result = SearchInputSchema.parse({ query: "family", limit: "5" })
		expect(result.limit).toBe(5)
	})

	it("rejects an empty query", () => {
		const result = SearchInputSchema.safeParse({ query: "" })
		expect(result.success).toBe(false)
		if (!result.success) {
			expect(result.error.issues[0]!.path).toEqual(["query"])
			expect(result.error.issues[0]!.code).toBe("too_small")
		}
	})

	it("rejects a limit above the maximum", () => {
		const result = SearchInputSchema.safeParse({ query: "family", limit: 51 })
		expect(result.success).toBe(false)
		if (!result.success) {
			expect(result.error.issues[0]!.path).toEqual(["limit"])
			expect(result.error.issues[0]!.code).toBe("too_big")
		}
	})
})

describe("SearchOutputSchema", () => {
	it("parses search results", () => {
		const result = SearchOutputSchema.parse({
			results: [{ memory, score: 0.75 }],
		})
		expect(result.results[0]!.memory.id).toBe(memory.id)
		expect(result.results[0]!.memory.eventDate).toBeInstanceOf(Date)
	})

	it("rejects a hit with an invalid memory id", () => {
		const result = SearchOutputSchema.safeParse({
			results: [{ memory: { ...memory, id: "bad-id" }, score: 0.75 }],
		})
		expect(result.success).toBe(false)
		if (!result.success) {
			expect(result.error.issues[0]!.path).toEqual(["results", 0, "memory", "id"])
			expect(result.error.issues[0]!.code).toBe("invalid_format")
		}
	})
})

describe("AskInputSchema", () => {
	it("parses defaults", () => {
		const result = AskInputSchema.parse({ question: "What happened?" })
		expect(result.limit).toBe(8)
	})

	it("rejects an empty question", () => {
		const result = AskInputSchema.safeParse({ question: "" })
		expect(result.success).toBe(false)
		if (!result.success) {
			expect(result.error.issues[0]!.path).toEqual(["question"])
			expect(result.error.issues[0]!.code).toBe("too_small")
		}
	})
})

describe("AskOutputSchema", () => {
	it("parses an answer with citations", () => {
		const result = AskOutputSchema.parse({
			answer: "You had dinner.",
			citations: [{ memoryId: memory.id, title: "Dinner" }],
		})
		expect(result.citations[0]!.memoryId).toBe(memory.id)
	})
})
