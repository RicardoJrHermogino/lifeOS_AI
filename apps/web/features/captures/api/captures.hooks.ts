"use client"

import { useMutation, useQuery, useQueryClient } from "@tanstack/react-query"

import { apiClient } from "@/services/api/client"

export type Capture = {
	id: string
	userId: string
	type: "voice" | "text"
	body: string | null
	audioUrl: string | null
	transcript: string | null
	transcriptCorrected: boolean
	mood: string | null
	status: "pending" | "transcribing" | "extracting" | "done" | "failed"
	syncId: string | null
	capturedAt: string
	createdAt: string
	updatedAt: string
}

export type CreateCaptureInput = {
	type: "voice" | "text"
	body?: string
	audioUrl?: string
	mood?: string
	syncId?: string
	capturedAt?: string
}

export const captureKeys = {
	all: ["captures"] as const,
	detail: (id: string) => ["captures", id] as const,
}

export function useCreateCapture() {
	const qc = useQueryClient()
	return useMutation({
		mutationFn: (input: CreateCaptureInput) => apiClient.post<Capture>("/captures", input),
		onSuccess: () => {
			qc.invalidateQueries({ queryKey: ["memories", "candidates"] })
			qc.invalidateQueries({ queryKey: captureKeys.all })
		},
	})
}

export function useCapture(id: string | null, opts?: { refetchInterval?: number }) {
	return useQuery({
		queryKey: ["captures", id] as const,
		queryFn: () => {
			if (!id) throw new Error("Capture id is required")
			return apiClient.get<Capture>(`/captures/${id}`)
		},
		enabled: !!id,
		refetchInterval: opts?.refetchInterval ?? false,
	})
}
