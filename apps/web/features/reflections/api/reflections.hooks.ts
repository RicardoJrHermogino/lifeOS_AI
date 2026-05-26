"use client"

import { useMutation, useQuery, useQueryClient } from "@tanstack/react-query"

import { apiClient } from "@/services/api/client"

export type Reflection = {
	id: string
	userId: string
	date: string
	content: string
	sourceMemoryIds: string[]
	isUserEdited: boolean
	feedback: "helpful" | "inaccurate" | null
	createdAt: string
	updatedAt: string
}

export const reflectionKeys = {
	all: ["reflections"] as const,
	byDate: (date: string) => ["reflections", date] as const,
}

export function useReflection(date: string) {
	return useQuery({
		queryKey: reflectionKeys.byDate(date),
		queryFn: () => apiClient.get<Reflection>(`/reflections/${date}`),
	})
}

export function useReflectionFeedback() {
	const qc = useQueryClient()
	return useMutation({
		mutationFn: ({ id, feedback }: { id: string; feedback: "helpful" | "inaccurate" }) =>
			apiClient.post<Reflection>(`/reflections/${id}/feedback`, { feedback }),
		onSuccess: () => {
			qc.invalidateQueries({ queryKey: reflectionKeys.all })
		},
	})
}
