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

import { useRegisterMutation } from "../api/register.hooks"
import { RegisterSchema } from "../api/register.schema"

export function RegisterForm({ className, ...props }: React.ComponentProps<"div">) {
	const { mutateAsync: register, isPending, isError, error } = useRegisterMutation()

	const form = useForm({
		defaultValues: {
			email: "",
			password: "",
			name: "",
		},
		validators: {
			onSubmit: RegisterSchema,
		},
		onSubmit: async ({ value }) => {
			await register(value)
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
					<FieldGroup className="gap-5">
						<div className="flex flex-col items-center gap-1 text-center">
							<h1 className="text-2xl font-extrabold tracking-tight">Create your account</h1>
							<p className="text-muted-foreground text-sm">
								Start building your personal memory layer
							</p>
						</div>

						<div className="bg-primary/15 border-primary/30 rounded-2xl border p-4">
							<p className="text-foreground/80 text-xs leading-relaxed">
								<strong className="text-foreground font-bold">Your data is yours.</strong> LifeOS AI
								stores your memories privately. You can edit, export, or delete everything at any
								time. AI-generated content is always reviewable.
							</p>
						</div>

						{isError && (
							<div className="bg-destructive/10 text-destructive rounded-2xl p-3 text-sm">
								{error instanceof Error ? error.message : "An unexpected error occurred"}
							</div>
						)}

						<form.Field
							name="name"
							children={field => {
								const isInvalid = field.state.meta.isTouched && !field.state.meta.isValid
								return (
									<Field data-invalid={isInvalid}>
										<FieldLabel htmlFor={field.name}>Full name</FieldLabel>
										<Input
											id={field.name}
											name={field.name}
											type="text"
											value={field.state.value || ""}
											onBlur={field.handleBlur}
											onChange={e => field.handleChange(e.target.value)}
											aria-invalid={isInvalid}
											placeholder="Jane Doe"
											autoComplete="name"
											disabled={isPending}
											data-element-id="register-name"
										/>
										{isInvalid && <FieldError errors={field.state.meta.errors} />}
									</Field>
								)
							}}
						/>

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
											data-element-id="register-email"
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
										<FieldLabel htmlFor={field.name}>Password</FieldLabel>
										<PasswordInput
											id={field.name}
											name={field.name}
											value={field.state.value}
											onBlur={field.handleBlur}
											onChange={e => field.handleChange(e.target.value)}
											aria-invalid={isInvalid}
											required
											autoComplete="new-password"
											disabled={isPending}
											placeholder="Create a strong password"
											data-element-id="register-password"
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
								data-element-id="register-submit"
							>
								{isPending ? "Creating account..." : "Create account"}
							</Button>
						</Field>

						<FieldSeparator className="*:data-[slot=field-separator-content]:bg-card">
							or sign up with
						</FieldSeparator>

						<SocialLoginButtons action="signup" />

						<FieldDescription className="text-center">
							Already have an account?{" "}
							<Link
								className={cn(
									buttonVariants({ variant: "link" }),
									"text-primary h-auto px-0 font-semibold"
								)}
								href="/login"
								data-element-id="go-to-login"
							>
								Sign in
							</Link>
						</FieldDescription>
					</FieldGroup>
				</form>
			</div>
			<TermsPrivacyNote />
		</div>
	)
}
