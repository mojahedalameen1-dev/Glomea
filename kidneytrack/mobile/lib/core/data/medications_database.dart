const List<Map<String, dynamic>> knownMedications = [
  // أدوية ضغط الدم
  {
    'name': 'Lisinopril',
    'nameAr': 'ليسينوبريل',
    'category': 'ACE Inhibitor',
    'nephrotoxic': false,
    'doseAdjustment': true,
    'warning': 'قد يرفع البوتاسيوم — راقب مستوى البوتاسيوم بانتظام'
  },
  {
    'name': 'Amlodipine',
    'nameAr': 'أملوديبين',
    'category': 'CCB',
    'nephrotoxic': false,
    'doseAdjustment': false,
    'warning': null
  },
  {
    'name': 'Furosemide',
    'nameAr': 'فيوروسيميد (لازيكس)',
    'category': 'Diuretic',
    'nephrotoxic': false,
    'doseAdjustment': true,
    'warning': 'قد يحتاج جرعة أعلى في الفشل الكلوي المتقدم'
  },

  // مسكنات — تحذير حرج
  {
    'name': 'Ibuprofen',
    'nameAr': 'إيبوبروفين',
    'category': 'NSAID',
    'nephrotoxic': true,
    'doseAdjustment': false,
    'warning': 'يضر الكلى — يجب تجنبه في الفشل الكلوي'
  },
  {
    'name': 'Diclofenac',
    'nameAr': 'ديكلوفيناك',
    'category': 'NSAID',
    'nephrotoxic': true,
    'doseAdjustment': false,
    'warning': 'يضر الكلى — يجب تجنبه في الفشل الكلوي'
  },
  {
    'name': 'Paracetamol',
    'nameAr': 'باراسيتامول',
    'category': 'Analgesic',
    'nephrotoxic': false,
    'doseAdjustment': false,
    'safeChoice': true,
    'warning': 'الخيار الآمن للألم لمرضى الكلى بجرعات معتدلة'
  },

  // سكري
  {
    'name': 'Metformin',
    'nameAr': 'ميتفورمين',
    'category': 'Antidiabetic',
    'nephrotoxic': false,
    'doseAdjustment': true,
    'warning': 'يُوقف عند تدهور وظائف الكلى — اسأل طبيبك'
  },

  // مضادات حيوية
  {
    'name': 'Amoxicillin',
    'nameAr': 'أموكسيسيلين',
    'category': 'Antibiotic',
    'nephrotoxic': false,
    'doseAdjustment': true,
    'warning': 'يحتاج تعديل جرعة في الفشل الكلوي — اسأل طبيبك أو صيدلانيك'
  },
  {
    'name': 'Gentamicin',
    'nameAr': 'جنتاميسين',
    'category': 'Antibiotic',
    'nephrotoxic': true,
    'doseAdjustment': true,
    'warning': 'سام للكلى جداً — يُستخدم فقط تحت إشراف طبي صارم'
  },

  // أدوية الغسيل
  {
    'name': 'Calcium Carbonate',
    'nameAr': 'كربونات الكالسيوم',
    'nephrotoxic': false,
    'doseAdjustment': false,
    'warning': 'رابط فوسفات — يُؤخذ مع الطعام دائماً'
  },
  {
    'name': 'Sevelamer',
    'nameAr': 'سيفيلامر',
    'nephrotoxic': false,
    'doseAdjustment': false,
    'warning': 'رابط فوسفات بدون كالسيوم — يُؤخذ مع الطعام'
  },
  {
    'name': 'Epoetin alfa',
    'nameAr': 'إريثروبويتين (EPO)',
    'nephrotoxic': false,
    'doseAdjustment': false,
    'warning': 'لعلاج فقر الدم الكلوي — راقب ضغط الدم أثناء الاستخدام'
  },
];
