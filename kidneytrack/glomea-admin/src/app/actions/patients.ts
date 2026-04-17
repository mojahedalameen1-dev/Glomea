"use server"

import { createClient } from "@/lib/supabase/server"
import { revalidatePath } from "next/cache"
import { logActivity } from "@/lib/activity-log"

export async function createPatient(formData: any) {
  const supabase = await createClient()
  const { data: { user } } = await supabase.auth.getUser()
  
  if (!user) return { success: false, error: "Unauthorized" }

  const { data, error } = await supabase
    .from('Patient')
    .insert([{
      ...formData,
      id: crypto.randomUUID(),
      created_at: new Date().toISOString()
    }])
    .select()

  if (error) {
    console.error("Error creating patient:", error)
    return { success: false, error: error.message }
  }

  // Log the activity
  await logActivity({
    userId: user.id,
    userName: user.email ?? 'Admin',
    action: 'CREATE',
    section: 'patients',
    details: { patientName: data[0].full_name }
  })

  revalidatePath('/dashboard/patients')
  revalidatePath('/dashboard')
  return { success: true, data }
}

export async function updatePatient(id: string, formData: any) {
  const supabase = await createClient()
  const { data: { user } } = await supabase.auth.getUser()

  if (!user) return { success: false, error: "Unauthorized" }

  const { data, error } = await supabase
    .from('Patient')
    .update({
      ...formData
    })
    .eq('id', id)
    .select()

  if (error) {
    console.error("Error updating patient:", error)
    return { success: false, error: error.message }
  }

  // Log the activity
  await logActivity({
    userId: user.id,
    userName: user.email ?? 'Admin',
    action: 'UPDATE',
    section: 'patients',
    details: { patientName: data[0].full_name }
  })

  revalidatePath('/dashboard/patients')
  revalidatePath(`/dashboard/patients/${id}`)
  revalidatePath('/dashboard')
  return { success: true, data }
}

export async function deletePatient(id: string) {
  const supabase = await createClient()
  const { data: { user } } = await supabase.auth.getUser()

  if (!user) return { success: false, error: "Unauthorized" }

  // First get the name for the log
  const { data: patient } = await supabase
    .from('Patient')
    .select('full_name')
    .eq('id', id)
    .single()

  const { error } = await supabase
    .from('Patient')
    .delete()
    .eq('id', id)

  if (error) {
    console.error("Error deleting patient:", error)
    return { success: false, error: error.message }
  }

  // Log the activity
  if (patient) {
    await logActivity({
      userId: user.id,
      userName: user.email ?? 'Admin',
      action: 'DELETE',
      section: 'patients',
      details: { patientName: patient.full_name }
    })
  }

  revalidatePath('/dashboard/patients')
  revalidatePath('/dashboard')
  return { success: true }
}
