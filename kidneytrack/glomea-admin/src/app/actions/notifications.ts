"use server"

import { createClient } from "@/lib/supabase/server"
import { requireAdmin } from "@/lib/require-admin"
import { revalidatePath } from "next/cache"

export async function createAlert(formData: {
  title: string
  content: string
  type: string
  priority: string
  status: string
  patientId?: string
}) {
  try {
    await requireAdmin()
  } catch (e: any) {
    return { success: false, error: e.message }
  }

  const supabase = await createClient()
  const { data, error } = await supabase
    .from('Alert')
    .insert([{
      ...formData,
      id: crypto.randomUUID(),
      created_at: new Date().toISOString(),
      updated_at: new Date().toISOString()
    }])
    .select()

  if (error) {
    console.error("Error creating alert:", error)
    return { success: false, error: error.message }
  }

  revalidatePath('/dashboard/notifications')
  revalidatePath('/dashboard')
  return { success: true, data }
}

export async function markAlertAsRead(id: string) {
  try {
    await requireAdmin()
  } catch (e: any) {
    return { success: false, error: e.message }
  }

  const supabase = await createClient()
  const { error } = await supabase
    .from('Alert')
    .update({ status: 'read', updated_at: new Date().toISOString() })
    .eq('id', id)

  if (error) {
    console.error("Error updating alert status:", error)
    return { success: false, error: error.message }
  }

  revalidatePath('/dashboard/notifications')
  revalidatePath('/dashboard')
  return { success: true }
}

export async function deleteAlert(id: string) {
  try {
    await requireAdmin()
  } catch (e: any) {
    return { success: false, error: e.message }
  }

  const supabase = await createClient()
  const { error } = await supabase
    .from('Alert')
    .delete()
    .eq('id', id)

  if (error) {
    console.error("Error deleting alert:", error)
    return { success: false, error: error.message }
  }

  revalidatePath('/dashboard/notifications')
  revalidatePath('/dashboard')
  return { success: true }
}
