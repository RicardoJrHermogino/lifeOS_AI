import { Controller } from "@nestjs/common"
import { Implement } from "@orpc/nest"
import { implement } from "@orpc/server"
import { Session, type UserSession } from "@thallesp/nestjs-better-auth"

import { v1 } from "@/config/api-versions.config"

import { CapturesService } from "./captures.service"

@Controller()
export class CapturesController {
	constructor(private readonly capturesService: CapturesService) {}

	@Implement(v1.capture.create)
	async createCapture(@Session() session: UserSession) {
		return implement(v1.capture.create).handler(async ({ input }) => {
			return this.capturesService.create({ payload: input, userId: session.user.id })
		})
	}

	@Implement(v1.capture.get)
	async getCapture(@Session() session: UserSession) {
		return implement(v1.capture.get).handler(async ({ input }) => {
			return this.capturesService.findOne({ id: input.id, userId: session.user.id })
		})
	}

	@Implement(v1.capture.patchTranscript)
	async patchTranscript(@Session() session: UserSession) {
		return implement(v1.capture.patchTranscript).handler(async ({ input }) => {
			return this.capturesService.patchTranscript({
				payload: input,
				userId: session.user.id,
			})
		})
	}
}
