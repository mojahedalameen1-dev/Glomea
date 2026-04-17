"use client"

import Link from "next/link"
import { usePathname } from "next/navigation"
import { cn } from "@/lib/utils"
import { 
  LayoutDashboard, 
  Users, 
  UserCog, 
  BarChart3, 
  Settings, 
  Bell, 
  LogOut,
  Activity
} from "lucide-react"
import { createClient } from "@/lib/supabase/client"

const navItems = [
  {
    title: "لوحة التحكم",
    href: "/dashboard",
    icon: LayoutDashboard,
  },
  {
    title: "إدارة المرضى",
    href: "/dashboard/patients",
    icon: Users,
  },
  {
    title: "إدارة الطاقم",
    href: "/dashboard/staff",
    icon: UserCog,
  },
  {
    title: "التحليلات",
    href: "/dashboard/analytics",
    icon: BarChart3,
  },
  {
    title: "تنبيهات العتبة",
    href: "/dashboard/thresholds",
    icon: Activity,
  },
  {
    title: "مركز التنبيهات",
    href: "/dashboard/notifications",
    icon: Bell,
  },
  {
    title: "الإعدادات",
    href: "/dashboard/settings",
    icon: Settings,
  },
]

export function Sidebar() {
  const pathname = usePathname()
  const supabase = createClient()

  const handleSignOut = async () => {
    await supabase.auth.signOut()
    window.location.href = "/login"
  }

  return (
    <div className="flex h-screen w-64 flex-col border-l bg-card text-card-foreground">
      <div className="flex h-16 items-center border-b px-6">
        <Link href="/dashboard" className="flex items-center gap-2 font-bold text-xl">
          <Activity className="h-6 w-6 text-primary" />
          <span>لوميا | Glomea</span>
        </Link>
      </div>
      <nav className="flex-1 space-y-1 p-4">
        {navItems.map((item) => {
          const isActive = pathname === item.href
          return (
            <Link
              key={item.href}
              href={item.href}
              className={cn(
                "flex items-center gap-3 rounded-lg px-3 py-2 text-sm font-medium transition-all group",
                isActive 
                  ? "bg-primary text-primary-foreground shadow-md shadow-primary/20" 
                  : "text-muted-foreground hover:bg-accent hover:text-accent-foreground"
              )}
            >
              <item.icon className={cn(
                "h-4 w-4 transition-colors",
                isActive ? "text-primary-foreground" : "text-muted-foreground group-hover:text-accent-foreground"
              )} />
              <span>{item.title}</span>
            </Link>
          )
        })}
      </nav>
      <div className="border-t p-4">
        <button
          onClick={handleSignOut}
          className="flex w-full items-center gap-3 rounded-lg px-3 py-2 text-sm font-medium text-destructive hover:bg-destructive/10 transition-colors"
        >
          <LogOut className="h-4 w-4" />
          <span>تسجيل الخروج</span>
        </button>
      </div>
    </div>
  )
}
