import { oc } from "@orpc/contract"

import {
	AskInputSchema,
	AskOutputSchema,
	SearchInputSchema,
	SearchOutputSchema,
} from "./search.schema.js"

export const searchContract = {
	/**
	 * Semantic search over a user's memories
	 * POST /search
	 */
	search: oc
		.route({
			method: "POST",
			path: "/search",
			summary: "Semantic search",
			description: "Vector-based kNN search over the user's memories",
			tags: ["Search"],
		})
		.input(SearchInputSchema)
		.output(SearchOutputSchema),

	/**
	 * Conversational retrieval (RAG)
	 * POST /ask
	 */
	ask: oc
		.route({
			method: "POST",
			path: "/ask",
			summary: "Ask question (RAG)",
			description: "Returns a grounded answer with memory citations",
			tags: ["Search"],
		})
		.input(AskInputSchema)
		.output(AskOutputSchema),
}
