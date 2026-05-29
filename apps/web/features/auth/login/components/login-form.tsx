"use client"

import Link from "next/link"
import { useForm } from "@tanstack/react-form"

import { Button, buttonVariants } from "@/core/components/ui/button"
import {
	Field,
	FieldDescription,
	FieldError,
	FieldGroup,
	FieldLabel,
} from "@/core/components/ui/field"
import { Input } from "@/core/components/ui/input"
import { cn } from "@/core/lib/utils"
import { PasswordInput } from "@/features/auth/components/password-input"

import { useLoginMutation } from "../api/login.hooks"
import { LoginSchema } from "../api/login.schema"

const memoryTiles = [
	"bg-lifeos-primary-subtle text-lifeos-primary",
	"bg-lifeos-teal-subtle text-lifeos-on-teal",
	"bg-lifeos-amber-subtle text-lifeos-on-amber",
	"bg-lifeos-rose-subtle text-lifeos-on-rose",
]

export function LoginForm({ className, ...props }: React.ComponentProps<"div">) {
	const { mutateAsync: login, isPending, isError, error } = useLoginMutation()

	const form = useForm({
		defaultValues: {
			email: "",
			password: "",
		},
		validators: {
			onSubmit: LoginSchema,
		},
		onSubmit: async ({ value }) => {
			await login(value)
		},
	})

	return (
		<div
			className={cn(
				"mx-auto flex w-full max-w-[22rem] flex-col items-center md:max-w-[24rem] md:-rotate-6",
				className
			)}
			{...props}
		>
			<div className="border-lifeos-border-subtle bg-card text-card-foreground shadow-primary/10 w-full rounded-[2rem] border p-7 shadow-2xl sm:p-9 md:transition-transform md:hover:rotate-3 md:hover:scale-[1.01]">
				<form
					onSubmit={e => {
						e.preventDefault()
						form.handleSubmit()
					}}
				>
					<FieldGroup className="gap-4">
						<div className="flex flex-col items-center pb-1 text-center">
							<h1 className="max-w-56 text-2xl leading-tight font-extrabold">
								Welcome Back to LifeOS
							</h1>
						</div>

						{isError && (
							<div className="bg-destructive/10 text-destructive rounded-2xl px-3 py-2 text-sm">
								{error instanceof Error ? error.message : "An unexpected error occurred"}
							</div>
						)}

						<form.Field
							name="email"
							children={field => {
								const isInvalid = field.state.meta.isTouched && !field.state.meta.isValid
								return (
									<Field data-invalid={isInvalid} className="gap-1">
										<FieldLabel
											htmlFor={field.name}
											className="text-muted-foreground pl-3 text-[0.7rem] font-medium"
										>
											E-mail
										</FieldLabel>
										<Input
											id={field.name}
											name={field.name}
											type="email"
											value={field.state.value}
											onBlur={field.handleBlur}
											onChange={e => field.handleChange(e.target.value)}
											aria-invalid={isInvalid}
											aria-label="Email"
											placeholder="hello@lifeos.ai"
											autoComplete="email"
											required
											disabled={isPending}
											data-element-id="login-email"
											className="border-lifeos-border-subtle bg-card h-11 rounded-full px-5 shadow-sm"
										/>
										{isInvalid && <FieldError errors={field.state.meta.errors} />}
									</Field>
								)
							}}
						/>

						<form.Field
							name="password"
							children={field => {
								const isInvalid = field.state.meta.isTouched && !field.state.meta.isValid
								return (
									<Field data-invalid={isInvalid} className="gap-1">
										<div className="flex items-center">
											<FieldLabel
												htmlFor={field.name}
												className="text-muted-foreground pl-3 text-[0.7rem] font-medium"
											>
												Password
											</FieldLabel>
											<Link
												href="#"
												className={cn(
													buttonVariants({ size: "sm", variant: "link" }),
													"text-muted-foreground hover:text-primary ml-auto h-auto px-0 text-[0.7rem] font-medium no-underline hover:no-underline"
												)}
												data-element-id="forgot-password"
											>
												Forgot password?
											</Link>
										</div>
										<PasswordInput
											id={field.name}
											name={field.name}
											value={field.state.value}
											onBlur={field.handleBlur}
											onChange={e => field.handleChange(e.target.value)}
											aria-invalid={isInvalid}
											required
											autoComplete="current-password"
											disabled={isPending}
											data-element-id="login-password"
											className="[&>input]:border-lifeos-border-subtle [&>input]:bg-card [&>input]:h-11 [&>input]:rounded-full [&>input]:px-5 [&>input]:shadow-sm"
										/>
										{isInvalid && <FieldError errors={field.state.meta.errors} />}
									</Field>
								)
							}}
						/>

						<Field>
							<Button
								type="submit"
								disabled={isPending}
								aria-label="Login"
								className="mt-2 h-12 w-full rounded-full bg-foreground text-sm font-bold text-background shadow-lg shadow-primary/15 hover:bg-foreground/90 hover:cursor-pointer"
								data-element-id="login-submit"
							>
								{isPending ? "Signing in..." : "Log in"}
							</Button>
						</Field>

						<div className="flex justify-center gap-3 py-2" aria-hidden>
							{memoryTiles.map((tile, index) => (
								<div
									key={tile}
									className={cn(
										"border-lifeos-border-subtle flex size-14 items-center justify-center rounded-xl border shadow-sm",
										index % 2 === 0 ? "rotate-[-4deg]" : "rotate-3",
										tile
									)}
								>
									<span className="bg-card/70 size-7 rounded-full" />
								</div>
							))}
						</div>

						<FieldDescription className="text-center">
							New to LifeOS?{" "}
							<Link
								className={cn(
									buttonVariants({ variant: "link" }),
									"text-foreground h-auto px-0 font-semibold underline underline-offset-4"
								)}
								href="/register"
								data-element-id="go-to-register"
							>
								Sign up
							</Link>
						</FieldDescription>
					</FieldGroup>
				</form>
			</div>
		</div>
	)
}
