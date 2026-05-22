export default function HomeLayout({
	children,
}: Readonly<{
	children: React.ReactNode
}>) {
	return <div className="bg-background text-foreground min-h-screen">{children}</div>
}
