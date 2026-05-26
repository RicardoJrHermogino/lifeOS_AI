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
