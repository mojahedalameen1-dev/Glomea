import { cookies } from "next/headers"
import { t, Language } from "./translations"

export async function getI18n() {
  const cookieStore = await cookies()
  const lang = (cookieStore.get('glomea-lang')?.value as Language) || 'en'
  
  return {
    lang,
    tr: t[lang],
    isRTL: lang === 'ar'
  }
}

export const getTranslations = getI18n
