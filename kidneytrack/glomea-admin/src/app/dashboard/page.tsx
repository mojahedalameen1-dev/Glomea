import { createClient } from "@/lib/supabase/server"
import { DashboardContent } from "@/components/dashboard/dashboard-content"
import { startOfDay, startOfMonth, subDays } from "date-fns"

export default async function DashboardPage() {
  const supabase = await createClient()
  const now = new Date()
  const todayStart = startOfDay(now).toISOString()
  const monthStart = startOfMonth(now).toISOString()
  const sevenDaysAgo = subDays(now, 7).toISOString()

  // 1. Get User Session First
  const { data: { user } } = await supabase.auth.getUser()

  // 2. Fetch all data in parallel
  const [
    { count: totalPatients },
    { count: todayAlerts },
    { count: highRiskMeds },
    { data: recentPatients },
    { count: monthPatients },
    { count: todayNewCount },
    { data: activePatientIds },
    { data: adminProfile },
    { data: alertsData },
  ] = await Promise.all([
    supabase.from('Patient').select('id', { count: 'exact', head: true }),
    supabase.from('Alert').select('id', { count: 'exact', head: true }).gte('created_at', todayStart),
    supabase.from('medications').select('id', { count: 'exact', head: true }).eq('is_nephrotoxic', true),
    supabase.from('Patient').select('id, full_name, created_at, kidneyStage, dialysisStatus').order('created_at', { ascending: false }).limit(10),
    supabase.from('Patient').select('id', { count: 'exact', head: true }).gte('created_at', monthStart),
    supabase.from('Patient').select('id', { count: 'exact', head: true }).gte('created_at', todayStart),
    supabase.from('LabResult').select('patientId').gte('recordedAt', sevenDaysAgo).limit(200),
    supabase.from('admin_users').select('full_name').eq('id', user?.id).single(),
    supabase.from('Alert').select('messageAr').limit(100),
  ])

  const uniqueActivePatients = new Set(activePatientIds?.map((p: any) => p.patientId)).size
  const activityRate = totalPatients && totalPatients > 0 
    ? Math.round((uniqueActivePatients / totalPatients) * 100) 
    : 0

  const groupedAlerts = (alertsData || []).reduce((acc: any, curr) => {
    if (curr.messageAr) {
      acc[curr.messageAr] = (acc[curr.messageAr] || 0) + 1
    }
    return acc
  }, {})

  const colors = ["bg-blue-500", "bg-amber-500", "bg-rose-500", "bg-indigo-500"]
  const topSources = Object.entries(groupedAlerts)
    .map(([name, count], idx) => ({ 
      name, 
      count: count as number, 
      color: colors[idx % colors.length] 
    }))
    .sort((a, b) => b.count - a.count)
    .slice(0, 4)

  return (
    <DashboardContent 
      stats={{
        totalPatients: totalPatients || 0,
        todayAlerts: todayAlerts || 0,
        highRiskMeds: highRiskMeds || 0
      }}
      recentPatients={recentPatients || []}
      monthPatients={monthPatients || 0}
      todayNewCount={todayNewCount || 0}
      activityRate={activityRate}
      topSources={topSources}
      doctorName={adminProfile?.full_name || "Admin"}
    />
  )
}
