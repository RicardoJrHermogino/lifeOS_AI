"use client"

import { useMutation, useQuery, useQueryClient } from "@tanstack/react-query"

import { apiClient } from "@/services/api/client"

export type Memory = {
	id: string
	userId: string
	rawCaptureId: string | null
	title: string
	summary: string
	eventDate: string
	emotions: string[]
	people: string[]
	places: string[]
	topics: string[]
	goals: string[]
	decisions: string[]
	actions: string[]
	sensitivity: string | null
	confidence: Record<string, number>
	status: "candidate" | "saved" | "archived" | "deleted"
	isUserCorrected: boolean
	createdAt: string
	updatedAt: string
}

export type UpdateMemoryInput = Partial<
	Pick<
		Memory,
		| "title"
		| "summary"
		| "eventDate"
		| "emotions"
		| "people"
		| "places"
		| "topics"
		| "goals"
		| "decisions"
		| "actions"
		| "sensitivity"
	>
> & { id: string }

export const memoryKeys = {
	all: ["memories"] as const,
	candidates: ["memories", "candidates"] as const,
	detail: (id: string) => ["memories", id] as const,
}

export function useMemoryCandidates() {
	return useQuery({
		queryKey: memoryKeys.candidates,
		queryFn: () =>
			apiClient.get<{ items: Memory[]; nextCursor: string | null }>("/memories/candidates"),
	})
}

export function useMemory(id: string | null) {
	return useQuery({
		queryKey: ["memories", id] as const,
		queryFn: () => {
			if (!id) throw new Error("Memory id is required")
			return apiClient.get<Memory>(`/memories/${id}`)
		},
		enabled: !!id,
	})
}

export function useUpdateMemory() {
	const qc = useQueryClient()
	return useMutation({
		mutationFn: (input: UpdateMemoryInput) =>
			apiClient.patch<Memory>(`/memories/${input.id}`, input),
		onSuccess: () => {
			qc.invalidateQueries({ queryKey: memoryKeys.all })
		},
	})
}

export function useDeleteMemory() {
	const qc = useQueryClient()
	return useMutation({
		mutationFn: (id: string) => apiClient.delete<{ success: boolean }>(`/memories/${id}`),
		onSuccess: () => {
			qc.invalidateQueries({ queryKey: memoryKeys.all })
		},
	})
}

export function useArchiveMemory() {
	const qc = useQueryClient()
	return useMutation({
		mutationFn: (id: string) => apiClient.patch<Memory>(`/memories/${id}/archive`),
		onSuccess: () => {
			qc.invalidateQueries({ queryKey: memoryKeys.all })
		},
	})
}

export function useRestoreMemory() {
	const qc = useQueryClient()
	return useMutation({
		mutationFn: (id: string) => apiClient.patch<Memory>(`/memories/${id}/restore`),
		onSuccess: () => {
			qc.invalidateQueries({ queryKey: memoryKeys.all })
		},
	})
}
