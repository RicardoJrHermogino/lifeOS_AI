import { oc } from "@orpc/contract"

import { captureContract } from "./captures/captures.contract.js"
import { v1Example } from "./examples/v1.example.js"
import { exportContract } from "./exports/exports.contract.js"
import { healthContract } from "./health/health.contract.js"
import { insightContract } from "./insights/insights.contract.js"
import { memoryContract } from "./memories/memories.contract.js"
import { reflectionContract } from "./reflections/reflections.contract.js"
import { searchContract } from "./search/search.contract.js"
import { settingsContract } from "./settings/settings.contract.js"
import { ticketContract } from "./tickets/tickets.contract.js"
import { timelineContract } from "./timeline/timeline.contract.js"

/**
 * V1 contract router (versioned paths: /v1/todos, /v1/health, /v1/tickets, /v1/captures, ...)
 * Assembles all v1 feature contracts and applies the /v1 prefix
 */
export const v1Contract = oc.prefix("/v1").router(
	oc.router({
		health: healthContract,
		example: v1Example,
		ticket: ticketContract,
		capture: captureContract,
		memory: memoryContract,
		timeline: timelineContract,
		search: searchContract,
		reflection: reflectionContract,
		export: exportContract,
		settings: settingsContract,
		insight: insightContract,
	})
)

export type V1Contract = typeof v1Contract
