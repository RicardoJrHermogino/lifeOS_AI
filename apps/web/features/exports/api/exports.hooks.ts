"use client"

import { useMutation, useQuery } from "@tanstack/react-query"

import { apiClient } from "@/services/api/client"

export type DataExport = {
	id: string
	userId: string
	status: "pending" | "ready" | "failed"
	downloadUrl: string | null
	expiresAt: string | null
	createdAt: string
}

export function useRequestExport() {
	return useMutation({
		mutationFn: () => apiClient.post<DataExport>("/exports"),
	})
}

export function useExport(id: string | null) {
	return useQuery({
		queryKey: ["exports", id],
		queryFn: () => apiClient.get<DataExport>(`/exports/${id}`),
		enabled: !!id,
		refetchInterval: query => {
			const status = (query.state.data as DataExport | undefined)?.status
			return status === "pending" ? 2000 : false
		},
	})
}

export function useDeleteAccount() {
	return useMutation({
		mutationFn: () => apiClient.delete<{ success: boolean }>("/account"),
	})
}
