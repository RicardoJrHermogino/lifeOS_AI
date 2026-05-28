import { oc } from "@orpc/contract"

import { SettingsSchema, UpdateSettingsSchema } from "./settings.schema.js"

export const settingsContract = {
	/**
	 * Get the authenticated user's settings
	 * GET /settings
	 */
	get: oc
		.route({
			method: "GET",
			path: "/settings",
			summary: "Get user settings",
			description:
				"Returns the authenticated user's settings, creating defaults if none exist",
			tags: ["Settings"],
		})
		.output(SettingsSchema),

	/**
	 * Update the authenticated user's settings
	 * PATCH /settings
	 */
	update: oc
		.route({
			method: "PATCH",
			path: "/settings",
			summary: "Update user settings",
			description: "Partially update the authenticated user's consent and preferences",
			tags: ["Settings"],
		})
		.input(UpdateSettingsSchema)
		.output(SettingsSchema),
}
