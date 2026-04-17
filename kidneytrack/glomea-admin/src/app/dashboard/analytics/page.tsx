"use client"

import { Card, CardContent, CardHeader, CardTitle, CardDescription } from "@/components/ui/card"
import { 
  BarChart, 
  Bar, 
  XAxis, 
  YAxis, 
  CartesianGrid, 
  Tooltip, 
  PieChart,
  Pie,
  Cell
} from "recharts"
import { Calendar, TrendingUp, Loader2 } from "lucide-react"
import { useEffect, useState } from "react"
import { createClient } from "@/lib/supabase/client"
import { useLanguage } from "@/hooks/use-language"
import SafeChart, { useChartDimensions } from "@/components/dashboard/safe-chart"

const COLORS = ["#2563EB", "#10B981", "#F59E0B", "#EF4444", "#8B5CF6", "#6366F1"]

/* Chart wrappers that read measured dimensions from SafeChart context */
function BarChartInner({ data, lang }: { data: any[]; lang: string }) {
  const { width, height } = useChartDimensions()
  return (
    <BarChart width={width} height={height} data={data}>
      <CartesianGrid strokeDasharray="3 3" vertical={false} strokeOpacity={0.1} />
      <XAxis dataKey="month" stroke="#888888" fontSize={10} fontWeight="bold" tickLine={false} axisLine={false} />
      <YAxis stroke="#888888" fontSize={10} fontWeight="bold" tickLine={false} axisLine={false} />
      <Tooltip 
        contentStyle={{ borderRadius: '12px', border: 'none', boxShadow: '0 10px 15px -3px rgb(0 0 0 / 0.1)' }}
        itemStyle={{ fontWeight: 'bold' }}
      />
      <Bar dataKey="count" fill="#2563EB" radius={[4, 4, 0, 0]} />
    </BarChart>
  )
}

function PieChartInner({ data }: { data: any[] }) {
  const { width, height } = useChartDimensions()
  return (
    <PieChart width={width} height={height}>
      <Pie
        data={data}
        cx="50%"
        cy="50%"
        innerRadius={60}
        outerRadius={90}
        paddingAngle={5}
        dataKey="value"
        stroke="none"
      >
        {data.map((entry, index) => (
          <Cell key={`cell-${index}`} fill={COLORS[index % COLORS.length]} />
        ))}
      </Pie>
      <Tooltip 
        contentStyle={{ borderRadius: '12px', border: 'none', boxShadow: '0 10px 15px -3px rgb(0 0 0 / 0.1)' }}
        itemStyle={{ fontWeight: 'bold' }}
      />
    </PieChart>
  )
}

