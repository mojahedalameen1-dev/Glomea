import { createClient } from "@/lib/supabase/server"

export interface LogEntry {
  userId: string
  userName: string
  action: 'CREATE' | 'UPDATE' | 'DELETE' | 'MARK_READ' | 'THRESHOLD_UPDATE'
  section: string
  details: any
}

export async function logActivity(entry: LogEntry) {
  try {
    const supabase = await createClient()
    
    const { error } = await supabase
      .from('ActivityLog')
      .insert({
        adminId: entry.userId,
        adminName: entry.userName,
        action: `${entry.action}_${entry.section.toUpperCase()}`,
        details: entry.details,
        created_at: new Date().toISOString()
      })

    if (error) console.warn('Failed to log activity:', error.message)
  } catch (e) {
    console.warn('Activity log skipped:', e)
  }
}
