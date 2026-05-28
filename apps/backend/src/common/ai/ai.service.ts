import { Injectable, Logger, ServiceUnavailableException } from "@nestjs/common"
import OpenAI from "openai"

import { env } from "@/config/env.config"

import type {
	AnswerOptions,
	AnswerResult,
	ExtractedMemory,
	ExtractOptions,
	GeneratedInsight,
	MemoryRef,
	ReflectionOptions,
} from "./ai.types"

const EMBED_DIMS = 1536

@Injectable()
export class AiService {
	private readonly logger = new Logger(AiService.name)
	private readonly enabled = !!env.OPENAI_API_KEY
	private client: OpenAI | null = null

	private ensureEnabled(): OpenAI {
		if (!this.enabled) {
			throw new ServiceUnavailableException(
				"AI provider not configured. Set OPENAI_API_KEY to enable AI features."
			)
		}
		if (!this.client) {
			this.client = new OpenAI({ apiKey: env.OPENAI_API_KEY })
		}
		return this.client
	}

	async transcribe(audio: Buffer | NodeJS.ReadableStream): Promise<string> {
		const client = this.ensureEnabled()
		const file =
			audio instanceof Buffer
				? await OpenAI.toFile(audio, "capture.webm")
				: await OpenAI.toFile(audio, "capture.webm")
		const result = await client.audio.transcriptions.create({
			file,
			model: "whisper-1",
			response_format: "text",
		})
		return typeof result === "string" ? result : (result as { text: string }).text
	}

	async extractMemory(text: string, opts?: ExtractOptions): Promise<ExtractedMemory> {
		const client = this.ensureEnabled()
		const sensitiveLine =
			opts?.sensitiveTopics && opts.sensitiveTopics.length > 0
				? `\n\nThe user has flagged these topics as sensitive: ${opts.sensitiveTopics.join(", ")}. If the capture touches them, set "sensitivity" accordingly and keep the summary factual, respectful, and non-judgmental.`
				: ""
		const systemPrompt = `You are a careful memory extractor. Extract structured fields from a user's raw capture. Use ONLY facts present in the input text. Do not invent people, places, dates, or feelings. If a field is not present, return an empty array or null.

Return a JSON object with these fields:
- title (string, <=80 chars): concise title for the moment
- summary (string, <=280 chars): neutral summary
- eventDate (ISO 8601 string or null): when the event happened, only if explicitly stated
- emotions (string[]): emotional words present
- people (string[]): named persons mentioned
- places (string[]): named places mentioned
- topics (string[]): topics/themes
- goals (string[]): stated goals or intentions
- decisions (string[]): decisions made
- actions (string[]): actions or commitments
- sensitivity (string or null): one of "health","finance","relationship","work","other" if sensitive, else null
- confidence (object mapping field name -> number 0..1)${sensitiveLine}`

		const response = await client.chat.completions.create({
			model: env.OPENAI_MODEL,
			temperature: 0,
			response_format: { type: "json_object" },
			messages: [
				{ role: "system", content: systemPrompt },
				{ role: "user", content: text },
			],
		})

		const raw = response.choices[0]?.message?.content ?? "{}"
		const parsed = JSON.parse(raw) as Partial<ExtractedMemory> & { eventDate?: string | null }

		const eventDate = parsed.eventDate ? new Date(parsed.eventDate) : new Date()

		return {
			title: parsed.title?.slice(0, 80) ?? text.slice(0, 64),
			summary: parsed.summary?.slice(0, 280) ?? text.slice(0, 280),
			eventDate: isNaN(eventDate.getTime()) ? new Date() : eventDate,
			emotions: parsed.emotions ?? [],
			people: parsed.people ?? [],
			places: parsed.places ?? [],
			topics: parsed.topics ?? [],
			goals: parsed.goals ?? [],
			decisions: parsed.decisions ?? [],
			actions: parsed.actions ?? [],
			sensitivity: parsed.sensitivity ?? null,
			confidence: parsed.confidence ?? {},
		}
	}

	async embed(text: string): Promise<number[]> {
		const client = this.ensureEnabled()
		const response = await client.embeddings.create({
			model: env.OPENAI_EMBEDDING_MODEL,
			input: text,
		})
		const vec = response.data[0]?.embedding ?? []
		if (vec.length !== EMBED_DIMS) {
			this.logger.warn(
				`Embedding dim mismatch: got ${vec.length}, expected ${EMBED_DIMS}. Check OPENAI_EMBEDDING_MODEL.`
			)
		}
		return vec
	}

