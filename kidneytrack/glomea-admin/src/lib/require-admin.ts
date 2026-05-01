import { createClient } from '@/lib/supabase/server'

/**
 * Verifies the current user is authenticated AND exists in admin_users.
 * Call at the top of every Server Action that mutates data.
 * Returns the admin row on success, throws an Error on failure.
 */
export async function requireAdmin() {
  const supabase = await createClient()

  const {
    data: { user },
    error: authError,
  } = await supabase.auth.getUser()

  if (authError || !user) {
    throw new Error('UNAUTHORIZED: No active session')
  }

  const { data: adminRow, error: adminError } = await supabase
    .from('admin_users')
    .select('id, full_name, is_super_admin, auth_user_id')
    .eq('auth_user_id', user.id)
    .single()

  if (adminError || !adminRow) {
    throw new Error('FORBIDDEN: User is not an admin')
  }

  return { user, admin: adminRow }
}
