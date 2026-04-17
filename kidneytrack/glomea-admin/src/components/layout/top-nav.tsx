"use client"

import { useState, useEffect } from "react"
import { useTheme } from "next-themes"
import { useLanguage } from "@/hooks/use-language"
import { Search, Bell, Settings, Moon, Sun, User } from "lucide-react"
import { Input } from "@/components/ui/input"
import { Button } from "@/components/ui/button"
import { cn } from "@/lib/utils"
import { Switch } from "@/components/ui/switch"
import { useAdmin } from "@/components/providers/admin-provider"

export function TopNav() {
  const { theme, resolvedTheme, setTheme } = useTheme()
  const { lang, setLang, tr, isRTL } = useLanguage()
  const { admin } = useAdmin()
  const adminName = admin?.fullName || "Admin"
  const [mounted, setMounted] = useState(false)

  // Prevent hydration mismatch for theme
  useEffect(() => {
    setMounted(true)
  }, [])

  if (!mounted) return null

  const isDark = resolvedTheme === 'dark'

  return (
    <header className="sticky top-0 start-0 end-0 h-20 border-b border-border bg-background/80 backdrop-blur-md z-40 px-8 flex items-center justify-between gap-12 transition-colors duration-300">
      {/* Search Bar */}
      <div className="flex-1 max-w-2xl relative group">
        <Search className="absolute start-4 top-1/2 -translate-y-1/2 w-4 h-4 text-muted-foreground group-focus-within:text-primary transition-colors" />
        <Input 
          placeholder={tr.searchPlaceholder}
          className="w-full bg-muted/50 border-none rounded-xl h-11 ps-12 pe-4 focus-visible:ring-1 focus-visible:ring-primary/50 transition-all font-medium"
        />
      </div>

      {/* Controls */}
      <div className="flex items-center gap-6">
        {/* Language Switch */}
        <div className="flex items-center gap-2.5 bg-muted/50 px-4 py-1.5 rounded-full border border-border transition-all hover:bg-muted">
          <span className={cn("text-xs font-bold transition-colors w-4 text-center select-none", lang === 'ar' ? "text-primary" : "text-muted-foreground")}>ع</span>
          <Switch 
            checked={lang === 'ar'}
            onCheckedChange={(checked: boolean) => setLang(checked ? 'ar' : 'en')}
            className="scale-90"
          />
          <span className={cn("text-[10px] font-black transition-colors w-4 text-center select-none", lang === 'en' ? "text-primary" : "text-muted-foreground")}>EN</span>
        </div>

        {/* Theme Toggles */}
        <div className="flex items-center gap-3">
          <div className="relative flex items-center bg-muted/50 p-1 rounded-full border border-border">
            <Button
              variant="ghost"
              size="icon"
              className={cn(
                "w-8 h-8 rounded-full transition-all duration-300",
                !isDark ? "bg-white dark:bg-white shadow-sm text-blue-600" : "text-muted-foreground"
              )}
              onClick={() => setTheme('light')}
            >
              <Sun className="w-4 h-4" />
            </Button>
            <Button
              variant="ghost"
              size="icon"
              className={cn(
                "w-8 h-8 rounded-full transition-all duration-300",
                isDark ? "bg-gray-800 shadow-sm text-yellow-400" : "text-muted-foreground"
              )}
              onClick={() => setTheme('dark')}
            >
              <Moon className="w-4 h-4" />
            </Button>
          </div>
        </div>

        <div className="w-px h-6 bg-border mx-2" />

        {/* Action Icons */}
        <div className="flex items-center gap-1">
          <Button 
            variant="ghost" 
            size="icon"
            className="rounded-xl text-gray-500 dark:text-gray-400 hover:bg-gray-100 dark:hover:bg-[#1a1a1a] h-10 w-10 relative"
          >
            <Bell className="w-5 h-5" />
            <span className="absolute top-2.5 end-2.5 w-2 h-2 bg-red-500 border-2 border-white dark:border-[#0a0a0a] rounded-full" />
          </Button>

          <Button 
            variant="ghost" 
            size="icon"
            className="rounded-xl text-gray-500 dark:text-gray-400 hover:bg-gray-100 dark:hover:bg-[#1a1a1a] h-10 w-10"
          >
            <Settings className="w-5 h-5" />
          </Button>
        </div>

        {/* Avatar */}
        <div className="ms-2 ps-4 border-s border-gray-100 dark:border-[#2a2a2a] flex items-center gap-3">
          <div className="w-10 h-10 rounded-xl bg-gradient-to-br from-blue-500 to-blue-700 p-0.5 shadow-lg shadow-blue-500/20">
            <div className="w-full h-full bg-white dark:bg-[#1a1a1a] rounded-[10px] flex items-center justify-center">
              <User className="w-5 h-5 text-blue-600 dark:text-blue-400" />
            </div>
          </div>
          <div className="hidden xl:block">
            <p className="text-sm font-bold text-gray-900 dark:text-white leading-none whitespace-nowrap">{adminName}</p>
            <p className="text-[10px] text-gray-500 dark:text-gray-400 font-semibold mt-1 flex items-center gap-1">
              <span className="w-1.5 h-1.5 bg-green-500 rounded-full" />
              {lang === 'ar' ? "متصل" : "ONLINE"}
            </p>
          </div>
        </div>
      </div>
    </header>
  )
}
