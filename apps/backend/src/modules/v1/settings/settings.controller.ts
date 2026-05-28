import { Controller } from "@nestjs/common"
import { Implement } from "@orpc/nest"
import { implement } from "@orpc/server"
import { Session, type UserSession } from "@thallesp/nestjs-better-auth"

import { v1 } from "@/config/api-versions.config"

import { SettingsService } from "./settings.service"

@Controller()
export class SettingsController {
	constructor(private readonly settingsService: SettingsService) {}

	@Implement(v1.settings.get)
	async get(@Session() session: UserSession) {
		return implement(v1.settings.get).handler(async () => {
			return this.settingsService.getOrCreate({ userId: session.user.id })
		})
	}

	@Implement(v1.settings.update)
	async update(@Session() session: UserSession) {
		return implement(v1.settings.update).handler(async ({ input }) => {
			return this.settingsService.update({ payload: input, userId: session.user.id })
		})
	}
}
