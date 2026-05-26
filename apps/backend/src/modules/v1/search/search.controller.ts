import { Controller } from "@nestjs/common"
import { Implement } from "@orpc/nest"
import { implement } from "@orpc/server"
import { Session, type UserSession } from "@thallesp/nestjs-better-auth"

import { v1 } from "@/config/api-versions.config"

import { SearchService } from "./search.service"

@Controller()
export class SearchController {
	constructor(private readonly searchService: SearchService) {}

	@Implement(v1.search.search)
	async semanticSearch(@Session() session: UserSession) {
		return implement(v1.search.search).handler(async ({ input }) => {
			return this.searchService.search({ payload: input, userId: session.user.id })
		})
	}

	@Implement(v1.search.ask)
	async askQuestion(@Session() session: UserSession) {
		return implement(v1.search.ask).handler(async ({ input }) => {
			return this.searchService.ask({ payload: input, userId: session.user.id })
		})
	}
}
