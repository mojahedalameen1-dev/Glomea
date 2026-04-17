import { createClient } from '@supabase/supabase-js'

const supabaseUrl = process.env.NEXT_PUBLIC_SUPABASE_URL || ''
const supabaseKey = process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY || ''
const supabase = createClient(supabaseUrl, supabaseKey)

async function checkAlert() {
  const { data, error } = await supabase.from('Alert').select('*').limit(1)
  if (error) {
    console.error('Error:', error)
  } else {
    console.log('Alert columns:', data && data.length > 0 ? Object.keys(data[0]) : 'No data, but query succeeded')
  }

  const { data: act, error: actErr } = await supabase.from('ActivityLog').select('*').limit(1)
  if (actErr) {
    console.error('ActivityLog Error:', actErr)
  } else {
    console.log('ActivityLog columns:', act && act.length > 0 ? Object.keys(act[0]) : 'No data, but query succeeded')
  }
}

checkAlert()
