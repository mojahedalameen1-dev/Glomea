export interface Patient {
  id: string
  full_name: string
  created_at: string
  phone_number: string | null
  user_id: string | null
  // New columns added in migration:
  birthDate: string | null
  heightCm: number | null
  weightKg: number | null
  kidneyStage: number | null
  dialysisStatus: string | null
  targetSystolic: number | null
  targetDiastolic: number | null
  dryWeightKg: number | null
  email: string | null
}


export interface LabResult {
  id: string
  patientId: string
  indicatorCode: string
  value: number
  recordedAt: string
}

export interface Medication {
  id: string
  patient_id: string
  name: string
  dose: string
  frequency: string
  times: string[]
  start_date: string
  end_date: string | null
  is_active: boolean
  medication_key: string | null
  is_nephrotoxic: boolean
  needs_dose_adjustment: boolean
  renal_warning: string | null
}

export interface AdminUser {
  id: string
  email: string
  fullName: string
  is_super_admin: boolean
}
