"use client"

import { useQuery } from "@tanstack/react-query"

import { apiClient } from "@/services/api/client"

import type { Memory } from "@/features/memories/api/memories.hooks"

export type TimelineGroup = {
	date: string
	memories: Memory[]
}

export type TimelineFilters = {
	mood?: string
	person?: string
	topic?: string
	from?: string
	to?: string
	cursor?: string
	limit?: number
}

export const timelineKeys = {
	all: ["timeline"] as const,
	list: (filters: TimelineFilters) => ["timeline", filters] as const,
}

function buildQuery(filters: TimelineFilters): string {
	const sp = new URLSearchParams()
	for (const [k, v] of Object.entries(filters)) {
		if (v !== undefined && v !== "") sp.set(k, String(v))
	}
	const s = sp.toString()
	return s ? `?${s}` : ""
}

export function useTimeline(filters: TimelineFilters = {}) {
	return useQuery({
		queryKey: timelineKeys.list(filters),
		queryFn: () =>
			apiClient.get<{ groups: TimelineGroup[]; nextCursor: string | null }>(
				`/timeline${buildQuery(filters)}`
			),
	})
}
