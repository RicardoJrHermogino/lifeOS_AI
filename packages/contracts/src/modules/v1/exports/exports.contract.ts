import { oc } from "@orpc/contract"
import { z } from "zod"

import { DataExportSchema, ExportIdSchema } from "./exports.schema.js"

export const exportContract = {
	/**
	 * Request a data export
	 * POST /exports
	 */
	request: oc
		.route({
			method: "POST",
			path: "/exports",
			summary: "Request data export",
			description: "Initiate a data export job. Returns the export record (status=pending).",
			tags: ["Exports"],
		})
		.output(DataExportSchema),

	/**
	 * Check export status
	 * GET /exports/{id}
	 */
	get: oc
		.route({
			method: "GET",
			path: "/exports/{id}",
			summary: "Get export status",
			description: "Get the current status and download URL of an export request",
			tags: ["Exports"],
		})
		.input(ExportIdSchema)
		.output(DataExportSchema),

	/**
	 * Delete the authenticated account
	 * DELETE /account
	 */
	deleteAccount: oc
		.route({
			method: "DELETE",
			path: "/account",
			summary: "Delete account",
			description: "Hard-delete the authenticated account and all associated data",
			tags: ["Account"],
		})
		.output(z.object({ success: z.boolean() })),
}
