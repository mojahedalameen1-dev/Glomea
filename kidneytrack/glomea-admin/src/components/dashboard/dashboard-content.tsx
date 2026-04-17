"use client"
import { useState, useEffect } from "react"
import { useLanguage } from "@/hooks/use-language"
import { 
  Users, 
  AlertCircle, 
  Droplets, 
  ArrowUpRight,
  MoreVertical,
  MoreHorizontal,
  CheckCircle2,
  Clock,
  ArrowRight,
  ExternalLink,
  Bell,
  BarChart3,
  Activity,
  Loader2,
  AlertTriangle,
  TrendingUp,
  Calendar,
  ChevronRight,
  User
} from "lucide-react"
import SafeChart, { useChartDimensions } from "./safe-chart"
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card"
import { 
  Table, 
  TableBody, 
  TableCell, 
  TableHead, 
  TableHeader, 
  TableRow 
} from "@/components/ui/table"
import { Badge } from "@/components/ui/badge"
import { Button } from "@/components/ui/button"
import { cn } from "@/lib/utils"
import { 
  RadialBarChart, 
  RadialBar, 
  PolarAngleAxis,
  PieChart,
  Pie,
  Cell
} from "recharts"
import Link from "next/link"
import { 
  DropdownMenu, 
  DropdownMenuTrigger, 
  DropdownMenuContent, 
  DropdownMenuItem, 
  DropdownMenuLabel, 
  DropdownMenuSeparator 
} from "@/components/ui/dropdown-menu"
import { PatientActionMenu } from "./patients/patient-action-menu"
import { EmptyState } from "@/components/ui/empty-state"

/* Inner chart that reads measured dimensions from SafeChart context */
function DashboardPieChartInner({ data }: { data: any[] }) {
  const { width, height } = useChartDimensions()
  return (
    <PieChart width={width} height={height}>
      <Pie
        data={data}
        cx="50%"
        cy="50%"
        innerRadius={60}
        outerRadius={80}
        paddingAngle={0}
        dataKey="value"
        startAngle={180}
        endAngle={0}
      >
        <Cell fill="#2563EB" stroke="none" />
      </Pie>
    </PieChart>
  )
}

interface DashboardContentProps {
  stats: {
    totalPatients: number
    todayAlerts: number
    highRiskMeds: number
  }
  recentPatients: any[]
  monthPatients: number
  activityRate: number
  topSources: { name: string, count: number, color: string }[]
  todayNewCount: number
  doctorName?: string
}

