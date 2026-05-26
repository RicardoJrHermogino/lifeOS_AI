import { Controller } from "@nestjs/common"
import { Implement } from "@orpc/nest"
import { implement } from "@orpc/server"
import { Session, type UserSession } from "@thallesp/nestjs-better-auth"

import { v1 } from "@/config/api-versions.config"

import { ReflectionsService } from "./reflections.service"

@Controller()
export class ReflectionsController {
	constructor(private readonly reflectionsService: ReflectionsService) {}

	@Implement(v1.reflection.today)
	async today(@Session() session: UserSession) {
		return implement(v1.reflection.today).handler(async () => {
			return this.reflectionsService.today({ userId: session.user.id })
		})
	}

	@Implement(v1.reflection.getByDate)
	async getByDate(@Session() session: UserSession) {
		return implement(v1.reflection.getByDate).handler(async ({ input }) => {
			return this.reflectionsService.getByDate({ date: input.date, userId: session.user.id })
		})
	}

	@Implement(v1.reflection.update)
	async update(@Session() session: UserSession) {
		return implement(v1.reflection.update).handler(async ({ input }) => {
			return this.reflectionsService.update({ payload: input, userId: session.user.id })
		})
	}

	@Implement(v1.reflection.feedback)
	async feedback(@Session() session: UserSession) {
		return implement(v1.reflection.feedback).handler(async ({ input }) => {
			return this.reflectionsService.feedback({ payload: input, userId: session.user.id })
		})
	}
}
