import { describe, expect, it } from "vitest"

import { DataExportSchema, ExportIdSchema, ExportStatusSchema } from "./exports.schema"

const dataExport = {
	id: "11111111-1111-4111-8111-111111111111",
	userId: "user-1",
	status: "ready",
	downloadUrl: "https://example.com/export.zip",
	expiresAt: "2026-05-29T00:00:00.000Z",
	createdAt: "2026-05-28T00:00:00.000Z",
}

describe("ExportStatusSchema", () => {
	it("parses valid statuses", () => {
		expect(ExportStatusSchema.parse("pending")).toBe("pending")
		expect(ExportStatusSchema.parse("ready")).toBe("ready")
		expect(ExportStatusSchema.parse("failed")).toBe("failed")
	})

	it("rejects invalid status", () => {
		const result = ExportStatusSchema.safeParse("done")
		expect(result.success).toBe(false)
		if (!result.success) {
			expect(result.error.issues[0]!.path).toEqual([])
			expect(result.error.issues[0]!.code).toBe("invalid_value")
		}
	})
})

describe("DataExportSchema", () => {
	it("parses a ready export and coerces dates", () => {
		const result = DataExportSchema.parse(dataExport)
		expect(result.expiresAt).toBeInstanceOf(Date)
		expect(result.createdAt).toBeInstanceOf(Date)
	})

	it("accepts nullable downloadUrl and expiresAt", () => {
		const result = DataExportSchema.parse({
			...dataExport,
			status: "pending",
			downloadUrl: null,
			expiresAt: null,
		})
		expect(result.downloadUrl).toBeNull()
		expect(result.expiresAt).toBeNull()
	})

	it("rejects a missing status", () => {
		const result = DataExportSchema.safeParse({ ...dataExport, status: undefined })
		expect(result.success).toBe(false)
		if (!result.success) {
			expect(result.error.issues[0]!.path).toEqual(["status"])
			expect(result.error.issues[0]!.code).toBe("invalid_value")
		}
	})
})

describe("ExportIdSchema", () => {
	it("parses a valid id", () => {
		const result = ExportIdSchema.parse({ id: dataExport.id })
		expect(result.id).toBe(dataExport.id)
	})

	it("rejects an invalid id", () => {
		const result = ExportIdSchema.safeParse({ id: "bad-id" })
		expect(result.success).toBe(false)
		if (!result.success) {
			expect(result.error.issues[0]!.path).toEqual(["id"])
			expect(result.error.issues[0]!.code).toBe("invalid_format")
		}
	})
})
