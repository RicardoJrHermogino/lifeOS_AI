import { oc } from "@orpc/contract"

import {
	CaptureIdSchema,
	CaptureSchema,
	CreateCaptureSchema,
	UpdateTranscriptSchema,
} from "./captures.schema.js"

export const captureContract = {
	/**
	 * Create a raw capture (text or voice)
	 * POST /captures
	 */
	create: oc
		.route({
			method: "POST",
			path: "/captures",
			summary: "Create capture",
			description: "Create a raw capture (text body or voice audio reference)",
			tags: ["Captures"],
		})
		.input(CreateCaptureSchema)
		.output(CaptureSchema),

	/**
	 * Get a capture by ID
	 * GET /captures/{id}
	 */
	get: oc
		.route({
			method: "GET",
			path: "/captures/{id}",
			summary: "Get capture",
			description: "Retrieve a single raw capture with its processing status",
			tags: ["Captures"],
		})
		.input(CaptureIdSchema)
		.output(CaptureSchema),

	/**
	 * Patch the transcript (user correction)
	 * PATCH /captures/{id}/transcript
	 */
	patchTranscript: oc
		.route({
			method: "PATCH",
			path: "/captures/{id}/transcript",
			summary: "Correct transcript",
			description: "User-provided correction to a voice capture transcript",
			tags: ["Captures"],
		})
		.input(UpdateTranscriptSchema)
		.output(CaptureSchema),
}
