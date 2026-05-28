import { MemoriesController } from "./memories.controller"
import type { MemoriesService } from "./memories.service"

jest.mock("@repo/db/schema", () => ({ memories: {} }))
jest.mock("@/common/ai/ai.service", () => ({ AiService: jest.fn() }))
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
		memory: {
			listCandidates: {},
			get: {},
			update: {},
			delete: {},
			archive: {},
			restore: {},
			related: {},
		},
	},
}))

jest.mock("@thallesp/nestjs-better-auth", () => ({
	Session: () => () => ({ user: { id: "template-user-id" } }),
}))

const session = { user: { id: "user-1" } }
const id = "11111111-1111-4111-8111-111111111111"

describe("MemoriesController (v1)", () => {
	let controller: MemoriesController
	let service: jest.Mocked<
		Pick<MemoriesService, "listCandidates" | "findOne" | "update" | "softDelete">
	>

	beforeEach(() => {
		service = {
			listCandidates: jest.fn(),
			findOne: jest.fn(),
			update: jest.fn(),
			softDelete: jest.fn(),
		}
		controller = new MemoriesController(service as unknown as MemoriesService)
	})

	it("listCandidates delegates query and user", async () => {
		service.listCandidates.mockResolvedValue({ items: [], nextCursor: null } as never)
		const handler = await controller.listCandidates(session as never)
		await handler({ input: { limit: 10 } })
		expect(service.listCandidates).toHaveBeenCalledWith({
			query: { limit: 10 },
			userId: "user-1",
		})
	})

	it("getMemory delegates id and user", async () => {
		service.findOne.mockResolvedValue({ id } as never)
		const handler = await controller.getMemory(session as never)
		await handler({ input: { id } })
		expect(service.findOne).toHaveBeenCalledWith({ id, userId: "user-1" })
	})

	it("updateMemory delegates payload and user", async () => {
		const input = { id, title: "Updated" }
		service.update.mockResolvedValue(input as never)
		const handler = await controller.updateMemory(session as never)
		await handler({ input })
		expect(service.update).toHaveBeenCalledWith({ payload: input, userId: "user-1" })
	})

	it("deleteMemory delegates id and user", async () => {
		service.softDelete.mockResolvedValue({ success: true, id } as never)
		const handler = await controller.deleteMemory(session as never)
		await handler({ input: { id } })
		expect(service.softDelete).toHaveBeenCalledWith({ id, userId: "user-1" })
	})
})
