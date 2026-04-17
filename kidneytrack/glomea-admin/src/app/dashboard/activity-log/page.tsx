import { createClient } from "@/lib/supabase/server"
import { getTranslations } from "@/lib/i18n/i18n-server"
import { Card, CardContent } from "@/components/ui/card"
import { ClipboardList, User, Shield, Clock } from "lucide-react"
import { EmptyState } from "@/components/ui/empty-state"

export default async function ActivityLogPage() {
  const { tr, lang } = await getTranslations()
  const supabase = await createClient()

  const { data: logs, error } = await supabase
    .from('ActivityLog')
    .select('id, adminName, action, targetId, created_at')
    .order('created_at', { ascending: false })
    .limit(100)

  if (error) {
    console.warn("Activity log fetch skipped (check if table exists):", error.message)
  }

  return (
    <div className="space-y-8 pb-20 max-w-6xl mx-auto p-8">
      <div>
        <h2 className="text-4xl font-black tracking-tight flex items-center gap-3 text-foreground">
          <ClipboardList className="h-8 w-8 text-primary" />
          {lang === 'ar' ? "سجل النشاط" : "Activity Log"}
        </h2>
        <p className="text-muted-foreground mt-2 font-medium">
          {lang === 'ar' ? "تتبع كافة العمليات التي قام بها المشرفون في النظام." : "Track all operations performed by administrators."}
        </p>
      </div>

      <div className="grid gap-4">
        {logs && logs.length > 0 ? (
          logs.map((log) => (
            <Card key={log.id} className="border border-border shadow-sm hover:shadow-md transition-all bg-card rounded-2xl overflow-hidden hover:bg-muted/50">
              <CardContent className="flex items-center gap-6 p-5">
                <div className="h-12 w-12 rounded-2xl bg-muted flex items-center justify-center text-muted-foreground">
                  <User className="h-6 w-6" />
                </div>
                
                <div className="flex-1 min-w-0">
                  <div className="flex items-center gap-2 mb-1">
                    <span className="font-bold text-foreground capitalize">{log.adminName}</span>
                    <span className="px-2 py-0.5 rounded-full bg-blue-50 dark:bg-blue-900/20 text-[10px] font-black text-blue-600 uppercase tracking-tighter">
                      {log.action.replace('_', ' ')}
                    </span>
                  </div>
                  <p className="text-sm text-muted-foreground font-medium truncate">
                    {lang === 'ar' ? "قام بتنفيذ عملية على المعرف: " : "Performed action on ID: "} 
                    <code className="bg-muted px-1.5 py-0.5 rounded text-xs font-mono text-foreground">{log.targetId || 'N/A'}</code>
                  </p>
                </div>

                <div className="text-right shrink-0">
                  <div className="flex items-center gap-1.5 text-xs font-bold text-muted-foreground">
                    <Clock className="h-3 w-3" />
                    {new Date(log.created_at).toLocaleString(lang === 'ar' ? 'ar-SA' : 'en-US', {
                      hour: '2-digit',
                      minute: '2-digit',
                      day: 'numeric',
                      month: 'short'
                    })}
                  </div>
                </div>
              </CardContent>
            </Card>
          ))
        ) : (
          <EmptyState 
            title={tr.noData} 
            description={lang === 'ar' ? 'سجل النشاطات فارغ.' : 'Activity log is empty.'} 
          />
        )}
      </div>
    </div>
  )
}