	async generateReflection(memories: MemoryRef[], opts?: ReflectionOptions): Promise<string> {
		const client = this.ensureEnabled()
		if (memories.length === 0) {
			return "No memories captured for this day."
		}
		const toneLine = {
			warm: "Keep tone warm and encouraging.",
			neutral: "Keep tone neutral and factual.",
			direct: "Keep tone direct and concise.",
		}[opts?.tone ?? "warm"]
		const personalLine =
			opts?.personalize === false
				? " Do not infer personal patterns or traits beyond what the listed memories state."
				: ""
		const memoryBlock = memories
			.map(m => `- [${m.id}] ${m.title}: ${m.summary}`)
			.join("\n")
		const response = await client.chat.completions.create({
			model: env.OPENAI_MODEL,
			temperature: 0.3,
			messages: [
				{
					role: "system",
					content: `You write calm, grounded daily reflections from a user's memories. Use only the provided memories. Do not give medical, legal, or therapy advice. ${toneLine}${personalLine} Max 6 sentences.`,
				},
				{
					role: "user",
					content: `Reflect on this day using ONLY these memories:\n\n${memoryBlock}`,
				},
			],
		})
		return response.choices[0]?.message?.content?.trim() ?? ""
	}

	async generateInsights(memories: MemoryRef[]): Promise<GeneratedInsight[]> {
		const client = this.ensureEnabled()
		if (memories.length < 3) return []

		const validIds = new Set(memories.map(m => m.id))
		const memoryBlock = memories
			.map(m => `[${m.id}] ${m.title}: ${m.summary}`)
			.join("\n")

		const response = await client.chat.completions.create({
			model: env.OPENAI_MODEL,
			temperature: 0.2,
			response_format: { type: "json_object" },
			messages: [
				{
					role: "system",
					content: `You surface grounded patterns across a user's saved memories. Return a JSON object: { "insights": Insight[] }.
Each Insight has:
- type (string): short kind, e.g. "pattern", "theme", "goal_progress"
- title (string, <=80 chars)
- body (string, <=400 chars): describe the pattern and reference what supports it
- sourceMemoryIds (string[]): 2+ memory IDs from the input that support this insight
- evidence ("weak"|"moderate"|"strong")

Rules: Use ONLY the provided memories. Every insight must be supported by at least 2 distinct memory IDs that exist in the input. Do not invent facts. Do NOT make medical, diagnostic, or therapy claims. Label tentative patterns as "weak". Return at most 5 insights. If there is not enough signal, return an empty array.`,
				},
				{
					role: "user",
					content: `Memories:\n${memoryBlock}`,
				},
			],
		})

		const raw = response.choices[0]?.message?.content ?? "{}"
		let parsed: { insights?: unknown }
		try {
			parsed = JSON.parse(raw) as { insights?: unknown }
		} catch {
			return []
		}
		const list = Array.isArray(parsed.insights) ? parsed.insights : []

		const result: GeneratedInsight[] = []
		for (const item of list) {
			if (typeof item !== "object" || item === null) continue
			const obj = item as Record<string, unknown>
			const ids = Array.isArray(obj.sourceMemoryIds)
				? obj.sourceMemoryIds.filter(
						(id): id is string => typeof id === "string" && validIds.has(id)
					)
				: []
			// Require grounding in 2+ real memories.
			if (ids.length < 2) continue
			const evidence =
				obj.evidence === "strong" || obj.evidence === "weak"
					? obj.evidence
					: "moderate"
			result.push({
				type: typeof obj.type === "string" ? obj.type : "pattern",
				title: typeof obj.title === "string" ? obj.title.slice(0, 80) : "Pattern",
				body: typeof obj.body === "string" ? obj.body.slice(0, 400) : "",
				sourceMemoryIds: ids,
				evidence,
			})
			if (result.length >= 5) break
		}
		return result
	}

	async answerQuestion(
		question: string,
		memories: MemoryRef[],
		opts?: AnswerOptions
	): Promise<AnswerResult> {
		const client = this.ensureEnabled()
		if (memories.length === 0) {
			return {
				answer: "I don't have enough memories to answer this yet.",
				citations: [],
			}
		}
		const sensitiveLine =
			opts?.sensitiveTopics && opts.sensitiveTopics.length > 0
				? ` Use especially gentle, non-judgmental language around these sensitive topics: ${opts.sensitiveTopics.join(", ")}.`
				: ""
		const context = memories
			.map(m => `[${m.id}] ${m.title} (${new Date(m.eventDate).toISOString().slice(0, 10)}): ${m.summary}`)
			.join("\n")
		const response = await client.chat.completions.create({
			model: env.OPENAI_MODEL,
			temperature: 0,
			messages: [
				{
					role: "system",
					content: `Answer ONLY using the provided memories. Cite memory IDs inline like [id]. If the memories do not contain the answer, say you do not have enough information. Never invent facts. Avoid medical, legal, or therapy claims.${sensitiveLine}`,
				},
				{
					role: "user",
					content: `Memories:\n${context}\n\nQuestion: ${question}`,
				},
			],
		})
		const answer = response.choices[0]?.message?.content?.trim() ?? ""
		const cited = new Set<string>()
		const idRegex = /\[([0-9a-f-]{8,})\]/gi
		let match: RegExpExecArray | null
		while ((match = idRegex.exec(answer)) !== null) {
			const memoryId = match[1]
			if (memoryId) {
				cited.add(memoryId)
			}
		}
		const citations = memories
			.filter(m => cited.has(m.id))
			.map(m => ({ memoryId: m.id, title: m.title }))
		return { answer, citations }
	}
}
