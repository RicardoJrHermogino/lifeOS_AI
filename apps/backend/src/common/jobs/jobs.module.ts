import { Global, Logger, Module, OnApplicationBootstrap, OnApplicationShutdown } from "@nestjs/common"
import type { Worker } from "bullmq"

import { AiService } from "@/common/ai/ai.service"

import { JobsService } from "./jobs.service"
import { startExportWorker } from "./workers/export.worker"
import { startExtractionWorker } from "./workers/extraction.worker"
import { startTranscriptionWorker } from "./workers/transcription.worker"

@Global()
@Module({
	providers: [JobsService],
	exports: [JobsService],
})
export class JobsModule implements OnApplicationBootstrap, OnApplicationShutdown {
	private readonly logger = new Logger(JobsModule.name)
	private workers: Worker[] = []

	constructor(
		private readonly jobs: JobsService,
		private readonly ai: AiService
	) {}

	onApplicationBootstrap() {
		const list = [
			startTranscriptionWorker(this.ai, this.jobs),
			startExtractionWorker(this.ai),
			startExportWorker(),
		].filter((w): w is Worker => w !== null)
		this.workers = list
		if (list.length > 0) {
			this.logger.log(`Started ${list.length} BullMQ workers`)
		}
	}

	async onApplicationShutdown() {
		for (const w of this.workers) {
			await w.close()
		}
	}
}
