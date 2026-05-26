import { oc } from "@orpc/contract"

import { TimelinePageSchema, TimelineQuerySchema } from "./timeline.schema.js"

export const timelineContract = {
	/**
	 * Paginated, day-grouped timeline of saved memories
	 * GET /timeline
	 */
	list: oc
		.route({
			method: "GET",
			path: "/timeline",
			summary: "Get timeline",
			description: "Cursor-paginated timeline of saved memories grouped by day",
			tags: ["Timeline"],
		})
		.input(TimelineQuerySchema)
		.output(TimelinePageSchema),
}
