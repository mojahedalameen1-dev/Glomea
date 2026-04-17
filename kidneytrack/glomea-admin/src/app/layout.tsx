import type { Metadata } from "next";
import { IBM_Plex_Sans_Arabic, Inter } from "next/font/google";
import { Providers } from "@/components/providers/theme-provider"
import { LanguageProvider } from "@/components/providers/language-provider"
import { Toaster } from "sonner"
import "./globals.css"
import { cookies } from "next/headers"

const arabic = IBM_Plex_Sans_Arabic({ 
  subsets: ["arabic"], 
  weight: ["300", "400", "500", "600", "700"],
  variable: "--font-ibm",
})

const english = Inter({ 
  subsets: ["latin"],
  weight: ["300", "400", "500", "600", "700"],
  variable: "--font-inter",
})

export const metadata: Metadata = {
  title: "Glomea Admin | لوميا إدمن",
  description: "Advanced health data management system for kidney care",
}

export default async function RootLayout({
  children,
}: Readonly<{
  children: React.ReactNode;
}>) {
  const cookieStore = await cookies()
  const lang = cookieStore.get('glomea-lang')?.value || 'en'

  return (
    <html lang={lang} dir={lang === 'ar' ? 'rtl' : 'ltr'} suppressHydrationWarning
      className={`${arabic.variable} ${english.variable} ${lang === 'ar' ? 'font-ibm' : 'font-inter'}`}>
      <body className={`antialiased font-sans bg-background text-foreground`}>
        <LanguageProvider>
          <Providers>
            {children}
            <Toaster position="top-center" richColors />
          </Providers>
        </LanguageProvider>
      </body>
    </html>
  )
}
