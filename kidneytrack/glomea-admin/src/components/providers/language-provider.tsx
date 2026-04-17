"use client"

import React, { createContext, useContext, useState, useEffect } from "react"
import { t, Language } from "@/lib/i18n/translations"

type LanguageContextType = {
  lang: Language
  setLang: (lang: Language) => void
  tr: typeof t['en']
  isRTL: boolean
}

const LanguageContext = createContext<LanguageContextType | undefined>(undefined)

export function LanguageProvider({ children }: { children: React.ReactNode }) {
  const [lang, setLangState] = useState<Language>('en')

  useEffect(() => {
    const stored = localStorage.getItem('glomea-lang') as Language
    if (stored && (stored === 'en' || stored === 'ar')) {
      setLangState(stored)
      document.documentElement.dir = stored === 'ar' ? 'rtl' : 'ltr'
      document.documentElement.lang = stored
    }
  }, [])

  const setLang = (newLang: Language) => {
    localStorage.setItem('glomea-lang', newLang)
    // Set cookie for server-side access
    document.cookie = `glomea-lang=${newLang}; path=/; max-age=31536000; SameSite=Lax`
    setLangState(newLang)
    document.documentElement.dir = newLang === 'ar' ? 'rtl' : 'ltr'
    document.documentElement.lang = newLang
  }

  return (
    <LanguageContext.Provider value={{ 
      lang, 
      setLang, 
      tr: t[lang], 
      isRTL: lang === 'ar' 
    }}>
      {children}
    </LanguageContext.Provider>
  )
}

export function useLanguage() {
  const context = useContext(LanguageContext)
  if (context === undefined) {
    throw new Error("useLanguage must be used within a LanguageProvider")
  }
  return context
}
