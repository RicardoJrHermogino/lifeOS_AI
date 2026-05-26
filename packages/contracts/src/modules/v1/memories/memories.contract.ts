import { oc } from "@orpc/contract"
import { z } from "zod"

import {
	CandidatesQuerySchema,
	MemoryIdSchema,
	MemorySchema,
	UpdateMemorySchema,
} from "./memories.schema.js"

export const memoryContract = {
	/**
	 * List candidate memories awaiting review
	 * GET /memories/candidates
	 */
	listCandidates: oc
		.route({
			method: "GET",
			path: "/memories/candidates",
			summary: "List candidate memories",
			description: "AI-extracted memories pending user review",
			tags: ["Memories"],
		})
		.input(CandidatesQuerySchema)
		.output(
			z.object({
				items: z.array(MemorySchema),
				nextCursor: z.string().uuid().nullable(),
			})
		),

	/**
	 * Get a memory by ID
	 * GET /memories/{id}
	 */
	get: oc
		.route({
			method: "GET",
			path: "/memories/{id}",
			summary: "Get memory",
			description: "Retrieve a single memory by ID",
			tags: ["Memories"],
		})
		.input(MemoryIdSchema)
		.output(MemorySchema),

	/**
	 * Edit memory fields (marks is_user_corrected)
	 * PATCH /memories/{id}
	 */
	update: oc
		.route({
			method: "PATCH",
			path: "/memories/{id}",
			summary: "Update memory",
			description: "Edit memory fields. Sets is_user_corrected=true.",
			tags: ["Memories"],
		})
		.input(UpdateMemorySchema)
		.output(MemorySchema),

	/**
	 * Soft-delete a memory
	 * DELETE /memories/{id}
	 */
	delete: oc
		.route({
			method: "DELETE",
			path: "/memories/{id}",
			summary: "Delete memory",
			description: "Soft-delete a memory (status=deleted)",
			tags: ["Memories"],
		})
		.input(MemoryIdSchema)
		.output(z.object({ success: z.boolean(), id: z.string().uuid() })),

	/**
	 * Archive a memory
	 * PATCH /memories/{id}/archive
	 */
	archive: oc
		.route({
			method: "PATCH",
			path: "/memories/{id}/archive",
			summary: "Archive memory",
			description: "Move a memory to archived status",
			tags: ["Memories"],
		})
		.input(MemoryIdSchema)
		.output(MemorySchema),

	/**
	 * Restore an archived memory
	 * PATCH /memories/{id}/restore
	 */
	restore: oc
		.route({
			method: "PATCH",
			path: "/memories/{id}/restore",
			summary: "Restore memory",
			description: "Restore an archived memory to saved status",
			tags: ["Memories"],
		})
		.input(MemoryIdSchema)
		.output(MemorySchema),
}
