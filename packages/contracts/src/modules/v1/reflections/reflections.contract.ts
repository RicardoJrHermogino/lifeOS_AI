import { oc } from "@orpc/contract"

import {
	ReflectionDateSchema,
	ReflectionFeedbackInputSchema,
	ReflectionIdSchema,
	ReflectionSchema,
	UpdateReflectionSchema,
} from "./reflections.schema.js"

export const reflectionContract = {
	/**
	 * Get (or generate) today's reflection
	 * GET /reflections/today
	 */
	today: oc
		.route({
			method: "GET",
			path: "/reflections/today",
			summary: "Today's reflection",
			description: "Returns today's reflection, generating it if missing",
			tags: ["Reflections"],
		})
		.output(ReflectionSchema),

	/**
	 * Get a reflection by date
	 * GET /reflections/{date}
	 */
	getByDate: oc
		.route({
			method: "GET",
			path: "/reflections/{date}",
			summary: "Get reflection by date",
			description: "Retrieve the reflection for a specific YYYY-MM-DD date",
			tags: ["Reflections"],
		})
		.input(ReflectionDateSchema)
		.output(ReflectionSchema),

	/**
	 * Edit a reflection
	 * PATCH /reflections/{id}
	 */
	update: oc
		.route({
			method: "PATCH",
			path: "/reflections/{id}",
			summary: "Update reflection",
			description: "User edits a reflection's content",
			tags: ["Reflections"],
		})
		.input(UpdateReflectionSchema)
		.output(ReflectionSchema),

	/**
	 * Submit feedback on a reflection
	 * POST /reflections/{id}/feedback
	 */
	feedback: oc
		.route({
			method: "POST",
			path: "/reflections/{id}/feedback",
			summary: "Submit reflection feedback",
			description: "User marks a reflection helpful or inaccurate",
			tags: ["Reflections"],
		})
		.input(ReflectionFeedbackInputSchema)
		.output(ReflectionSchema),
}

// re-export id schema for backward compatibility if needed
export { ReflectionIdSchema }
