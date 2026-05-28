import { ReflectionsController } from "./reflections.controller"
import type { ReflectionsService } from "./reflections.service"

jest.mock("@repo/db/schema", () => ({ memories: {}, reflections: {} }))
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
		reflection: {
			today: {},
			getByDate: {},
			update: {},
			feedback: {},
		},
	},
}))

jest.mock("@thallesp/nestjs-better-auth", () => ({
	Session: () => () => ({ user: { id: "template-user-id" } }),
}))

const session = { user: { id: "user-1" } }
const id = "11111111-1111-4111-8111-111111111111"

describe("ReflectionsController (v1)", () => {
	let controller: ReflectionsController
	let service: jest.Mocked<
		Pick<ReflectionsService, "today" | "getByDate" | "update" | "feedback">
	>

	beforeEach(() => {
		service = {
			today: jest.fn(),
			getByDate: jest.fn(),
			update: jest.fn(),
			feedback: jest.fn(),
		}
		controller = new ReflectionsController(service as unknown as ReflectionsService)
	})

	it("today delegates with the session user", async () => {
		service.today.mockResolvedValue({ id } as never)
		const handler = await controller.today(session as never)
		await handler({})
		expect(service.today).toHaveBeenCalledWith({ userId: "user-1" })
	})

	it("getByDate delegates date and user", async () => {
		service.getByDate.mockResolvedValue({ id } as never)
		const handler = await controller.getByDate(session as never)
		await handler({ input: { date: "2026-05-28" } })
		expect(service.getByDate).toHaveBeenCalledWith({
			date: "2026-05-28",
			userId: "user-1",
		})
	})

	it("update delegates payload and user", async () => {
		const input = { id, content: "Updated" }
		service.update.mockResolvedValue(input as never)
		const handler = await controller.update(session as never)
		await handler({ input })
		expect(service.update).toHaveBeenCalledWith({ payload: input, userId: "user-1" })
	})

	it("feedback delegates payload and user", async () => {
		const input = { id, feedback: "helpful" }
		service.feedback.mockResolvedValue(input as never)
		const handler = await controller.feedback(session as never)
		await handler({ input })
		expect(service.feedback).toHaveBeenCalledWith({ payload: input, userId: "user-1" })
	})
})
