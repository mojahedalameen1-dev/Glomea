"use client"

import { useState } from "react"
import { useLanguage } from "@/hooks/use-language"
import { 
  DropdownMenu, 
  DropdownMenuContent, 
  DropdownMenuItem, 
  DropdownMenuLabel, 
  DropdownMenuSeparator, 
  DropdownMenuTrigger 
} from "@/components/ui/dropdown-menu"
import { Button } from "@/components/ui/button"
import { MoreHorizontal, Eye, Edit, Trash2, Loader2, User } from "lucide-react"
import Link from "next/link"
import { deletePatient } from "@/app/actions/patients"
import { toast } from "sonner"
import { 
  AlertDialog, 
  AlertDialogAction, 
  AlertDialogCancel, 
  AlertDialogContent, 
  AlertDialogDescription, 
  AlertDialogFooter, 
  AlertDialogHeader, 
  AlertDialogTitle 
} from "@/components/ui/alert-dialog"

interface PatientActionMenuProps {
  patientId: string
  patientName: string
}

export function PatientActionMenu({ patientId, patientName }: PatientActionMenuProps) {
  const { tr, lang } = useLanguage()
  const [isDeleting, setIsDeleting] = useState(false)
  const [alertOpen, setAlertOpen] = useState(false)

  async function handleDelete() {
    setIsDeleting(true)
    const res = await deletePatient(patientId)
    setIsDeleting(false)
    setAlertOpen(false)

    if (res.success) {
      toast.success(lang === 'ar' ? "تم حذف المريض بنجاح" : "Patient deleted successfully")
    } else {
      toast.error(lang === 'ar' ? "خطأ في حذف المريض" : "Error deleting patient")
    }
  }

  return (
    <>
      <DropdownMenu>
        <DropdownMenuTrigger asChild>
          <Button variant="ghost" size="icon" className="h-8 w-8 rounded-xl border border-transparent hover:border-gray-100 dark:hover:border-white/5 transition-all group">
            <MoreHorizontal className="h-4 w-4 text-gray-400 group-hover:text-gray-900 dark:group-hover:text-white" />
          </Button>
        </DropdownMenuTrigger>
        <DropdownMenuContent align={lang === 'ar' ? 'start' : 'end'} className="rounded-2xl border border-border shadow-2xl bg-card p-1.5 w-[180px]">
          <DropdownMenuLabel className="text-[10px] font-black uppercase tracking-widest text-muted-foreground px-3 py-2">
            {lang === 'ar' ? "العمليات" : "Operations"}
          </DropdownMenuLabel>
          <DropdownMenuSeparator className="bg-border mx-1" />
          
          <DropdownMenuItem asChild className="rounded-xl font-bold py-2.5 cursor-pointer focus:bg-blue-50 focus:text-blue-600 dark:focus:bg-blue-900/20 dark:focus:text-blue-400 gap-3">
            <Link href={`/dashboard/patients/${patientId}`} className="flex items-center gap-2">
              <User className="h-4 w-4" />
              {lang === 'ar' ? "الملف الشخصي" : "Profile"}
            </Link>
          </DropdownMenuItem>
          
          <DropdownMenuItem className="rounded-xl font-bold py-2.5 cursor-pointer focus:bg-blue-50 focus:text-blue-600 dark:focus:bg-blue-900/20 dark:focus:text-blue-400 gap-3">
            <Edit className="h-4 w-4" />
            {lang === 'ar' ? "تعديل البيانات" : "Edit Profile"}
          </DropdownMenuItem>
          
          <DropdownMenuSeparator className="bg-border mx-1" />
          
          <DropdownMenuItem 
            onClick={() => setAlertOpen(true)}
            className="rounded-xl font-bold py-2.5 cursor-pointer text-rose-500 focus:bg-rose-50 focus:text-rose-600 dark:focus:bg-rose-900/20 dark:focus:text-rose-400 gap-3"
          >
            <Trash2 className="h-4 w-4" />
            {lang === 'ar' ? "حذف المريض" : "Delete Patient"}
          </DropdownMenuItem>
        </DropdownMenuContent>
      </DropdownMenu>

      <AlertDialog open={alertOpen} onOpenChange={setAlertOpen}>
        <AlertDialogContent className="rounded-[2rem] border-none shadow-2xl p-8 gap-6 max-w-md">
          <AlertDialogHeader>
            <AlertDialogTitle className="text-2xl font-black text-foreground">
              {lang === 'ar' ? "هل أنت متأكد؟" : "Are you absolutely sure?"}
            </AlertDialogTitle>
            <AlertDialogDescription className="text-muted-foreground font-medium leading-relaxed">
              {lang === 'ar' 
                ? `سيتم حذف بيانات المريض ${patientName} نهائياً من النظام. لا يمكن التراجع عن هذه العملية.`
                : `This will permanently delete ${patientName}'s profile and all associated medical records. This action cannot be undone.`
              }
            </AlertDialogDescription>
          </AlertDialogHeader>
          <AlertDialogFooter className="gap-3">
            <AlertDialogCancel className="rounded-2xl h-12 border border-border bg-muted/50 font-bold hover:bg-muted">
              {lang === 'ar' ? "إلغاء" : "Cancel"}
            </AlertDialogCancel>
            <AlertDialogAction 
              onClick={(e: React.MouseEvent) => {
                e.preventDefault()
                handleDelete()
              }}
              disabled={isDeleting}
              className="rounded-2xl h-12 bg-rose-600 hover:bg-rose-700 font-bold text-white border-none"
            >
              {isDeleting ? (
                <div className="flex items-center gap-2">
                  <span className="w-4 h-4 border-2 border-white/30 border-t-white rounded-full animate-spin" />
                  {lang === 'ar' ? "جاري الحذف..." : "Deleting..."}
                </div>
              ) : (
                lang === 'ar' ? "نعم، حذف المريض" : "Yes, delete patient"
              )}
            </AlertDialogAction>
          </AlertDialogFooter>
        </AlertDialogContent>
      </AlertDialog>
    </>
  )
}
