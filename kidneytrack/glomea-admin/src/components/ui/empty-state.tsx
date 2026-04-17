"use client"

import { LucideIcon, Inbox } from "lucide-react"
import { useLanguage } from "@/hooks/use-language"

interface EmptyStateProps {
  icon?: LucideIcon
  title: string
  description?: string
  className?: string
}

export function EmptyState({ 
  icon: Icon = Inbox, 
  title, 
  description,
  className 
}: EmptyStateProps) {
  const { isRTL } = useLanguage()

  return (
    <div className={`flex flex-col items-center justify-center text-center p-12 py-20 bg-muted/30 rounded-[2rem] border-2 border-dashed border-border ${className}`}>
      <div className="p-6 bg-muted rounded-full mb-6">
        <Icon className="h-12 w-12 text-muted-foreground/50" />
      </div>
      <h3 className="text-xl font-bold text-foreground mb-2">{title}</h3>
      {description && (
        <p className="text-muted-foreground font-medium max-w-xs">{description}</p>
      )}
    </div>
  )
}
