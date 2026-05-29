type LifeOSMarkProps = {
	className?: string
	title?: string
}

export function LifeOSMark({ className, title = "LifeOS" }: LifeOSMarkProps) {
	return (
		<svg viewBox="0 0 120 120" className={className} role="img" aria-label={title}>
			<path
				d="M110 60 A50 50 0 1 1 60 10"
				fill="none"
				stroke="var(--lifeos-accent-primary)"
				strokeLinecap="round"
				strokeWidth="3.5"
			/>
			<circle cx="60" cy="10" r="4.5" fill="var(--lifeos-accent-teal)" />
			<circle cx="110" cy="60" r="3" fill="var(--lifeos-accent-primary)" />
			<path
				d="M89.94 68.02 A31 31 0 1 1 33.2 36.25"
				fill="none"
				stroke="var(--lifeos-accent-teal)"
				strokeLinecap="round"
				strokeWidth="2.5"
			/>
			<circle cx="33.2" cy="36.25" r="3.5" fill="var(--lifeos-accent-amber)" />
			<path
				d="M76.78 68.91 A19 19 0 0 1 41.94 60"
				fill="none"
				stroke="var(--lifeos-accent-amber)"
				strokeLinecap="round"
				strokeWidth="2"
			/>
			<circle cx="41.94" cy="60" r="3" fill="var(--lifeos-accent-teal)" />
			<circle cx="60" cy="60" r="5.5" fill="var(--lifeos-accent-primary)" />
		</svg>
	)
}
