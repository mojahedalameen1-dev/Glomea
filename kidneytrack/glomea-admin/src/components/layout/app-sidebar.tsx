"use client"

import { usePathname, useRouter } from "next/navigation"
import Link from "next/link"
import { 
  LayoutDashboard, 
  Users, 
  UserRound, 
  BarChart3, 
  Bell, 
  Settings, 
  LogOut,
  SlidersHorizontal,
  History
} from "lucide-react"
import { useLanguage } from "@/hooks/use-language"
import { cn } from "@/lib/utils"
import { useAdmin } from "@/components/providers/admin-provider"

export function AppSidebar() {
  const pathname = usePathname()
  const router = useRouter()
  const { tr, isRTL } = useLanguage()
  const { admin, signOut } = useAdmin()

  const handleSignOut = async () => {
    await signOut()
    router.refresh()
    router.push('/login')
  }

  const menuItems = [
    { icon: LayoutDashboard, label: tr.dashboard, href: "/dashboard" },
    { icon: Users, label: tr.patients, href: "/dashboard/patients" },
    { icon: UserRound, label: tr.staff, href: "/dashboard/staff" },
    { icon: BarChart3, label: tr.analytics, href: "/dashboard/analytics" },
    { icon: SlidersHorizontal, label: tr.thresholds, href: "/dashboard/thresholds" },
    { icon: Bell, label: tr.notifications, href: "/dashboard/notifications" },
    { icon: History, label: tr.activityLog, href: "/dashboard/activity-log" },
    { icon: Settings, label: tr.settings, href: "/dashboard/settings" },
  ]

  return (
    <aside className="fixed top-0 bottom-0 start-0 w-60 border-e border-border bg-card transition-all duration-300 z-50 flex flex-col">
      {/* Logo */}
      <div className="p-6 flex items-center gap-3">
        <div className="w-8 h-8 bg-primary rounded-lg flex items-center justify-center">
          <div className="w-4 h-4 bg-white rounded-full opacity-80" />
        </div>
        <span className="text-xl font-bold text-foreground">Glomea</span>
      </div>


      {/* Navigation */}
      <nav className="flex-1 px-4 space-y-1 overflow-y-auto custom-scrollbar">
        {menuItems.map((item) => {
          const isActive = pathname === item.href
          return (
            <Link 
              key={item.href} 
              href={item.href}
              className={cn(
                "flex items-center gap-3 px-3 py-3 rounded-xl transition-all group relative",
                isActive 
                  ? "bg-primary/10 text-primary" 
                  : "text-muted-foreground hover:bg-muted hover:text-foreground"
              )}
            >
              <item.icon className={cn(
                "w-5 h-5",
                isActive ? "text-primary" : "text-muted-foreground group-hover:text-foreground"
              )} />
              <span className="font-medium">{item.label}</span>
              {isActive && (
                <div className="absolute w-1 h-6 bg-primary rounded-full end-1" />
              )}
            </Link>
          )
        })}
      </nav>

      {/* Footer / Admin Info */}
      <div className="p-4 border-t border-border space-y-2">
        <div className="p-4 rounded-2xl bg-muted/30 border border-border flex items-center gap-3">
          <div className="w-10 h-10 rounded-full bg-primary flex items-center justify-center text-white font-black text-sm shadow-lg shadow-primary/20">
            {admin?.fullName?.charAt(0) || "A"}
          </div>
          <div className="flex-1 min-w-0">
            <p className="text-sm font-bold text-foreground truncate">
              {admin?.fullName || "Admin"}
            </p>
            <p className="text-[10px] font-black text-primary uppercase tracking-widest leading-none mt-1">
              {admin?.isSuperAdmin ? "Super Admin" : "System Admin"}
            </p>
          </div>
        </div>

        <button 
          onClick={handleSignOut}
          className="flex items-center gap-3 w-full px-3 py-3.5 text-muted-foreground hover:text-destructive hover:bg-destructive/10 rounded-xl transition-all font-bold text-sm"
        >
          <LogOut className="w-5 h-5" />
          <span>{tr.signOut}</span>
        </button>
      </div>
    </aside>
  )
}
