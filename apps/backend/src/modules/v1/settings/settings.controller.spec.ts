import { SettingsController } from "./settings.controller"
import type { SettingsService } from "./settings.service"

jest.mock("@repo/db/schema", () => ({ userSettings: {} }))

jest.mock("@orpc/nest", () => ({
	Implement: () => () => undefined,
}))

jest.mock("@orpc/server", () => ({
	implement: jest.fn(() => ({
		handler: jest.fn((fn: unknown) => fn),
	})),
}))

jest.mock("@/config/api-versions.config", () => ({
	v1: { settings: { get: {}, update: {} } },
}))

jest.mock("@thallesp/nestjs-better-auth", () => ({
	Session: () => () => ({ user: { id: "template-user-id" } }),
}))

jest.mock("@/common/database/database.client", () => ({ db: {} }))

const session = { user: { id: "user-1" } }

describe("SettingsController (v1)", () => {
	let controller: SettingsController
	let service: jest.Mocked<Pick<SettingsService, "getOrCreate" | "update">>

	beforeEach(() => {
		service = {
			getOrCreate: jest.fn(),
			update: jest.fn(),
		}
		controller = new SettingsController(service as unknown as SettingsService)
	})

	it("get returns defaults from the service when no row exists", async () => {
		const settings = { userId: "user-1", reflectionTone: "warm" }
		service.getOrCreate.mockResolvedValue(settings as never)

		const handler = await controller.get(session as never)
		const result = await handler({})

		expect(result).toBe(settings)
		expect(service.getOrCreate).toHaveBeenCalledWith({ userId: "user-1" })
	})

	it("update merges a partial patch through the service", async () => {
		const settings = { userId: "user-1", proactiveInsights: false }
		service.update.mockResolvedValue(settings as never)

		const handler = await controller.update(session as never)
		const result = await handler({ input: { proactiveInsights: false } })

		expect(result).toBe(settings)
		expect(service.update).toHaveBeenCalledWith({
			payload: { proactiveInsights: false },
			userId: "user-1",
		})
	})
})
