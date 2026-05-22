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
	FieldSeparator,
} from "@/core/components/ui/field"
import { Input } from "@/core/components/ui/input"
import { cn } from "@/core/lib/utils"
import { PasswordInput } from "@/features/auth/components/password-input"
import { SocialLoginButtons } from "@/features/auth/components/social-login-buttons"
import { TermsPrivacyNote } from "@/features/auth/components/terms-privacy-note"

import { useLoginMutation } from "../api/login.hooks"
import { LoginSchema } from "../api/login.schema"

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
			className={cn("mx-auto flex w-full max-w-md flex-col items-center gap-5", className)}
			{...props}
		>
			<div className="border-border bg-card text-card-foreground shadow-primary/5 w-full rounded-[2rem] border p-10 shadow-xl">
				<form
					onSubmit={e => {
						e.preventDefault()
						form.handleSubmit()
					}}
				>
					<FieldGroup className="gap-6">
						<div className="flex flex-col items-center gap-1 text-center">
							<h1 className="text-2xl font-extrabold tracking-tight">Welcome back</h1>
							<p className="text-muted-foreground text-sm">Sign in to your LifeOS AI account</p>
						</div>

						{isError && (
							<div className="bg-destructive/10 text-destructive rounded-2xl p-3 text-sm">
								{error instanceof Error ? error.message : "An unexpected error occurred"}
							</div>
						)}

						<form.Field
							name="email"
							children={field => {
								const isInvalid = field.state.meta.isTouched && !field.state.meta.isValid
								return (
									<Field data-invalid={isInvalid}>
										<FieldLabel htmlFor={field.name}>Email address</FieldLabel>
										<Input
											id={field.name}
											name={field.name}
											type="email"
											value={field.state.value}
											onBlur={field.handleBlur}
											onChange={e => field.handleChange(e.target.value)}
											aria-invalid={isInvalid}
											placeholder="you@example.com"
											autoComplete="email"
											required
											disabled={isPending}
											data-element-id="login-email"
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
									<Field data-invalid={isInvalid}>
										<div className="flex items-center">
											<FieldLabel htmlFor={field.name}>Password</FieldLabel>
											<Link
												href="#"
												className={cn(
													buttonVariants({ size: "sm", variant: "link" }),
													"text-primary ml-auto h-auto font-medium"
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
								className="h-12 w-full rounded-full text-sm font-bold hover:cursor-pointer"
								data-element-id="login-submit"
							>
								{isPending ? "Signing in..." : "Sign in"}
							</Button>
						</Field>

						<FieldSeparator className="*:data-[slot=field-separator-content]:bg-card">
							or continue with
						</FieldSeparator>

						<SocialLoginButtons action="login" />

						<FieldDescription className="text-center">
							Don&apos;t have an account?{" "}
							<Link
								className={cn(
									buttonVariants({ variant: "link" }),
									"text-primary h-auto px-0 font-semibold"
								)}
								href="/register"
								data-element-id="go-to-register"
							>
								Create one
							</Link>
						</FieldDescription>
					</FieldGroup>
				</form>
			</div>
			<TermsPrivacyNote />
		</div>
	)
}