export function DashboardContent({ 
  stats, 
  recentPatients, 
  monthPatients, 
  activityRate, 
  topSources,
  todayNewCount,
  doctorName = "Dr. Glomea" 
}: DashboardContentProps) {
  const { tr, isRTL, lang } = useLanguage()
  const [isMounted, setIsMounted] = useState(false)

  useEffect(() => {
    setIsMounted(true)
  }, [])

  // Simplified gauge data for Recharts
  const gaugeData = [{ value: activityRate, fill: "#2563EB" }]

  return (
    <div className="grid grid-cols-1 xl:grid-cols-12 gap-8">
      {/* Center Column */}
      <div className="xl:col-span-8 space-y-8">
        {/* Header Message */}
        <div className="flex flex-col gap-2">
          <h1 className="text-3xl font-extrabold text-foreground tracking-tight">
            {tr.greeting} {doctorName}
          </h1>
          <p className="text-muted-foreground font-medium">
            {tr.subtitle}
          </p>
        </div>

        {/* KPI Cards */}
        <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
          <Card className="border-none shadow-sm dark:shadow-none bg-blue-50 dark:bg-blue-900/10 hover:scale-[1.02] transition-transform duration-300">
            <CardContent className="p-6">
              <div className="flex items-center justify-between mb-4">
                <div className="p-2.5 bg-blue-600 rounded-xl">
                  <Users className="w-5 h-5 text-white" />
                </div>
              </div>
              <p className="text-sm font-bold text-blue-900/60 dark:text-blue-400/60 mb-1">{tr.totalPatients}</p>
              <h3 className="text-3xl font-black text-blue-900 dark:text-white">{stats.totalPatients}</h3>
            </CardContent>
          </Card>

          <Card className="border-none shadow-sm dark:shadow-none bg-amber-50 dark:bg-amber-900/10 hover:scale-[1.02] transition-transform duration-300">
            <CardContent className="p-6">
              <div className="flex items-center justify-between mb-4">
                <div className="p-2.5 bg-amber-500 rounded-xl">
                  <AlertCircle className="w-5 h-5 text-white" />
                </div>
                <Badge variant="secondary" className="bg-amber-100 dark:bg-amber-800/30 text-amber-700 dark:text-amber-300 border-none font-bold">
                  LIVE
                </Badge>
              </div>
              <p className="text-sm font-bold text-amber-900/60 dark:text-amber-400/60 mb-1">{tr.todayAlerts}</p>
              <h3 className="text-3xl font-black text-amber-900 dark:text-white">{stats.todayAlerts}</h3>
            </CardContent>
          </Card>

          <Card className="border-none shadow-sm dark:shadow-none bg-rose-50 dark:bg-rose-900/10 hover:scale-[1.02] transition-transform duration-300">
            <CardContent className="p-6">
              <div className="flex items-center justify-between mb-4">
                <div className="p-2.5 bg-rose-500 rounded-xl">
                  <Droplets className="w-5 h-5 text-white" />
                </div>
                <Badge variant="secondary" className="bg-rose-100 dark:bg-rose-800/30 text-rose-700 dark:text-rose-300 border-none font-bold">
                  HIGH
                </Badge>
              </div>
              <p className="text-[10px] font-black text-rose-600 dark:text-rose-400 uppercase tracking-widest mt-1">
                 {lang === 'ar' ? 'الأدوية عالية الخطورة' : 'High Risk Meds'}
              </p>
              <h3 className="text-3xl font-black text-rose-900 dark:text-white">{stats.highRiskMeds}</h3>
            </CardContent>
          </Card>
        </div>

        {/* Quick Actions */}
        <div className="space-y-4">
          <h2 className="text-xl font-black text-foreground">{tr.quickActions}</h2>
          <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
            <Button 
              asChild
              variant="outline" 
              className="h-24 rounded-3xl border-2 border-blue-100 dark:border-blue-900/30 hover:border-blue-600 dark:hover:border-blue-500 bg-card flex flex-col gap-2 transition-all duration-300"
            >
              <Link href="/dashboard/notifications">
                <div className="p-2 bg-blue-100 dark:bg-blue-900/40 rounded-xl">
                  <Bell className="w-5 h-5 text-blue-600" />
                </div>
                <span className="font-bold text-sm tracking-tight text-foreground">{tr.viewAlerts}</span>
              </Link>
            </Button>

            <Button 
              asChild
              variant="outline" 
              className="h-24 rounded-3xl border-2 border-indigo-100 dark:border-indigo-900/30 hover:border-indigo-600 dark:hover:border-indigo-500 bg-card flex flex-col gap-2 transition-all duration-300"
            >
              <Link href="/dashboard/patients">
                <div className="p-2 bg-indigo-100 dark:bg-indigo-900/40 rounded-xl">
                  <Users className="w-5 h-5 text-indigo-600" />
                </div>
                <span className="font-bold text-sm tracking-tight text-foreground">{tr.managePatients}</span>
              </Link>
            </Button>

            <Button 
              asChild
              variant="outline" 
              className="h-24 rounded-3xl border-2 border-violet-100 dark:border-violet-900/30 hover:border-violet-600 dark:hover:border-violet-500 bg-card flex flex-col gap-2 transition-all duration-300"
            >
              <Link href="/dashboard/analytics">
                <div className="p-2 bg-violet-100 dark:bg-violet-900/40 rounded-xl">
                  <BarChart3 className="w-5 h-5 text-violet-600" />
                </div>
                <span className="font-bold text-sm tracking-tight text-foreground">{tr.reports}</span>
              </Link>
            </Button>
          </div>
        </div>

        {/* Recent Patients Table */}
        <div className="space-y-4">
          <div className="flex items-center justify-between">
            <h2 className="text-xl font-black text-foreground">{tr.recentPatients}</h2>
            <Button variant="ghost" className="text-primary font-bold text-xs gap-1">
              {tr.viewAll} <ArrowUpRight className={cn("w-3 h-3", isRTL && "-scale-x-100")} />
            </Button>
          </div>
          
          <Card className="border border-border shadow-sm dark:shadow-none bg-card rounded-[1.5rem] overflow-hidden">
            <Table>
              <TableHeader className="bg-muted/50 border-b border-border">
                <TableRow className="border-none hover:bg-transparent text-foreground">
                  <TableHead className="font-bold py-4 text-[11px] uppercase tracking-wider text-muted-foreground">{tr.name}</TableHead>
                  <TableHead className="font-bold py-4 text-[11px] uppercase tracking-wider text-muted-foreground">{tr.registrationDate}</TableHead>
                  <TableHead className="font-bold py-4 text-[11px] uppercase tracking-wider text-muted-foreground">{tr.lastReading}</TableHead>
                  <TableHead className="font-bold py-4 text-[11px] uppercase tracking-wider text-muted-foreground">{tr.status}</TableHead>
                  <TableHead className="w-[50px]"></TableHead>
                </TableRow>
              </TableHeader>
              <TableBody>
                {recentPatients.length > 0 ? (
                  recentPatients.map((patient) => (
                    <TableRow key={patient.id} className="border-border hover:bg-muted/50 transition-colors">
                      <TableCell className="font-bold text-foreground py-5">
                        <div className="flex items-center gap-3">
                          <div className="w-8 h-8 rounded-full bg-primary/10 flex items-center justify-center text-[10px] text-primary font-black">
                            {patient.full_name?.charAt(0) || "P"}
                          </div>
                          {patient.full_name ?? '—'}
                        </div>
                      </TableCell>
                      <TableCell className="text-muted-foreground font-medium text-sm">
                        {new Date(patient.created_at).toLocaleDateString(lang === 'ar' ? 'ar-SA' : 'en-US')}
                      </TableCell>
                      <TableCell>
                        <Badge variant="outline" className="rounded-lg h-7 font-bold border-border bg-background text-muted-foreground">
                          {patient.kidneyStage || "N/A"}
                        </Badge>
                      </TableCell>
                      <TableCell>
                        <div className="flex items-center gap-2">
                          <div className={cn(
                            "w-1.5 h-1.5 rounded-full",
                            patient.dialysisStatus ? "bg-blue-500" : "bg-green-500"
                          )} />
                          <span className="text-xs font-bold text-muted-foreground capitalize">
                            {patient.dialysisStatus || patient.kidneyStage || "\u2014"}
                          </span>
                        </div>
                      </TableCell>
                      <TableCell>
                        <PatientActionMenu patientId={patient.id} patientName={patient.full_name ?? '—'} />
                      </TableCell>
                    </TableRow>
                  ))
                ) : (
                  <TableRow>
                    <TableCell colSpan={5} className="p-0">
                      <EmptyState 
                        title={tr.noData} 
                        description={lang === 'ar' ? 'لا توجد بيانات مرضى حديثة.' : 'No recent patients data.'} 
                        className="border-none rounded-none bg-transparent py-10"
                      />
                    </TableCell>
                  </TableRow>
                )}
              </TableBody>
            </Table>
          </Card>
        </div>
      </div>

      {/* Right Column (Panel) */}
      <div className="xl:col-span-4 space-y-8">
        {/* Month Stat Card */}
        <Card className="border-none shadow-sm dark:shadow-none bg-blue-600 rounded-[2rem] text-white overflow-hidden relative">
          <CardContent className="p-8 space-y-4">
            <div className="flex items-center justify-between">
              <span className="text-sm font-bold opacity-80">{tr.thisMonth}</span>
              <div className="w-10 h-10 bg-white/20 rounded-xl flex items-center justify-center">
                <Users className="w-5 h-5" />
              </div>
            </div>
            <h3 className="text-5xl font-black">{monthPatients}</h3>
            <div className="flex items-center gap-2 pt-2">
              <span className="text-xs font-bold opacity-80 leading-relaxed">
                {lang === 'ar' ? `+${todayNewCount} مسجلين اليوم` : `+${todayNewCount} New today`}
              </span>
            </div>
          </CardContent>
          <div className={cn("absolute top-0 w-32 h-32 bg-white/10 rounded-full blur-2xl -translate-y-1/2", isRTL ? "end-0 -translate-x-1/2" : "end-0 translate-x-1/2")} />
        </Card>

        {/* Analytics Summary */}
        <Card className="border border-border shadow-sm dark:shadow-none bg-card rounded-[2rem] overflow-hidden">
          <CardContent className="p-8 space-y-6">
            <div className="flex items-center justify-between">
              <p className="text-[10px] font-black text-primary uppercase tracking-widest mt-1">
                {lang === 'ar' ? 'المرضى النشطون' : 'Active patients'}
              </p>
              <div className="p-1.5 bg-muted rounded-lg border border-border">
                <ArrowUpRight className="w-4 h-4 text-muted-foreground" />
              </div>
            </div>
            
            <div className="flex items-center justify-center py-4">
              <div className="relative w-48 h-48">
                <SafeChart>
                  <DashboardPieChartInner data={gaugeData} />
                </SafeChart>
                <div className="absolute inset-0 flex flex-col items-center justify-center pt-8">
                  <span className="text-4xl font-black text-foreground">{activityRate}%</span>
                  <span className="text-[10px] font-bold text-muted-foreground uppercase tracking-widest leading-none mt-1">{tr.activity}</span>
                </div>
              </div>
            </div>

            <div className="space-y-4">
              {topSources.map((source, index) => (
                <div key={index} className="flex items-center justify-between">
                  <div className="flex items-center gap-3">
                    <div className="w-2 h-2 rounded-full" style={{ backgroundColor: source.color }} />
                    <span className="text-xs font-bold text-muted-foreground">{source.name}</span>
                  </div>
                  <span className="text-xs font-black text-foreground">{source.count}</span>
                </div>
              ))}
            </div>
          </CardContent>
        </Card>

        {/* Top Alerts / Sources Section Alternative (Simplified) */}
        <Card className="border border-border shadow-sm dark:shadow-none bg-card rounded-[2rem] p-8">
          <div className="flex items-center justify-between mb-8">
            <h3 className="font-black text-foreground tracking-tight uppercase text-xs">{tr.topAlerts}</h3>
            <Button variant="ghost" size="icon" className="h-8 w-8 text-muted-foreground border border-transparent hover:border-border">
              <MoreHorizontal className="w-4 h-4" />
            </Button>
          </div>

          <div className="space-y-6">
            {topSources.length > 0 ? (
              topSources.map((source, idx) => (
                <div key={idx} className="flex items-center justify-between group cursor-pointer">
                  <div className="flex items-center gap-4">
                    <div className={cn("w-3 h-3 rounded-full")} style={{ backgroundColor: source.color }} />
                    <div>
                      <p className="text-sm font-bold text-foreground group-hover:text-primary transition-colors">
                        {source.name}
                      </p>
                      <p className="text-[10px] font-bold text-muted-foreground uppercase tracking-wider">{source.count} {tr.alerts}</p>
                    </div>
                  </div>
                  <ArrowUpRight className={cn("w-4 h-4 text-border transition-all", isRTL ? "group-hover:-translate-x-0.5 group-hover:-translate-y-0.5 -scale-x-100" : "group-hover:translate-x-0.5 group-hover:-translate-y-0.5")} />
                </div>
              ))
            ) : (
              <p className="text-center py-8 text-muted-foreground font-bold text-sm">{tr.noData}</p>
            )}
            
            <Button asChild variant="outline" className="w-full bg-muted/30 hover:bg-muted text-muted-foreground border-border rounded-2xl h-12 gap-2 transition-all active:scale-95">
              <Link href="/dashboard/notifications">
                <span className="font-bold">{tr.checkAllSources}</span>
                <ExternalLink className={cn("w-4 h-4", isRTL && "-scale-x-100")} />
              </Link>
            </Button>
          </div>
        </Card>
      </div>
    </div>
  )
}
