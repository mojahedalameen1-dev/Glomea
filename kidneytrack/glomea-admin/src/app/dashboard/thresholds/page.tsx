import { Card, CardContent, CardDescription, CardHeader, CardTitle, CardFooter } from "@/components/ui/card"
import { Label } from "@/components/ui/label"
import { Input } from "@/components/ui/input"
import { Button } from "@/components/ui/button"
import { Save, AlertCircle } from "lucide-react"
import { createClient } from "@/lib/supabase/server"
import { getI18n } from "@/lib/i18n/i18n-server"

export default async function ThresholdsPage() {
  const supabase = await createClient()
  const { tr, lang } = await getI18n()

  const { data: patients, error } = await supabase
    .from('Patient')
    .select('targetSystolic, targetDiastolic, potassiumLimitMg')

  if (error) {
    return (
      <div className="p-8 text-center bg-destructive/10 text-destructive rounded-lg">
        {lang === 'ar' ? 'حدث خطأ أثناء تحميل بيانات الحدود الصحية' : 'Error loading health threshold data'}: {error.message}
      </div>
    )
  }

  const count = patients?.length || 1
  const avgSystolic = Math.round((patients || []).reduce((sum, p) => sum + (p.targetSystolic || 130), 0) / count)
  const avgDiastolic = Math.round((patients || []).reduce((sum, p) => sum + (p.targetDiastolic || 80), 0) / count)
  const avgPotassiumLimit = Math.round((patients || []).reduce((sum, p) => sum + (p.potassiumLimitMg || 2000), 0) / count)

  return (
    <div className="space-y-6">
      <div>
        <h2 className="text-3xl font-bold tracking-tight">{tr.thresholdSettings}</h2>
        <p className="text-muted-foreground">{tr.thresholdSubtitle}</p>
      </div>

      <div className="grid gap-6 md:grid-cols-2">
        <Card className="border border-border shadow-sm dark:shadow-none bg-card rounded-[2rem] overflow-hidden">
          <CardHeader className="p-8 pb-4">
            <CardTitle className="text-xl font-black">{tr.bloodPressure}</CardTitle>
            <CardDescription className="font-medium">{tr.targetValues}</CardDescription>
          </CardHeader>
          <CardContent className="p-8 pt-0 space-y-6">
            <div className="grid gap-2">
              <Label className="font-bold text-muted-foreground">{tr.systolic} (Systolic)</Label>
              <Input type="number" disabled defaultValue={avgSystolic} className="bg-muted/50 border border-border h-11 rounded-xl font-bold" />
            </div>
            <div className="grid gap-2">
              <Label className="font-bold text-muted-foreground">{tr.diastolic} (Diastolic)</Label>
              <Input type="number" disabled defaultValue={avgDiastolic} className="bg-muted/50 border border-border h-11 rounded-xl font-bold" />
            </div>
          </CardContent>
          <CardFooter className="p-8 pt-0 flex-col items-start gap-4">
            <Button disabled className="w-full h-12 rounded-2xl bg-blue-600 hover:bg-blue-700 text-white font-bold gap-2">
              <Save className="h-4 w-4" />
              {tr.saveChanges} ({tr.comingSoon})
            </Button>
            <p className="text-[10px] text-muted-foreground font-bold uppercase tracking-widest leading-normal italic">
              * {lang === 'ar' ? 'ميزة تعديل الحدود العامة تتطلب إنشاء جدول الإعدادات.' : 'Global threshold modification requires a settings table.'}
            </p>
          </CardFooter>
        </Card>

        <Card className="border border-border shadow-sm dark:shadow-none bg-card rounded-[2rem] overflow-hidden">
          <CardHeader className="p-8 pb-4">
            <CardTitle className="text-xl font-black">{tr.labNutritionAlerts}</CardTitle>
            <CardDescription className="font-medium">{tr.defaultLimits}</CardDescription>
          </CardHeader>
          <CardContent className="p-8 pt-0 space-y-6">
            <div className="grid gap-2">
              <Label className="font-bold text-muted-foreground">{tr.creatinine}</Label>
              <Input type="number" step="0.1" disabled defaultValue={1.2} className="bg-muted/50 border border-border h-11 rounded-xl font-bold" />
            </div>
            <div className="grid gap-2">
              <Label className="font-bold text-muted-foreground">{tr.potassiumLimit}</Label>
              <Input type="number" step="10" disabled defaultValue={avgPotassiumLimit} className="bg-muted bg-muted/50 border border-border h-11 rounded-xl font-bold" />
            </div>
          </CardContent>
          <CardFooter className="p-8 pt-0">
             <div className="flex items-start gap-3 p-4 bg-amber-50 dark:bg-amber-900/10 rounded-2xl border border-amber-100 dark:border-amber-900/20 text-sm text-amber-700 dark:text-amber-400 font-medium">
                <AlertCircle className="h-5 w-5 shrink-0" />
                <span>{tr.viewOnlyNote}</span>
             </div>
          </CardFooter>
        </Card>
      </div>
    </div>
  )
}
