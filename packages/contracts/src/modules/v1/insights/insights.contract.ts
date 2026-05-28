import { oc } from "@orpc/contract"
import { z } from "zod"

import {
	InsightFeedbackInputSchema,
	InsightIdSchema,
	InsightSchema,
} from "./insights.schema.js"

export const insightContract = {
	/**
	 * List active + saved insights
	 * GET /insights
	 */
	list: oc
		.route({
			method: "GET",
			path: "/insights",
			summary: "List insights",
			description: "Returns the user's active and saved insights",
			tags: ["Insights"],
		})
		.output(z.array(InsightSchema)),

	/**
	 * Generate new insights from saved memories
	 * POST /insights/generate
	 */
	generate: oc
		.route({
			method: "POST",
			path: "/insights/generate",
			summary: "Generate insights",
			description:
				"Analyzes the user's saved memories for grounded patterns and stores them as active insights",
			tags: ["Insights"],
		})
		.output(z.array(InsightSchema)),

	/**
	 * Save an insight
	 * PATCH /insights/{id}/save
	 */
	save: oc
		.route({
			method: "PATCH",
			path: "/insights/{id}/save",
			summary: "Save insight",
			tags: ["Insights"],
		})
		.input(InsightIdSchema)
		.output(InsightSchema),

	/**
	 * Dismiss an insight
	 * PATCH /insights/{id}/dismiss
	 */
	dismiss: oc
		.route({
			method: "PATCH",
			path: "/insights/{id}/dismiss",
			summary: "Dismiss insight",
			tags: ["Insights"],
		})
		.input(InsightIdSchema)
		.output(InsightSchema),

	/**
	 * Submit feedback on an insight
	 * POST /insights/{id}/feedback
	 */
	feedback: oc
		.route({
			method: "POST",
			path: "/insights/{id}/feedback",
			summary: "Insight feedback",
			tags: ["Insights"],
		})
		.input(InsightFeedbackInputSchema)
		.output(InsightSchema),
}
