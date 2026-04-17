"use client"

import { createContext, useContext, useState, useEffect, useRef, type ReactNode } from "react"
import { createClient } from "@/lib/supabase/client"

interface AdminData {
  fullName: string
  isSuperAdmin: boolean
}

interface AdminContextType {
  admin: AdminData | null
  loading: boolean
  signOut: () => Promise<void>
}

const AdminContext = createContext<AdminContextType>({
  admin: null,
  loading: true,
  signOut: async () => {},
})

export function useAdmin() {
  return useContext(AdminContext)
}

export function AdminProvider({ children }: { children: ReactNode }) {
  const [admin, setAdmin] = useState<AdminData | null>(null)
  const [loading, setLoading] = useState(true)
  const fetchedRef = useRef(false)

  useEffect(() => {
    // Guard against React Strict Mode double-mount
    if (fetchedRef.current) return
    fetchedRef.current = true

    const supabase = createClient()

    async function getAdmin() {
      try {
        const { data: { user } } = await supabase.auth.getUser()
        if (user) {
          const { data } = await supabase
            .from('admin_users')
            .select('full_name, is_super_admin')
            .eq('id', user.id)
            .single()

          if (data) {
            setAdmin({
              fullName: data.full_name,
              isSuperAdmin: data.is_super_admin,
            })
          }
        }
      } catch (err) {
        console.warn("Admin fetch failed:", err)
      } finally {
        setLoading(false)
      }
    }

    getAdmin()
  }, [])

  const signOut = async () => {
    const supabase = createClient()
    await supabase.auth.signOut()
  }

  return (
    <AdminContext.Provider value={{ admin, loading, signOut }}>
      {children}
    </AdminContext.Provider>
  )
}
