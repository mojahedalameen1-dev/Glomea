import { Card, CardContent } from "@/components/ui/card"
import { Info, AlertTriangle, Bell, Inbox } from "lucide-react"
import { createClient } from "@/lib/supabase/server"
import { getTranslations } from "@/lib/i18n/i18n-server"
import { AlertActions } from "@/components/dashboard/notifications/alert-actions"
import { EmptyState } from "@/components/ui/empty-state"

export default async function NotificationsPage() {
  const { tr, lang } = await getTranslations()
  const supabase = await createClient()

  const { data: alerts, error } = await supabase
    .from('Alert')
    .select('id, messageAr, isRead, created_at, patientId')
    .order('created_at', { ascending: false })
    .limit(50)

  if (error) {
    return (
      <div className="p-8 text-center bg-red-50 dark:bg-red-900/10 text-red-600 rounded-2xl border border-red-100 dark:border-red-900/20">
        {lang === 'ar' ? 'حدث خطأ أثناء تحميل التنبيهات' : 'Error loading alerts'}: {error.message}
      </div>
    )
  }

  return (
    <div className="max-w-5xl mx-auto space-y-8 pb-20">
      <div className="flex items-center justify-between">
        <div>
          <h2 className="text-4xl font-black tracking-tight flex items-center gap-3">
            <Bell className="h-8 w-8 text-blue-600" />
            {tr.notifications}
          </h2>
          <p className="text-muted-foreground mt-2 font-medium">
            {lang === 'ar' ? 'متابعة كافة الإشعارات والتنبيهات الطبية والفنية.' : 'Track all medical and system alerts.'}
          </p>
        </div>
      </div>

      <div className="grid gap-4">
        {alerts && alerts.length > 0 ? (
          alerts.map((n) => {
            const isCritical = n.messageAr ? n.messageAr.includes('حرجة') || n.messageAr.includes('عالية') || n.messageAr.includes('خطير') : false
            const isRead = n.isRead === true
            
            return (
              <Card 
                key={n.id} 
                className={`group border border-border shadow-sm transition-all hover:shadow-md hover:translate-x-1 ${
                  isRead ? "opacity-60 bg-muted/50" : "bg-card border-l-4 border-l-blue-600"
                } ${isCritical && !isRead ? "border-l-red-600" : ""}`}
              >
                <CardContent className="flex items-center gap-6 p-6">
                  <div className={`p-4 rounded-2xl ${
                    isCritical ? 'bg-red-500/10 text-red-500' : 'bg-blue-500/10 text-blue-500'
                  }`}>
                    {isCritical ? <AlertTriangle className="h-6 w-6" /> : <Info className="h-6 w-6" />}
                  </div>
                  
                  <div className="flex-1 min-w-0">
                    <div className="flex items-center justify-between mb-1">
                      <p className={`font-bold text-lg truncate ${isRead ? "text-muted-foreground" : "text-foreground"}`}>
                        {lang === 'ar' ? 'تنبيه لنظام المراقبة' : 'Monitoring Alert'}
                      </p>
                      <span className="text-xs font-bold text-muted-foreground shrink-0">
                        {new Date(n.created_at).toLocaleString(lang === 'ar' ? 'ar-SA' : 'en-US', {
                          month: 'short',
                          day: 'numeric',
                          hour: '2-digit',
                          minute: '2-digit'
                        })}
                      </span>
                    </div>
                    <p className="text-muted-foreground text-sm line-clamp-2 font-medium leading-relaxed">
                      {n.messageAr || '-'}
                    </p>
                  </div>

                  <AlertActions alertId={n.id} isRead={isRead} />
                </CardContent>
              </Card>
            )
          })
        ) : (
          <EmptyState 
            title={tr.noData} 
            description={lang === 'ar' ? 'لا توجد إشعارات حتى الآن.' : 'No notifications yet.'} 
          />
        )}
      </div>
    </div>
  )
}
