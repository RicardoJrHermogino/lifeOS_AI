import { Controller } from "@nestjs/common"
import { Implement } from "@orpc/nest"
import { implement } from "@orpc/server"
import { Session, type UserSession } from "@thallesp/nestjs-better-auth"

import { v1 } from "@/config/api-versions.config"

import { TimelineService } from "./timeline.service"

@Controller()
export class TimelineController {
	constructor(private readonly timelineService: TimelineService) {}

	@Implement(v1.timeline.list)
	async listTimeline(@Session() session: UserSession) {
		return implement(v1.timeline.list).handler(async ({ input }) => {
			return this.timelineService.list({ query: input, userId: session.user.id })
		})
	}
}
