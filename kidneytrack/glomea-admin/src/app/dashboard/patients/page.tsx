import { 
  Table, 
  TableBody, 
  TableCell, 
  TableHead, 
  TableHeader, 
  TableRow 
} from "@/components/ui/table"
import { Badge } from "@/components/ui/badge"
import { Input } from "@/components/ui/input"
import { Search } from "lucide-react"
import { createClient } from "@/lib/supabase/server"
import { getI18n } from "@/lib/i18n/i18n-server"
import { AddPatientSheet } from "@/components/dashboard/patients/add-patient-sheet"
import { PatientActionMenu } from "@/components/dashboard/patients/patient-action-menu"
import { EmptyState } from "@/components/ui/empty-state"

export default async function PatientsPage() {
  const supabase = await createClient()
  const { tr, lang } = await getI18n()

  const { data: patients, error } = await supabase
    .from('Patient')
    .select('id, full_name, phone_number, kidneyStage, dialysisStatus, created_at')
    .order('created_at', { ascending: false })
    .limit(100)

  if (error) {
    return (
      <div className="p-8 text-center bg-destructive/10 text-destructive rounded-lg">
          {lang === 'ar' ? 'حدث خطأ أثناء تحميل بيانات المرضى' : 'Error loading patients data'}: {error.message}
      </div>
    )
  }

  return (
    <div className="space-y-6">
      <div className="flex items-center justify-between">
        <div>
          <h2 className="text-3xl font-bold tracking-tight">{tr.patients}</h2>
          <p className="text-muted-foreground">{lang === 'ar' ? 'عرض وإدارة كافة المرضى المسجلين في النظام.' : 'View and manage all patients registered in the system.'}</p>
        </div>
        <AddPatientSheet />
      </div>

      <div className="flex items-center gap-4">
        <div className="relative flex-1">
          <Search className={lang === 'ar' ? "absolute right-3 top-1/2 h-4 w-4 -translate-y-1/2 text-muted-foreground" : "absolute left-3 top-1/2 h-4 w-4 -translate-y-1/2 text-muted-foreground"} />
          <Input 
            placeholder={tr.searchPlaceholder}
            className={lang === 'ar' ? "pr-10 text-right h-12 rounded-xl border-border bg-muted/50" : "pl-10 text-left h-12 rounded-xl border-border bg-muted/50"}
          />
        </div>
      </div>

      <div className="rounded-[2rem] border border-border shadow-sm bg-card overflow-hidden">
        <Table>
          <TableHeader className="bg-muted/50 border-b border-border">
            <TableRow className="border-none hover:bg-transparent">
              <TableHead className={lang === 'ar' ? "text-right font-black uppercase text-[10px] tracking-widest py-5" : "text-left font-black uppercase text-[10px] tracking-widest py-5"}>{tr.name}</TableHead>
              <TableHead className={lang === 'ar' ? "text-right font-black uppercase text-[10px] tracking-widest py-5" : "text-left font-black uppercase text-[10px] tracking-widest py-5"}>{lang === 'ar' ? 'رقم الهاتف' : 'Phone'}</TableHead>
              <TableHead className={lang === 'ar' ? "text-right font-black uppercase text-[10px] tracking-widest py-5" : "text-left font-black uppercase text-[10px] tracking-widest py-5"}>{lang === 'ar' ? 'المرحلة' : 'Stage'}</TableHead>
              <TableHead className={lang === 'ar' ? "text-right font-black uppercase text-[10px] tracking-widest py-5" : "text-left font-black uppercase text-[10px] tracking-widest py-5"}>{tr.status}</TableHead>
              <TableHead className={lang === 'ar' ? "text-right font-black uppercase text-[10px] tracking-widest py-5" : "text-left font-black uppercase text-[10px] tracking-widest py-5"}>{tr.registrationDate}</TableHead>
              <TableHead className="w-[100px] font-black uppercase text-[10px] tracking-widest py-5">{tr.actions}</TableHead>
            </TableRow>
          </TableHeader>
          <TableBody>
            {patients && patients.length > 0 ? (
              patients.map((patient) => (
                <TableRow key={patient.id} className="border-border hover:bg-muted/50 transition-colors">
                  <TableCell className="font-bold text-foreground py-4">
                    {patient.full_name ?? '—'}
                  </TableCell>
                  <TableCell className="font-medium text-muted-foreground">{patient.phone_number || (lang === 'ar' ? "غير متوفر" : "N/A")}</TableCell>
                  <TableCell>
                    <Badge variant="outline" className="rounded-lg border-blue-100 dark:border-blue-900/30 bg-blue-50/50 dark:bg-blue-900/10 text-blue-600 dark:text-blue-400 font-bold px-2 py-0.5">
                      {patient.kidneyStage || (lang === 'ar' ? "غير محدد" : "Unset")}
                    </Badge>
                  </TableCell>
                  <TableCell>
                    <Badge variant={patient.dialysisStatus === 'Active' ? 'success' : 'secondary'} className="rounded-lg font-bold px-2 py-0.5">
                      {patient.dialysisStatus || (lang === 'ar' ? "منتظم" : "Regular")}
                    </Badge>
                  </TableCell>
                  <TableCell className="text-muted-foreground font-medium">
                    {new Date(patient.created_at).toLocaleDateString(lang === 'ar' ? 'ar-SA' : 'en-US')}
                  </TableCell>
                  <TableCell>
                    <PatientActionMenu patientId={patient.id} patientName={patient.full_name ?? '—'} />
                  </TableCell>
                </TableRow>
              ))
            ) : (
              <TableRow>
                <TableCell colSpan={6} className="p-0">
                  <EmptyState 
                    title={tr.noData} 
                    description={lang === 'ar' ? 'لا يوجد مرضى مضافين حالياً.' : 'No patients added yet.'} 
                    className="border-none rounded-none bg-transparent"
                  />
                </TableCell>
              </TableRow>
            )}
          </TableBody>
        </Table>
      </div>
    </div>
  )
}
