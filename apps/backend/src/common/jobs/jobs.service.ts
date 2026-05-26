import { Injectable, Logger, OnModuleDestroy } from "@nestjs/common"
import { Queue } from "bullmq"

import { env } from "@/config/env.config"

import type { JobPayloads, QueueName } from "./jobs.types"

@Injectable()
export class JobsService implements OnModuleDestroy {
	private readonly logger = new Logger(JobsService.name)
	private readonly hasRedis = !!env.REDIS_URL
	private readonly queues = new Map<QueueName, Queue>()

	private getQueue(name: QueueName): Queue {
		let q = this.queues.get(name)
		if (!q) {
			q = new Queue(name, {
				connection: { url: env.REDIS_URL as string },
			})
			this.queues.set(name, q)
		}
		return q
	}

	async enqueue<Q extends QueueName>(queue: Q, payload: JobPayloads[Q]): Promise<void> {
		if (!this.hasRedis) {
			this.logger.debug(`[no-redis] enqueue ${queue} ${JSON.stringify(payload)}`)
			return
		}
		await this.getQueue(queue).add(queue, payload, {
			attempts: 3,
			backoff: { type: "exponential", delay: 2000 },
			removeOnComplete: 100,
			removeOnFail: 500,
		})
	}

	async onModuleDestroy() {
		for (const q of this.queues.values()) {
			await q.close()
		}
	}
}
