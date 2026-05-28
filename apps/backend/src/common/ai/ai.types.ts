/**
 * Shape of structured memory fields produced by the extractor.
 */
export interface ExtractedMemory {
	title: string
	summary: string
	eventDate: Date
	emotions: string[]
	people: string[]
	places: string[]
	topics: string[]
	goals: string[]
	decisions: string[]
	actions: string[]
	sensitivity: string | null
	confidence: Record<string, number>
}

export interface MemoryRef {
	id: string
	title: string
	summary: string
	eventDate: Date | string
}

export interface AnswerResult {
	answer: string
	citations: Array<{ memoryId: string; title: string }>
}

export type ReflectionTone = "neutral" | "warm" | "direct"

export interface ExtractOptions {
	/** User-flagged sensitive topics to handle with extra care. */
	sensitiveTopics?: string[]
}

export interface ReflectionOptions {
	tone?: ReflectionTone
	/** When false, avoid inferring personal patterns beyond the listed memories. */
	personalize?: boolean
}

export interface AnswerOptions {
	sensitiveTopics?: string[]
}

export interface GeneratedInsight {
	type: string
	title: string
	body: string
	sourceMemoryIds: string[]
	evidence: "weak" | "moderate" | "strong"
}
