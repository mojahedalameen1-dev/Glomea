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
import { UserPlus, Shield, ShieldCheck } from "lucide-react"
import { createClient } from "@/lib/supabase/server"
import { getI18n } from "@/lib/i18n/i18n-server"
import { EmptyState } from "@/components/ui/empty-state"

export default async function StaffPage() {
  const supabase = await createClient()
  const { tr, lang } = await getI18n()
  
  const { data: staff, error } = await supabase
    .from('admin_users')
    .select('id, fullName:full_name, isSuperAdmin:is_super_admin, isActive:is_active, username')
    .order('created_at', { ascending: false })

  if (error) {
    return (
      <div className="p-8 text-center bg-destructive/10 text-destructive rounded-lg">
        {lang === 'ar' ? 'حدث خطأ أثناء تحميل بيانات الطاقم' : 'Error loading staff data'}: {error.message}
      </div>
    )
  }

  return (
    <div className="space-y-6">
      <div className="flex items-center justify-between">
        <div>
          <h2 className="text-3xl font-bold tracking-tight">{tr.staffManagement}</h2>
          <p className="text-muted-foreground">{tr.staffSubtitle}</p>
        </div>
        <Button className="gap-2">
          <UserPlus className="h-4 w-4" />
          {tr.addNewMember}
        </Button>
      </div>

      <div className="rounded-[2rem] border border-border shadow-sm bg-card overflow-hidden">
        <Table>
          <TableHeader className="bg-muted/50 border-b border-border">
            <TableRow className="border-none hover:bg-transparent">
              <TableHead className={lang === 'ar' ? "text-right" : "text-left"}>{tr.name}</TableHead>
              <TableHead className={lang === 'ar' ? "text-right" : "text-left"}>{tr.username}</TableHead>
              <TableHead className={lang === 'ar' ? "text-right" : "text-left"}>{tr.status}</TableHead>
              <TableHead className={lang === 'ar' ? "text-right" : "text-left"}>{tr.role}</TableHead>
              <TableHead className="w-[100px]">{tr.actions}</TableHead>
            </TableRow>
          </TableHeader>
          <TableBody>
            {staff && staff.length > 0 ? (
              staff.map((member) => (
                <TableRow key={member.id} className="border-border hover:bg-muted/50 transition-colors">
                  <TableCell className="font-medium text-foreground py-4">{member.fullName || (lang === 'ar' ? "غير متوفر" : "N/A")}</TableCell>
                  <TableCell>{member.username}</TableCell>
                  <TableCell>
                    <Badge variant={member.isActive ? "success" : "secondary"}>
                      {member.isActive ? tr.active : tr.inactive}
                    </Badge>
                  </TableCell>
                  <TableCell>
                    {member.isSuperAdmin ? (
                      <Badge variant="default" className="gap-1 bg-blue-100 dark:bg-blue-900/30 text-blue-600 dark:text-blue-400 border-none font-bold">
                        <ShieldCheck className="h-3 w-3" />
                        {tr.superAdmin}
                      </Badge>
                    ) : (
                      <Badge variant="secondary" className="gap-1 font-bold">
                        <Shield className="h-3 w-3" />
                        {tr.user}
                      </Badge>
                    )}
                  </TableCell>
                  <TableCell>
                    <Button variant="ghost" size="sm" className="font-bold text-xs text-blue-600">
                      {tr.update}
                    </Button>
                  </TableCell>
                </TableRow>
              ))
            ) : (
              <TableRow>
                <TableCell colSpan={5} className="p-0">
                  <EmptyState 
                    title={tr.noData} 
                    description={lang === 'ar' ? 'لا يوجد طاقم طبي مسجل.' : 'No staff members registered.'} 
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
