import { describe, expect, it } from "vitest"

import { CaptureSchema, CreateCaptureSchema } from "./captures.schema"

const capture = {
	id: "11111111-1111-4111-8111-111111111111",
	userId: "user-1",
	type: "text",
	body: "Remember dinner with Sam.",
	audioUrl: null,
	transcript: null,
	transcriptCorrected: false,
	mood: "happy",
	status: "done",
	syncId: "sync-1",
	capturedAt: "2026-05-28T00:00:00.000Z",
	createdAt: "2026-05-28T01:00:00.000Z",
	updatedAt: "2026-05-28T02:00:00.000Z",
}

describe("CaptureSchema", () => {
	it("parses a valid capture and coerces dates", () => {
		const result = CaptureSchema.parse(capture)
		expect(result.capturedAt).toBeInstanceOf(Date)
		expect(result.type).toBe("text")
	})

	it("rejects an invalid type", () => {
		const result = CaptureSchema.safeParse({ ...capture, type: "photo" })
		expect(result.success).toBe(false)
		if (!result.success) {
			expect(result.error.issues[0]!.path).toEqual(["type"])
			expect(result.error.issues[0]!.code).toBe("invalid_value")
		}
	})

	it("rejects a missing required field", () => {
		const result = CaptureSchema.safeParse({ ...capture, status: undefined })
		expect(result.success).toBe(false)
		if (!result.success) {
			expect(result.error.issues[0]!.path).toEqual(["status"])
			expect(result.error.issues[0]!.code).toBe("invalid_value")
		}
	})
})

describe("CreateCaptureSchema", () => {
	it("parses a text capture with optional mood and syncId", () => {
		const result = CreateCaptureSchema.parse({
			type: "text",
			body: "A new note",
			mood: "calm",
			syncId: "same-sync-id",
			capturedAt: "2026-05-28T00:00:00.000Z",
		})
		expect(result.syncId).toBe("same-sync-id")
		expect(result.capturedAt).toBeInstanceOf(Date)
	})

	it("parses a voice capture with audioUrl", () => {
		const result = CreateCaptureSchema.parse({
			type: "voice",
			audioUrl: "https://example.com/audio.m4a",
		})
		expect(result.audioUrl).toBe("https://example.com/audio.m4a")
	})

	it("rejects an empty text body", () => {
		const result = CreateCaptureSchema.safeParse({ type: "text", body: "" })
		expect(result.success).toBe(false)
		if (!result.success) {
			expect(result.error.issues[0]!.path).toEqual(["body"])
			expect(result.error.issues[0]!.code).toBe("too_small")
		}
	})

	it("rejects a text capture without body", () => {
		const result = CreateCaptureSchema.safeParse({ type: "text" })
		expect(result.success).toBe(false)
		if (!result.success) {
			expect(result.error.issues[0]!.path).toEqual([])
			expect(result.error.issues[0]!.code).toBe("custom")
		}
	})

	it("rejects an invalid audioUrl", () => {
		const result = CreateCaptureSchema.safeParse({ type: "voice", audioUrl: "nope" })
		expect(result.success).toBe(false)
		if (!result.success) {
			expect(result.error.issues[0]!.path).toEqual(["audioUrl"])
			expect(result.error.issues[0]!.code).toBe("invalid_format")
		}
	})
})
