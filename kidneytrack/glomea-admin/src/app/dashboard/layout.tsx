"use client"

import { AppSidebar } from "@/components/layout/app-sidebar"
import { TopNav } from "@/components/layout/top-nav"
import { useLanguage } from "@/hooks/use-language"
import { AdminProvider } from "@/components/providers/admin-provider"

export default function DashboardLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  const { isRTL } = useLanguage()

  return (
    <AdminProvider>
      <div className="min-h-screen bg-background text-foreground flex flex-row">
        <AppSidebar />
        <div className="w-60 flex-shrink-0 hidden md:block" />
        
        <div className="flex-1 flex flex-col min-w-0">
          <TopNav />
          <main className="flex-1 p-8 overflow-y-auto">
            <div className="mx-auto max-w-[1600px] w-full animate-in fade-in duration-700">
              {children}
            </div>
          </main>
        </div>
      </div>
    </AdminProvider>
  );
}
