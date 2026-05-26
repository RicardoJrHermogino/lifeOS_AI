export type QueueName = "transcription" | "extraction" | "reflection" | "export"

export interface TranscriptionJob {
	captureId: string
	userId: string
}

export interface ExtractionJob {
	captureId: string
	userId: string
}

export interface ReflectionJob {
	userId: string
	date: string // YYYY-MM-DD
}

export interface ExportJob {
	exportId: string
	userId: string
}

export interface JobPayloads {
	transcription: TranscriptionJob
	extraction: ExtractionJob
	reflection: ReflectionJob
	export: ExportJob
}
