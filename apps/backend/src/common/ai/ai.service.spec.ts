import { AiService } from "./ai.service"
import type { MemoryRef } from "./ai.types"

type OpenAiMocks = {
	chatCreate: jest.Mock
	transcriptionsCreate: jest.Mock
	toFile: jest.Mock
}

const getOpenAiMocks = () => (globalThis as unknown as { openAiMocks: OpenAiMocks }).openAiMocks

jest.mock("openai", () => ({
	__esModule: true,
	default: (() => {
		const mocks: OpenAiMocks = {
			chatCreate: jest.fn(),
			transcriptionsCreate: jest.fn(),
			toFile: jest.fn(async (input: unknown) => input),
		}
		;(globalThis as unknown as { openAiMocks: OpenAiMocks }).openAiMocks = mocks
		return class MockOpenAI {
			static toFile = mocks.toFile
			chat = { completions: { create: mocks.chatCreate } }
			audio = { transcriptions: { create: mocks.transcriptionsCreate } }
		}
	})(),
}))

jest.mock("@/config/env.config", () => ({
	env: {
		OPENAI_API_KEY: "test",
		OPENAI_MODEL: "gpt-test",
		OPENAI_EMBEDDING_MODEL: "embed-test",
	},
}))

const ids = {
	a: "11111111-1111-4111-8111-111111111111",
	b: "22222222-2222-4222-8222-222222222222",
	c: "33333333-3333-4333-8333-333333333333",
	d: "44444444-4444-4444-8444-444444444444",
	e: "55555555-5555-4555-8555-555555555555",
	f: "66666666-6666-4666-8666-666666666666",
}

const memories: MemoryRef[] = [
	{ id: ids.a, title: "A", summary: "First memory", eventDate: new Date() },
	{ id: ids.b, title: "B", summary: "Second memory", eventDate: new Date() },
	{ id: ids.c, title: "C", summary: "Third memory", eventDate: new Date() },
	{ id: ids.d, title: "D", summary: "Fourth memory", eventDate: new Date() },
	{ id: ids.e, title: "E", summary: "Fifth memory", eventDate: new Date() },
	{ id: ids.f, title: "F", summary: "Sixth memory", eventDate: new Date() },
]

function openAiResponse(content: string) {
	return { choices: [{ message: { content } }] }
}

describe("AiService", () => {
	let service: AiService

	beforeEach(() => {
		jest.clearAllMocks()
		service = new AiService()
	})

	describe("answerQuestion", () => {
		it("returns fallback answer with no memories", async () => {
			const result = await service.answerQuestion("What happened?", [])
			expect(result).toEqual({
				answer: "I don't have enough memories to answer this yet.",
				citations: [],
			})
			expect(getOpenAiMocks().chatCreate).not.toHaveBeenCalled()
		})

		it("returns only cited known memories with titles", async () => {
			getOpenAiMocks().chatCreate.mockResolvedValueOnce(
				openAiResponse(`You did A [${ids.a}] and B [${ids.b}].`)
			)
			const result = await service.answerQuestion("What happened?", memories.slice(0, 3))
			expect(result.citations).toEqual([
				{ memoryId: ids.a, title: "A" },
				{ memoryId: ids.b, title: "B" },
			])
		})

		it("filters cited ids that are not in provided memories", async () => {
			getOpenAiMocks().chatCreate.mockResolvedValueOnce(
				openAiResponse(`Unknown [99999999-9999-4999-8999-999999999999].`)
			)
			const result = await service.answerQuestion("What happened?", memories.slice(0, 3))
			expect(result.citations).toEqual([])
		})
	})

	describe("generateInsights", () => {
		it("returns empty for fewer than three memories", async () => {
			const result = await service.generateInsights(memories.slice(0, 2))
			expect(result).toEqual([])
			expect(getOpenAiMocks().chatCreate).not.toHaveBeenCalled()
		})

		it("filters unsupported insights, normalizes evidence, slices text, and caps results", async () => {
			getOpenAiMocks().chatCreate.mockResolvedValueOnce(
				openAiResponse(
					JSON.stringify({
						insights: [
							{ title: "one", body: "x", sourceMemoryIds: [ids.a], evidence: "strong" },
							{ title: "two", body: "x", sourceMemoryIds: [ids.a, "unknown"], evidence: "weak" },
							...Array.from({ length: 6 }, (_, i) => ({
								type: "pattern",
								title: `${i}`.repeat(100),
								body: `${i}`.repeat(500),
								sourceMemoryIds: [ids.a, ids.b],
								evidence: i === 0 ? "certain" : "strong",
							})),
						],
					})
				)
			)
			const result = await service.generateInsights(memories)
			expect(result).toHaveLength(5)
			expect(result[0]!.evidence).toBe("moderate")
			expect(result[0]!.title).toHaveLength(80)
			expect(result[0]!.body).toHaveLength(400)
			expect(result.every(item => item.sourceMemoryIds.length >= 2)).toBe(true)
		})

		it("returns empty for invalid JSON", async () => {
			getOpenAiMocks().chatCreate.mockResolvedValueOnce(openAiResponse("not json"))
			await expect(service.generateInsights(memories)).resolves.toEqual([])
		})
	})

	describe("extractMemory", () => {
		it("passes through full JSON and converts eventDate", async () => {
			getOpenAiMocks().chatCreate.mockResolvedValueOnce(
				openAiResponse(
					JSON.stringify({
						title: "Title",
						summary: "Summary",
						eventDate: "2026-05-28T00:00:00.000Z",
						emotions: ["calm"],
						people: ["Sam"],
						places: ["Home"],
						topics: ["family"],
						goals: ["rest"],
						decisions: ["stay in"],
						actions: ["cook"],
						sensitivity: "work",
						confidence: { title: 0.9 },
					})
				)
			)
			const result = await service.extractMemory("raw text")
			expect(result.eventDate).toBeInstanceOf(Date)
			expect(result.people).toEqual(["Sam"])
			expect(result.confidence).toEqual({ title: 0.9 })
		})

		it("uses fallbacks for missing title, summary, eventDate, and arrays", async () => {
			getOpenAiMocks().chatCreate.mockResolvedValueOnce(openAiResponse(JSON.stringify({})))
			const result = await service.extractMemory("fallback text")
			expect(result.title).toBe("fallback text")
			expect(result.summary).toBe("fallback text")
			expect(result.eventDate).toBeInstanceOf(Date)
			expect(result.emotions).toEqual([])
		})

		it("falls back to a valid Date for invalid eventDate", async () => {
			getOpenAiMocks().chatCreate.mockResolvedValueOnce(
				openAiResponse(JSON.stringify({ eventDate: "not-a-date" }))
			)
			const result = await service.extractMemory("raw text")
			expect(result.eventDate).toBeInstanceOf(Date)
			expect(Number.isNaN(result.eventDate.getTime())).toBe(false)
		})

		it("includes sensitive topics in the system prompt", async () => {
			getOpenAiMocks().chatCreate.mockResolvedValueOnce(openAiResponse(JSON.stringify({})))
			await service.extractMemory("raw text", { sensitiveTopics: ["health", "money"] })
			const arg = getOpenAiMocks().chatCreate.mock.calls[0]![0]
			expect(arg.messages[0].content).toContain("health, money")
		})
	})
})
