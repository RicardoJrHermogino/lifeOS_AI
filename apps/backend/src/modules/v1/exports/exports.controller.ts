import { Controller } from "@nestjs/common"
import { Implement } from "@orpc/nest"
import { implement } from "@orpc/server"
import { Session, type UserSession } from "@thallesp/nestjs-better-auth"

import { v1 } from "@/config/api-versions.config"

import { ExportsService } from "./exports.service"

@Controller()
export class ExportsController {
	constructor(private readonly exportsService: ExportsService) {}

	@Implement(v1.export.request)
	async request(@Session() session: UserSession) {
		return implement(v1.export.request).handler(async () => {
			return this.exportsService.request({ userId: session.user.id })
		})
	}

	@Implement(v1.export.get)
	async getExport(@Session() session: UserSession) {
		return implement(v1.export.get).handler(async ({ input }) => {
			return this.exportsService.get({ id: input.id, userId: session.user.id })
		})
	}

	@Implement(v1.export.deleteAccount)
	async deleteAccount(@Session() session: UserSession) {
		return implement(v1.export.deleteAccount).handler(async () => {
			return this.exportsService.deleteAccount({ userId: session.user.id })
		})
	}
}
