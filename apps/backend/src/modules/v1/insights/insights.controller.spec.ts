import { InsightsController } from "./insights.controller"
import type { InsightsService } from "./insights.service"

jest.mock("@repo/db/schema", () => ({ insights: {}, memories: {} }))
jest.mock("@/common/ai/ai.service", () => ({ AiService: jest.fn() }))
jest.mock("@/common/settings/user-settings", () => ({ getEffectiveSettings: jest.fn() }))
jest.mock("@/common/database/database.client", () => ({ db: {} }))

jest.mock("@orpc/nest", () => ({
	Implement: () => () => undefined,
}))

jest.mock("@orpc/server", () => ({
	implement: jest.fn(() => ({
		handler: jest.fn((fn: unknown) => fn),
	})),
}))

jest.mock("@/config/api-versions.config", () => ({
	v1: {
		insight: {
			list: {},
			generate: {},
			save: {},
			dismiss: {},
			feedback: {},
		},
	},
}))

jest.mock("@thallesp/nestjs-better-auth", () => ({
	Session: () => () => ({ user: { id: "template-user-id" } }),
}))

const session = { user: { id: "user-1" } }
const id = "11111111-1111-4111-8111-111111111111"

describe("InsightsController (v1)", () => {
	let controller: InsightsController
	let service: jest.Mocked<
		Pick<InsightsService, "list" | "generate" | "save" | "dismiss" | "feedback">
	>

	beforeEach(() => {
		service = {
			list: jest.fn(),
			generate: jest.fn(),
			save: jest.fn(),
			dismiss: jest.fn(),
			feedback: jest.fn(),
		}
		controller = new InsightsController(service as unknown as InsightsService)
	})

	it("list delegates with the session user", async () => {
		service.list.mockResolvedValue([] as never)
		const handler = await controller.list(session as never)
		await expect(handler({})).resolves.toEqual([])
		expect(service.list).toHaveBeenCalledWith({ userId: "user-1" })
	})

	it("generate delegates with the session user", async () => {
		service.generate.mockResolvedValue([] as never)
		const handler = await controller.generate(session as never)
		await expect(handler({})).resolves.toEqual([])
		expect(service.generate).toHaveBeenCalledWith({ userId: "user-1" })
	})

	it("save delegates input and user", async () => {
		service.save.mockResolvedValue({ id } as never)
		const handler = await controller.save(session as never)
		await handler({ input: { id } })
		expect(service.save).toHaveBeenCalledWith({ payload: { id }, userId: "user-1" })
	})

	it("dismiss delegates input and user", async () => {
		service.dismiss.mockResolvedValue({ id } as never)
		const handler = await controller.dismiss(session as never)
		await handler({ input: { id } })
		expect(service.dismiss).toHaveBeenCalledWith({ payload: { id }, userId: "user-1" })
	})

	it("feedback delegates input and user", async () => {
		const input = { id, feedback: "helpful" }
		service.feedback.mockResolvedValue(input as never)
		const handler = await controller.feedback(session as never)
		await handler({ input })
		expect(service.feedback).toHaveBeenCalledWith({ payload: input, userId: "user-1" })
	})
})
