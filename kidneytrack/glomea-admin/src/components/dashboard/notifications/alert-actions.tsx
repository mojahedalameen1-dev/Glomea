"use client"

import { useState } from "react"
import { Check, Trash2, Loader2 } from "lucide-react"
import { Button } from "@/components/ui/button"
import { markAlertAsRead, deleteAlert } from "@/app/actions/notifications"
import { toast } from "sonner"
import { useLanguage } from "@/hooks/use-language"

interface AlertActionsProps {
  alertId: string
  isRead: boolean
}

export function AlertActions({ alertId, isRead }: AlertActionsProps) {
  const { lang } = useLanguage()
  const [loading, setLoading] = useState<string | null>(null)

  async function handleMarkRead() {
    setLoading('read')
    const res = await markAlertAsRead(alertId)
    setLoading(null)
    if (res.success) {
      toast.success(lang === 'ar' ? "تم تحديث التنبيه" : "Alert updated")
    } else {
      toast.error(res.error)
    }
  }

  async function handleDelete() {
    setLoading('delete')
    const res = await deleteAlert(alertId)
    setLoading(null)
    if (res.success) {
      toast.success(lang === 'ar' ? "تم حذف التنبيه" : "Alert deleted")
    } else {
      toast.error(res.error)
    }
  }

  return (
    <div className="flex items-center gap-2 opacity-0 group-hover:opacity-100 transition-opacity">
      {!isRead && (
        <Button 
          variant="ghost" 
          size="icon" 
          disabled={loading !== null}
          onClick={handleMarkRead}
          className="h-8 w-8 text-blue-600 hover:text-blue-700 hover:bg-blue-50 dark:hover:bg-blue-900/20"
        >
          {loading === 'read' ? <Loader2 className="h-4 w-4 animate-spin" /> : <Check className="h-4 w-4" />}
        </Button>
      )}
      <Button 
        variant="ghost" 
        size="icon" 
        disabled={loading !== null}
        onClick={handleDelete}
        className="h-8 w-8 text-red-600 hover:text-red-700 hover:bg-red-50 dark:hover:bg-red-900/20"
      >
        {loading === 'delete' ? <Loader2 className="h-4 w-4 animate-spin" /> : <Trash2 className="h-4 w-4" />}
      </Button>
    </div>
  )
}
