"use client"

import { useState } from "react"
import { useLanguage } from "@/hooks/use-language"
import { 
  Sheet, 
  SheetContent, 
  SheetHeader, 
  SheetTitle, 
  SheetTrigger,
  SheetDescription,
  SheetFooter
} from "@/components/ui/sheet"
import { Button } from "@/components/ui/button"
import { Input } from "@/components/ui/input"
import { Label } from "@/components/ui/label"
import { 
  Select, 
  SelectContent, 
  SelectItem, 
  SelectTrigger, 
  SelectValue 
} from "@/components/ui/select"
import { UserPlus, Loader2 } from "lucide-react"
import { createPatient } from "@/app/actions/patients"
import { toast } from "sonner"

export function AddPatientSheet() {
  const { tr, lang } = useLanguage()
  const [open, setOpen] = useState(false)
  const [loading, setLoading] = useState(false)

  async function handleSubmit(event: React.FormEvent<HTMLFormElement>) {
    event.preventDefault()
    setLoading(true)

    const formData = new FormData(event.currentTarget)
    const data = {
      firstName: formData.get("firstName") as string,
      lastName: formData.get("lastName") as string,
      fullName: `${formData.get("firstName")} ${formData.get("lastName")}`,
      phone: formData.get("phone") as string || undefined,
      email: formData.get("email") as string || undefined,
      kidneyStage: formData.get("kidneyStage") as string || undefined,
      dialysisStatus: formData.get("dialysisStatus") as string || undefined,
      gender: formData.get("gender") as string || undefined,
    }

    const res = await createPatient(data)
    setLoading(false)

    if (res.success) {
      toast.success(lang === 'ar' ? "تم إضافة المريض بنجاح" : "Patient added successfully")
      setOpen(false)
    } else {
      toast.error(lang === 'ar' ? "خطأ في إضافة المريض" : "Error adding patient")
    }
  }

  return (
    <Sheet open={open} onOpenChange={setOpen}>
      <SheetTrigger asChild>
        <Button className="gap-2 bg-blue-600 hover:bg-blue-700 text-white rounded-xl shadow-lg shadow-blue-500/20">
          <UserPlus className="h-4 w-4" />
          {tr.addPatient}
        </Button>
      </SheetTrigger>
      <SheetContent side={lang === 'ar' ? 'right' : 'right'} className="w-[400px] sm:w-[540px] border-l border-border shadow-2xl bg-card overflow-y-auto">
        <SheetHeader className="pb-6">
          <SheetTitle className="text-2xl font-bold tracking-tight">{tr.addPatient}</SheetTitle>
          <SheetDescription>
            {lang === 'ar' ? 'أدخل تفاصيل المريض الجديد هنا.' : 'Enter the details for the new patient below.'}
          </SheetDescription>
        </SheetHeader>

        <form onSubmit={handleSubmit} className="space-y-6 py-6">
          <div className="grid grid-cols-2 gap-4">
            <div className="space-y-2">
              <Label htmlFor="firstName" className="font-bold">{lang === 'ar' ? 'الاسم الأول' : 'First Name'}</Label>
              <Input id="firstName" name="firstName" placeholder={lang === 'ar' ? "أحمد" : "John"} required className="rounded-xl border-border" />
            </div>
            <div className="space-y-2">
              <Label htmlFor="lastName" className="font-bold">{lang === 'ar' ? 'اسم العائلة' : 'Last Name'}</Label>
              <Input id="lastName" name="lastName" placeholder={lang === 'ar' ? "محمد" : "Doe"} required className="rounded-xl border-border" />
            </div>
          </div>

          <div className="space-y-2">
            <Label htmlFor="phone" className="font-bold">{lang === 'ar' ? 'رقم الهاتف' : 'Phone'}</Label>
            <Input id="phone" name="phone" placeholder="+966 50 000 0000" className="rounded-xl border-border" />
          </div>

          <div className="space-y-2">
            <Label htmlFor="email" className="font-bold">{lang === 'ar' ? 'البريد الإلكتروني' : 'Email'}</Label>
            <Input id="email" name="email" type="email" placeholder="example@gmail.com" className="rounded-xl border-border" />
          </div>

          <div className="grid grid-cols-2 gap-4">
            <div className="space-y-2">
              <Label htmlFor="gender" className="font-bold">{lang === 'ar' ? 'الجنس' : 'Gender'}</Label>
              <Select name="gender">
                <SelectTrigger className="rounded-xl border-border">
                  <SelectValue placeholder={lang === 'ar' ? "اختر" : "Select"} />
                </SelectTrigger>
                <SelectContent className="rounded-xl">
                  <SelectItem value="MALE">{lang === 'ar' ? "ذكر" : "Male"}</SelectItem>
                  <SelectItem value="FEMALE">{lang === 'ar' ? "أنثى" : "Female"}</SelectItem>
                </SelectContent>
              </Select>
            </div>
            
            <div className="space-y-2">
              <Label htmlFor="kidneyStage" className="font-bold">{lang === 'ar' ? 'مرحلة المرض' : 'Kidney Stage'}</Label>
              <Select name="kidneyStage">
                <SelectTrigger className="rounded-xl border-border">
                  <SelectValue placeholder={lang === 'ar' ? "اختر" : "Select"} />
                </SelectTrigger>
                <SelectContent className="rounded-xl">
                  <SelectItem value="STAGE_3">{lang === 'ar' ? "المرحلة 3" : "Stage 3"}</SelectItem>
                  <SelectItem value="STAGE_4">{lang === 'ar' ? "المرحلة 4" : "Stage 4"}</SelectItem>
                  <SelectItem value="STAGE_5">{lang === 'ar' ? "المرحلة 5" : "Stage 5"}</SelectItem>
                  <SelectItem value="POST_TRANSPLANT">{lang === 'ar' ? "بعد الزراعة" : "Post Transplant"}</SelectItem>
                </SelectContent>
              </Select>
            </div>
          </div>

          <div className="space-y-2">
            <Label htmlFor="dialysisStatus" className="font-bold">{lang === 'ar' ? 'حالة الغسيل' : 'Dialysis Status'}</Label>
            <Select name="dialysisStatus">
              <SelectTrigger className="rounded-xl border-border">
                <SelectValue placeholder={lang === 'ar' ? "اختر" : "Select"} />
              </SelectTrigger>
              <SelectContent className="rounded-xl">
                <SelectItem value="NON_DIALYSIS">{lang === 'ar' ? "لا يوجد غسيل" : "Non-Dialysis"}</SelectItem>
                <SelectItem value="HEMODIALYSIS">{lang === 'ar' ? "غسيل دموي" : "Hemodialysis"}</SelectItem>
                <SelectItem value="PERITONEAL">{lang === 'ar' ? "غسيل بريتوني" : "Peritoneal"}</SelectItem>
              </SelectContent>
            </Select>
          </div>

          <SheetFooter className="pt-8">
            <Button 
                type="submit" 
                disabled={loading}
                className="w-full bg-blue-600 hover:bg-blue-700 text-white rounded-xl h-12 shadow-lg shadow-blue-500/20"
            >
              {loading ? <Loader2 className="h-4 w-4 animate-spin" /> : (lang === 'ar' ? "حفظ المريض" : "Save Patient")}
            </Button>
          </SheetFooter>
        </form>
      </SheetContent>
    </Sheet>
  )
}
