import {
	Injectable,
	InternalServerErrorException,
	NotFoundException,
} from "@nestjs/common"
import { and, eq } from "drizzle-orm"

import { dataExports, users } from "@repo/db/schema"

import { db } from "@/common/database/database.client"
import { JobsService } from "@/common/jobs/jobs.service"

@Injectable()
export class ExportsService {
	constructor(private readonly jobs: JobsService) {}

	async request({ userId }: { userId: string }) {
		const [row] = await db
			.insert(dataExports)
			.values({ userId, status: "pending" })
			.returning()
		if (!row) throw new InternalServerErrorException("Export not created")

		await this.jobs.enqueue("export", { exportId: row.id, userId })
		return row
	}

	async get({ id, userId }: { id: string; userId: string }) {
		const [row] = await db
			.select()
			.from(dataExports)
			.where(and(eq(dataExports.id, id), eq(dataExports.userId, userId)))
		if (!row) throw new NotFoundException(`Export ${id} not found`)
		return row
	}

	/**
	 * Hard-delete the user. ON DELETE CASCADE wipes captures, memories,
	 * reflections, exports, sessions, and accounts (spec §10).
	 */
	async deleteAccount({ userId }: { userId: string }) {
		const result = await db.delete(users).where(eq(users.id, userId))
		// Drizzle returns a result object — treat any successful return as success.
		return { success: !!result }
	}
}