export default function AnalyticsPage() {
  const { tr, lang } = useLanguage()
  const [loading, setLoading] = useState(true)
  const [registrationData, setRegistrationData] = useState<any[]>([])
  const [stageData, setStageData] = useState<any[]>([])
  const [totalPatients, setTotalPatients] = useState(0)
  const [weeklyActivity, setWeeklyActivity] = useState(0)

  useEffect(() => {
    async function fetchData() {
      const supabase = createClient()
      const now = new Date()
      const sevenDaysAgo = new Date(now.getTime() - 7 * 24 * 60 * 60 * 1000).toISOString()
      
      const { data: patients, error } = await supabase
        .from('Patient')
        .select('created_at, kidneyStage')
        .limit(1000)

      if (error) {
        console.error("Error fetching analytics data:", error)
        setLoading(false)
        return
      }

      setTotalPatients(patients.length)

      const { count: activityCount } = await supabase
        .from('Alert')
        .select('id', { count: 'exact', head: true })
        .gte('created_at', sevenDaysAgo)
      
      setWeeklyActivity(activityCount || 0)

      const last6Months = Array.from({ length: 6 }).map((_, i) => {
        const d = new Date(now.getFullYear(), now.getMonth() - (5 - i), 1)
        return {
          monthIndex: d.getMonth(),
          year: d.getFullYear(),
          month: d.toLocaleDateString(lang === 'ar' ? 'ar-SA' : 'en-US', { month: 'short' }),
          count: 0
        }
      })

      patients.forEach(p => {
        const pDate = new Date(p.created_at)
        const match = last6Months.find(m => m.monthIndex === pDate.getMonth() && m.year === pDate.getFullYear())
        if (match) match.count++
      })
      setRegistrationData(last6Months)

      const stageMap: Record<string, number> = {}
      patients.forEach(p => {
        const stage = p.kidneyStage || "UNKNOWN"
        stageMap[stage] = (stageMap[stage] || 0) + 1
      })

      const processedStageData = Object.entries(stageMap).map(([key, value]) => ({
        name: key.replace('_', ' '),
        value
      }))
      setStageData(processedStageData)
      setLoading(false)
    }

    fetchData()
  }, [lang])

  if (loading) {
    return (
      <div className="h-[400px] flex flex-col items-center justify-center gap-4">
        <Loader2 className="h-8 w-8 animate-spin text-blue-600" />
        <p className="text-muted-foreground animate-pulse font-bold">
          {lang === 'ar' ? 'جاري تحليل البيانات...' : 'Analyzing data...'}
        </p>
      </div>
    )
  }

  return (
    <div className="space-y-6">
      <div>
        <h2 className="text-3xl font-bold tracking-tight">{tr.analytics}</h2>
        <p className="text-muted-foreground">
          {lang === 'ar' ? 'نظرة معمقة على البيانات الصحية للمرضى ونمو المنصة.' : 'In-depth look at patient health data and platform growth.'}
        </p>
      </div>

      <div className="grid gap-6 md:grid-cols-2 lg:grid-cols-4">
          <Card className="border-none shadow-sm dark:shadow-none bg-blue-50 dark:bg-blue-900/10 rounded-[1.5rem] overflow-hidden">
              <CardHeader className="flex flex-row items-center justify-between pb-2">
                  <CardTitle className="text-sm font-bold text-blue-900/60 dark:text-blue-400/60">{tr.totalPatients}</CardTitle>
                  <TrendingUp className="h-4 w-4 text-blue-600" />
              </CardHeader>
              <CardContent>
                  <div className="text-3xl font-black text-blue-900 dark:text-white">{totalPatients}</div>
                  <p className="text-[10px] font-bold text-blue-600/60 dark:text-blue-400/60 uppercase tracking-widest mt-1">Active patients</p>
              </CardContent>
          </Card>
          <Card className="border-none shadow-sm dark:shadow-none bg-amber-50 dark:bg-amber-900/10 rounded-[1.5rem] overflow-hidden">
              <CardHeader className="flex flex-row items-center justify-between pb-2">
                  <CardTitle className="text-sm font-bold text-amber-900/60 dark:text-amber-400/60">{lang === 'ar' ? 'النشاط الأسبوعي' : 'Weekly Activity'}</CardTitle>
                  <Calendar className="h-4 w-4 text-amber-500" />
              </CardHeader>
              <CardContent>
                  <div className="text-3xl font-black text-amber-900 dark:text-white">{weeklyActivity}</div>
                  <p className="text-[10px] font-bold text-amber-600/60 dark:text-amber-400/60 uppercase tracking-widest mt-1">Alerts this week</p>
              </CardContent>
          </Card>
      </div>

      <div className="grid gap-6 md:grid-cols-2">
        <Card className="border border-border shadow-sm dark:shadow-none bg-card rounded-[2rem] overflow-hidden">
          <CardHeader className="p-8 pb-4">
            <CardTitle className="text-xl font-black uppercase tracking-tight">{tr.patientRegGrowth}</CardTitle>
            <CardDescription className="font-medium">{lang === 'ar' ? 'عدد المرضى المسجلين شهرياً' : 'Number of patients registered monthly'}</CardDescription>
          </CardHeader>
          <CardContent className="p-8 pt-0">
            <div className="h-[300px] w-full">
              <SafeChart>
                <BarChartInner data={registrationData} lang={lang} />
              </SafeChart>
            </div>
          </CardContent>
        </Card>

        <Card className="border border-border shadow-sm dark:shadow-none bg-card rounded-[2rem] overflow-hidden">
          <CardHeader className="p-8 pb-4">
            <CardTitle className="text-xl font-black uppercase tracking-tight">{tr.kidneyStageDist}</CardTitle>
            <CardDescription className="font-medium">{lang === 'ar' ? 'نسبة المرضى حسب المرحلة' : 'Percentage of patients by stage'}</CardDescription>
          </CardHeader>
          <CardContent className="p-8 pt-0 flex items-center justify-center">
            <div className="h-[300px] w-full">
              <SafeChart>
                <PieChartInner data={stageData} />
              </SafeChart>
            </div>
          </CardContent>
        </Card>
      </div>
    </div>
  )
}
