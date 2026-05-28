import { Controller } from "@nestjs/common"
import { Implement } from "@orpc/nest"
import { implement } from "@orpc/server"
import { Session, type UserSession } from "@thallesp/nestjs-better-auth"

import { v1 } from "@/config/api-versions.config"

import { InsightsService } from "./insights.service"

@Controller()
export class InsightsController {
	constructor(private readonly insightsService: InsightsService) {}

	@Implement(v1.insight.list)
	async list(@Session() session: UserSession) {
		return implement(v1.insight.list).handler(async () => {
			return this.insightsService.list({ userId: session.user.id })
		})
	}

	@Implement(v1.insight.generate)
	async generate(@Session() session: UserSession) {
		return implement(v1.insight.generate).handler(async () => {
			return this.insightsService.generate({ userId: session.user.id })
		})
	}

	@Implement(v1.insight.save)
	async save(@Session() session: UserSession) {
		return implement(v1.insight.save).handler(async ({ input }) => {
			return this.insightsService.save({ payload: input, userId: session.user.id })
		})
	}

	@Implement(v1.insight.dismiss)
	async dismiss(@Session() session: UserSession) {
		return implement(v1.insight.dismiss).handler(async ({ input }) => {
			return this.insightsService.dismiss({ payload: input, userId: session.user.id })
		})
	}

	@Implement(v1.insight.feedback)
	async feedback(@Session() session: UserSession) {
		return implement(v1.insight.feedback).handler(async ({ input }) => {
			return this.insightsService.feedback({ payload: input, userId: session.user.id })
		})
	}
}
