"use client"

import { getApiUrl } from "@/core/lib/utils"

export type ApiError = Error & { status?: number; data?: unknown }

async function request<T>(path: string, init?: RequestInit): Promise<T> {
	const res = await fetch(`${getApiUrl()}${path}`, {
		credentials: "include",
		headers: {
			"Content-Type": "application/json",
			...(init?.headers ?? {}),
		},
		...init,
	})
	if (!res.ok) {
		let data: unknown = null
		try {
			data = await res.json()
		} catch {
			// ignore
		}
		const message =
			(data as { message?: string } | null)?.message ?? `Request failed (${res.status})`
		const err: ApiError = Object.assign(new Error(message), {
			status: res.status,
			data,
		})
		throw err
	}
	if (res.status === 204) return undefined as T
	return (await res.json()) as T
}

export const apiClient = {
	get: <T>(path: string) => request<T>(path, { method: "GET" }),
	post: <T>(path: string, body?: unknown) =>
		request<T>(path, { method: "POST", body: JSON.stringify(body ?? {}) }),
	patch: <T>(path: string, body?: unknown) =>
		request<T>(path, { method: "PATCH", body: JSON.stringify(body ?? {}) }),
	delete: <T>(path: string) => request<T>(path, { method: "DELETE" }),
}
