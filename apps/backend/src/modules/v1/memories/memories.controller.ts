import { Controller } from "@nestjs/common"
import { Implement } from "@orpc/nest"
import { implement } from "@orpc/server"
import { Session, type UserSession } from "@thallesp/nestjs-better-auth"

import { v1 } from "@/config/api-versions.config"

import { MemoriesService } from "./memories.service"

@Controller()
export class MemoriesController {
	constructor(private readonly memoriesService: MemoriesService) {}

	@Implement(v1.memory.listCandidates)
	async listCandidates(@Session() session: UserSession) {
		return implement(v1.memory.listCandidates).handler(async ({ input }) => {
			return this.memoriesService.listCandidates({ query: input, userId: session.user.id })
		})
	}

	@Implement(v1.memory.get)
	async getMemory(@Session() session: UserSession) {
		return implement(v1.memory.get).handler(async ({ input }) => {
			return this.memoriesService.findOne({ id: input.id, userId: session.user.id })
		})
	}

	@Implement(v1.memory.update)
	async updateMemory(@Session() session: UserSession) {
		return implement(v1.memory.update).handler(async ({ input }) => {
			return this.memoriesService.update({ payload: input, userId: session.user.id })
		})
	}

	@Implement(v1.memory.delete)
	async deleteMemory(@Session() session: UserSession) {
		return implement(v1.memory.delete).handler(async ({ input }) => {
			return this.memoriesService.softDelete({ id: input.id, userId: session.user.id })
		})
	}

	@Implement(v1.memory.archive)
	async archiveMemory(@Session() session: UserSession) {
		return implement(v1.memory.archive).handler(async ({ input }) => {
			return this.memoriesService.archive({ id: input.id, userId: session.user.id })
		})
	}

	@Implement(v1.memory.restore)
	async restoreMemory(@Session() session: UserSession) {
		return implement(v1.memory.restore).handler(async ({ input }) => {
			return this.memoriesService.restore({ id: input.id, userId: session.user.id })
		})
	}
}
