import { Controller, Post, Req, UploadedFile, UseInterceptors, Version } from "@nestjs/common"
import { FileInterceptor } from "@nestjs/platform-express"
import { Implement } from "@orpc/nest"
import { implement } from "@orpc/server"
import { Session, type UserSession } from "@thallesp/nestjs-better-auth"
import type { Request } from "express"

import { v1 } from "@/config/api-versions.config"
import { env } from "@/config/env.config"

import { CapturesService } from "./captures.service"

@Controller()
export class CapturesController {
	constructor(private readonly capturesService: CapturesService) {}

	@Post("captures/audio")
	@Version("1")
	@UseInterceptors(FileInterceptor("file"))
	async uploadAudio(
		@Session() session: UserSession,
		@UploadedFile()
		file:
			| {
					buffer: Buffer
					originalname: string
					mimetype: string
					size: number
			  }
			| undefined,
		@Req() request: Request
	) {
		const protocol = request.protocol
		const requestHost = request.get("host") ?? `127.0.0.1:${env.PORT}`
		const host = requestHost.startsWith("10.0.2.2")
			? `127.0.0.1:${env.PORT}`
			: requestHost
		const baseUrl = `${protocol}://${host}`
		return this.capturesService.saveAudioUpload({
			file,
			userId: session.user.id,
			baseUrl,
		})
	}

	@Implement(v1.capture.create)
	async createCapture(@Session() session: UserSession) {
		return implement(v1.capture.create).handler(async ({ input }) => {
			return this.capturesService.create({ payload: input, userId: session.user.id })
		})
	}

	@Implement(v1.capture.get)
	async getCapture(@Session() session: UserSession) {
		return implement(v1.capture.get).handler(async ({ input }) => {
			return this.capturesService.findOne({ id: input.id, userId: session.user.id })
		})
	}

	@Implement(v1.capture.patchTranscript)
	async patchTranscript(@Session() session: UserSession) {
		return implement(v1.capture.patchTranscript).handler(async ({ input }) => {
			return this.capturesService.patchTranscript({
				payload: input,
				userId: session.user.id,
			})
		})
	}
}
