import { createClient } from "@/lib/supabase/server"
import { notFound } from "next/navigation"
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card"
import { Tabs, TabsContent, TabsList, TabsTrigger } from "@/components/ui/tabs"
import { Badge } from "@/components/ui/badge"
import { Button } from "@/components/ui/button"
import { 
  Table, 
  TableBody, 
  TableCell, 
  TableHead, 
  TableHeader, 
  TableRow 
} from "@/components/ui/table"
import { 
  ArrowRight, 
  User, 
  Calendar, 
  Phone, 
  Mail, 
  Hospital,
  Activity,
  FlaskConical,
  Pill
} from "lucide-react"
import Link from "next/link"

interface PatientDetailPageProps {
  params: {
    id: string
  }
}

export default async function PatientDetailPage({ params }: PatientDetailPageProps) {
  const { id } = await params
  const supabase = await createClient()

  // Fetch Patient Details
  const { data: patient, error: patientError } = await supabase
    .from('Patient')
    .select('id, full_name, phone_number, email, birthDate, heightCm, weightKg, kidneyStage, dialysisStatus, targetSystolic, targetDiastolic, dryWeightKg')
    .eq('id', id)
    .single()

  if (patientError || !patient) {
    notFound()
  }

  // Fetch Lab Results
  const { data: labs } = await supabase
    .from('LabResult')
    .select('id, indicatorCode, value, recordedAt')
    .eq('patientId', id)
    .order('recordedAt', { ascending: false })
    .limit(50)

  // Fetch Medications (snake_case table)
  const { data: medications } = await supabase
    .from('medications')
    .select('id, name, dose, frequency, is_active, is_nephrotoxic')
    .eq('patient_id', id)
    .order('start_date', { ascending: false })
    .limit(50)

  return (
    <div className="space-y-6">
      <div className="flex items-center gap-4">
        <Button variant="ghost" size="icon" asChild>
          <Link href="/dashboard/patients">
            <ArrowRight className="h-4 w-4" />
          </Link>
        </Button>
        <div>
          <h2 className="text-3xl font-bold tracking-tight">تفاصيل المريض</h2>
          <p className="text-muted-foreground">{patient.full_name ?? '—'}</p>
        </div>
      </div>

      <div className="grid gap-6 md:grid-cols-3">
        {/* Profile Summary Card */}
        <Card className="md:col-span-1">
          <CardHeader>
            <div className="flex items-center justify-between">
              <CardTitle>الملف الشخصي</CardTitle>
              <User className="h-4 w-4 text-muted-foreground" />
            </div>
            <CardDescription>معلومات التواصل والمقاييس الأساسية</CardDescription>
          </CardHeader>
          <CardContent className="space-y-4">
            <div className="space-y-1">
              <div className="flex items-center gap-2 text-sm text-muted-foreground">
                <Phone className="h-3 w-3" />
                <span>رقم الهاتف</span>
              </div>
              <p className="font-medium">{patient.phone_number || "غير متوفر"}</p>
            </div>
            <div className="space-y-1">
              <div className="flex items-center gap-2 text-sm text-muted-foreground">
                <Mail className="h-3 w-3" />
                <span>البريد الإلكتروني</span>
              </div>
              <p className="font-medium">{patient.email || "غير متوفر"}</p>
            </div>
            <div className="space-y-1">
              <div className="flex items-center gap-2 text-sm text-muted-foreground">
                <Calendar className="h-3 w-3" />
                <span>تاريخ الميلاد</span>
              </div>
              <p className="font-medium">
                {patient.birthDate ? new Date(patient.birthDate).toLocaleDateString('ar-SA') : "غير متوفر"}
              </p>
            </div>
            <div className="pt-4 border-t grid grid-cols-2 gap-4">
              <div className="space-y-1">
                <span className="text-xs text-muted-foreground">الطول</span>
                <p className="font-bold">{patient.heightCm ? `${patient.heightCm} سم` : "—"}</p>
              </div>
              <div className="space-y-1">
                <span className="text-xs text-muted-foreground">الوزن</span>
                <p className="font-bold">{patient.weightKg ? `${patient.weightKg} كجم` : "—"}</p>
              </div>
            </div>
          </CardContent>
        </Card>

        {/* Tabs for detailed data */}
        <Card className="md:col-span-2">
          <CardContent className="p-6">
            <Tabs defaultValue="overview" dir="rtl">
              <TabsList className="grid w-full grid-cols-3">
                <TabsTrigger value="overview">ملخص الحالة</TabsTrigger>
                <TabsTrigger value="labs">الفحوصات</TabsTrigger>
                <TabsTrigger value="meds">الأدوية</TabsTrigger>
              </TabsList>

              <TabsContent value="overview" className="space-y-4 pt-4">
                <div className="grid gap-4 sm:grid-cols-2">
                  <div className="rounded-lg border p-4">
                    <div className="flex items-center gap-2 text-sm font-medium mb-2">
                      <Hospital className="h-4 w-4 text-primary" />
                      <span>المرحلة الكلوية</span>
                    </div>
                    <p className="text-2xl font-bold">{patient.kidneyStage || "غير محدد"}</p>
                  </div>
                  <div className="rounded-lg border p-4">
                    <div className="flex items-center gap-2 text-sm font-medium mb-2">
                      <Activity className="h-4 w-4 text-primary" />
                      <span>حالة الغسيل</span>
                    </div>
                    <p className="text-2xl font-bold">{patient.dialysisStatus || "منتظم"}</p>
                  </div>
                  <div className="rounded-lg border p-4">
                    <div className="text-sm font-medium mb-2 text-muted-foreground">الضغط المستهدف</div>
                    <p className="text-xl font-bold">{patient.targetSystolic}/{patient.targetDiastolic}</p>
                  </div>
                  <div className="rounded-lg border p-4">
                    <div className="text-sm font-medium mb-2 text-muted-foreground">وزن السحب (كجم)</div>
                    <p className="text-xl font-bold">{patient.dryWeightKg || "—"}</p>
                  </div>
                </div>
              </TabsContent>

              <TabsContent value="labs" className="pt-4">
                <div className="rounded-md border">
                  <Table>
                    <TableHeader>
                      <TableRow>
                        <TableHead>المؤشر</TableHead>
                        <TableHead>القيمة</TableHead>
                        <TableHead>التاريخ</TableHead>
                      </TableRow>
                    </TableHeader>
                    <TableBody>
                      {labs && labs.length > 0 ? (
                        labs.map((lab) => (
                          <TableRow key={lab.id}>
                            <TableCell className="font-medium">{lab.indicatorCode}</TableCell>
                            <TableCell>{lab.value}</TableCell>
                            <TableCell>
                              {new Date(lab.recordedAt).toLocaleDateString('ar-SA')}
                            </TableCell>
                          </TableRow>
                        ))
                      ) : (
                        <TableRow>
                          <TableCell colSpan={3} className="text-center h-24 text-muted-foreground">
                            لا توجد فحوصات مسجلة.
                          </TableCell>
                        </TableRow>
                      )}
                    </TableBody>
                  </Table>
                </div>
              </TabsContent>

              <TabsContent value="meds" className="pt-4">
                <div className="rounded-md border">
                  <Table>
                    <TableHeader>
                      <TableRow>
                        <TableHead>الدواء</TableHead>
                        <TableHead>الجرعة</TableHead>
                        <TableHead>الحالة</TableHead>
                        <TableHead>تحذير كلوي</TableHead>
                      </TableRow>
                    </TableHeader>
                    <TableBody>
                      {medications && medications.length > 0 ? (
                        medications.map((med) => (
                          <TableRow key={med.id}>
                            <TableCell className="font-medium">{med.name}</TableCell>
                            <TableCell>{med.dose} - {med.frequency}</TableCell>
                            <TableCell>
                              <Badge variant={med.is_active ? 'success' : 'secondary'}>
                                {med.is_active ? 'نشط' : 'متوقف'}
                              </Badge>
                            </TableCell>
                            <TableCell>
                              {med.is_nephrotoxic ? (
                                <Badge variant="destructive">سام للكلية</Badge>
                              ) : (
                                <span className="text-muted-foreground text-xs">—</span>
                              )}
                            </TableCell>
                          </TableRow>
                        ))
                      ) : (
                        <TableRow>
                          <TableCell colSpan={4} className="text-center h-24 text-muted-foreground">
                            لا توجد أدوية مسجلة.
                          </TableCell>
                        </TableRow>
                      )}
                    </TableBody>
                  </Table>
                </div>
              </TabsContent>
            </Tabs>
          </CardContent>
        </Card>
      </div>
    </div>
  )
}
