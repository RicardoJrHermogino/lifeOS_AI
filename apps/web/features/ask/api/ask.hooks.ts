"use client"

import { useMutation } from "@tanstack/react-query"

import { apiClient } from "@/services/api/client"

export type AskResult = {
	answer: string
	citations: Array<{ memoryId: string; title: string }>
}

export function useAsk() {
	return useMutation({
		mutationFn: (question: string) =>
			apiClient.post<AskResult>("/ask", { question }),
	})
}

export type SearchResult = {
	memory: {
		id: string
		title: string
		summary: string
		eventDate: string
	}
	score: number
}

export function useSearch() {
	return useMutation({
		mutationFn: (query: string) =>
			apiClient.post<{ results: SearchResult[] }>("/search", { query }),
	})
}
