import { Card, CardContent, CardDescription, CardHeader, CardTitle, CardFooter } from "@/components/ui/card"
import { Button } from "@/components/ui/button"
import { Label } from "@/components/ui/label"
import { Shield, User, Settings2 } from "lucide-react"
import { createClient } from "@/lib/supabase/server"
import { Badge } from "@/components/ui/badge"

export default async function SettingsPage() {
  const supabase = await createClient()
  
  // Get current user session
  const { data: { user } } = await supabase.auth.getUser()
  
  // Fetch specific admin data
  const { data: adminProfile } = await supabase
    .from('admin_users')
    .select('fullName:full_name, username, isSuperAdmin:is_super_admin')
    .eq('id', user?.id)
    .single()

  // Fetch roles count
  const { count: rolesCount } = await supabase
    .from('admin_roles')
    .select('id', { count: 'exact', head: true })

  return (
    <div className="space-y-6">
      <div>
        <h2 className="text-3xl font-bold tracking-tight">الإعدادات</h2>
        <p className="text-muted-foreground">إدارة إعدادات النظام وتفضيلات المنصة.</p>
      </div>

      <div className="grid gap-6 md:grid-cols-2">
        <Card className="border border-border shadow-sm dark:shadow-none bg-card rounded-[2rem] overflow-hidden">
          <CardHeader>
            <div className="flex items-center gap-2">
              <User className="h-5 w-5 text-primary" />
              <CardTitle>الملف الشخصي</CardTitle>
            </div>
            <CardDescription>معلومات حسابك الحالي وصلاحيات الوصول.</CardDescription>
          </CardHeader>
          <CardContent className="space-y-4">
             <div className="flex flex-col gap-1">
                <Label className="text-muted-foreground">الاسم الكامل</Label>
                <p className="font-medium text-lg">{adminProfile?.fullName || "غير مسجل"}</p>
             </div>
             <div className="flex flex-col gap-1">
                <Label className="text-muted-foreground">اسم المستخدم</Label>
                <p className="font-medium">{adminProfile?.username || user?.email}</p>
             </div>
             <div className="flex items-center justify-between pt-2">
                <Label>نوع الحساب</Label>
                <Badge variant={adminProfile?.isSuperAdmin ? "default" : "secondary"}>
                   {adminProfile?.isSuperAdmin ? "سوبر أدمن" : "مدير نظام"}
                </Badge>
             </div>
          </CardContent>
          <CardFooter className="border-t pt-4">
             <Button variant="outline" size="sm">تعديل الملف الشخصي</Button>
          </CardFooter>
        </Card>

        <Card className="border border-border shadow-sm dark:shadow-none bg-card rounded-[2rem] overflow-hidden">
          <CardHeader>
            <div className="flex items-center gap-2">
              <Settings2 className="h-5 w-5 text-primary" />
              <CardTitle>نظرة عامة على النظام</CardTitle>
            </div>
            <CardDescription>إحصائيات إدارية سريعة.</CardDescription>
          </CardHeader>
          <CardContent className="space-y-4">
             <div className="flex items-center justify-between">
                <Label>عدد الأدوار المعرفة</Label>
                <Badge variant="outline">{rolesCount || 0}</Badge>
             </div>
             <div className="flex items-center justify-between">
                <Label>اللغة الافتراضية</Label>
                <Badge variant="outline">العربية (SA)</Badge>
             </div>
          </CardContent>
          <CardFooter className="border-t pt-4">
              <div className="flex items-center gap-2 text-xs text-muted-foreground">
                <Shield className="h-3 w-3" />
                <span>إصدار النظام: 1.0.0-stable</span>
              </div>
          </CardFooter>
        </Card>
      </div>
    </div>
  )
}
