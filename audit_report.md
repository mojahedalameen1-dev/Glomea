# 🔍 تقرير التدقيق الشامل (Audit Report) — Glomea App

---

## المرحلة الثانية: تقرير الأخطاء

---

### ١. Auth Flow (تدفق المصادقة)

---

#### 🐛 BUG-01: `authNotifierProvider` لا يُعيد البناء تلقائياً عند تغيُّر حالة المصادقة

| الحقل | التفاصيل |
|---|---|
| 📁 الملف | [auth_provider.dart](file:///c:/Projects/renal_app/kidneytrack/mobile/lib/features/auth/providers/auth_provider.dart) — السطر 48-61 |
| 🔴 المشكلة | `AuthNotifier.build()` يُنفَّذ **مرة واحدة فقط** عند إنشاء الـ Provider. لا يوجد ربط بـ `onAuthStateChange` داخل [build()](file:///c:/Projects/renal_app/kidneytrack/mobile/lib/main.dart#49-67). عند تسجيل الدخول، يُطلق `authStateProvider` (StreamProvider) حدثاً جديداً، لكن `authNotifierProvider` لا يستمع لهذا الحدث ولا يُعيد جلب بيانات المريض تلقائياً. |
| 💡 السبب | استخدام `AsyncNotifier` بمعزل عن `StreamProvider`. يحتاج [build()](file:///c:/Projects/renal_app/kidneytrack/mobile/lib/main.dart#49-67) أن **يستمع** (`listen`) لـ `authStateProvider` ليُعيد تنفيذ [_fetchPatient()](file:///c:/Projects/renal_app/kidneytrack/mobile/lib/features/auth/providers/auth_provider.dart#77-106) عند كل تغيير. |
| ⚡ الخطورة | **حرج** — بعد [register()](file:///c:/Projects/renal_app/kidneytrack/mobile/lib/features/auth/providers/auth_provider.dart#107-124) مثلاً، `authNotifierProvider` قد يظل `null` لأنه لا يعلم بالـ session الجديدة. |

---

#### 🐛 BUG-02: [logout()](file:///c:/Projects/renal_app/kidneytrack/mobile/lib/features/auth/providers/auth_provider.dart#136-141) لا يُصفِّر الـ Cache

| الحقل | التفاصيل |
|---|---|
| 📁 الملف | [auth_provider.dart](file:///c:/Projects/renal_app/kidneytrack/mobile/lib/features/auth/providers/auth_provider.dart) — السطر 136-140 |
| 🔴 المشكلة | [logout()](file:///c:/Projects/renal_app/kidneytrack/mobile/lib/features/auth/providers/auth_provider.dart#136-141) يضبط `state = AsyncValue.data(null)` لكنه **لا يمسح** `SharedPreferences` (`_patientCacheKey` و `_onboardingKey`). عند تسجيل الدخول مرة ثانية بمستخدم آخر، سيُرجع [build()](file:///c:/Projects/renal_app/kidneytrack/mobile/lib/main.dart#49-67) بيانات المستخدم القديم إلى أن تنتهي جلسة الشبكة. |
| 💡 السبب | نسيان مسح الـ cache المحلي عند الخروج. |
| ⚡ الخطورة | **حرج** — تسريب بيانات بين مستخدمين مختلفين. |

---

#### 🐛 BUG-03: [register()](file:///c:/Projects/renal_app/kidneytrack/mobile/lib/features/auth/providers/auth_provider.dart#107-124) يُجري `signInWithPassword` ثانيةً قد يسبب حلقة

| الحقل | التفاصيل |
|---|---|
| 📁 الملف | [auth_provider.dart](file:///c:/Projects/renal_app/kidneytrack/mobile/lib/features/auth/providers/auth_provider.dart) — السطر 112-114 |
| 🔴 المشكلة | بعد `signUp`، إذا كان `res.session == null` (Supabase Email Confirmation مُفعَّل)، يحاول الكود تسجيل دخول فوري. هذا سيفشل لأن البريد لم يُؤكَّد بعد، ولن يُبلَّغ المستخدم بذلك. |
| 💡 السبب | عدم التحقق من نوع تدفق التسجيل (PKCE مع تأكيد البريد أو بدونه). |
| ⚡ الخطورة | **متوسط** — قد يسبب تجربة مربكة للمستخدم الجديد. |

---

#### 🐛 BUG-04: [profile_screen.dart](file:///c:/Projects/renal_app/kidneytrack/mobile/lib/features/profile/profile_screen.dart) يستدعي `ref.read(authProvider.notifier).checkAuth()` — دالة غير موجودة

| الحقل | التفاصيل |
|---|---|
| 📁 الملف | [profile_screen.dart](file:///c:/Projects/renal_app/kidneytrack/mobile/lib/features/profile/profile_screen.dart) — السطر 56 |
| 🔴 المشكلة | الكود يستدعي `checkAuth()` على [AuthNotifier](file:///c:/Projects/renal_app/kidneytrack/mobile/lib/features/auth/providers/auth_provider.dart#13-161) لكن هذه الدالة **غير معرَّفة** في [auth_provider.dart](file:///c:/Projects/renal_app/kidneytrack/mobile/lib/features/auth/providers/auth_provider.dart). سيؤدي هذا لخطأ compile-time أو runtime. |
| 💡 السبب | دالة محذوفة أو لم تُضَف أصلاً (ربما تم إعادة تسميتها). |
| ⚡ الخطورة | **حرج** — الكود لن يعمل عند تغيير الصورة الشخصية. |

---

### ٢. Navigation / Routing

---

#### 🐛 BUG-05: `redirect` في [app_router.dart](file:///c:/Projects/renal_app/kidneytrack/mobile/lib/core/router/app_router.dart) يقرأ `authNotifierProvider` بطريقة غير آمنة

| الحقل | التفاصيل |
|---|---|
| 📁 الملف | [app_router.dart](file:///c:/Projects/renal_app/kidneytrack/mobile/lib/core/router/app_router.dart) — السطر 93 |
| 🔴 المشكلة | الـ `redirect` callback يستخدم `ref.read(authNotifierProvider).valueOrNull`. في حال بدء تشغيل التطبيق مع وجود session مسبقة، `authNotifierProvider` يكون في حالة `loading` لحظة تشغيل الـ redirect. القيمة ستكون `null`، ما يعني أن `isOnboarded` ستعتمد فقط على `userMetadata`. إذا لم تكن `userMetadata` موجودة، سيُوجَّه المستخدم لـ onboarding من جديد. |
| 💡 السبب | Race condition بين بناء الـ Router وجلب بيانات المريض. |
| ⚡ الخطورة | **حرج** — المستخدمون الذين أكملوا Onboarding قد يُعاد توجيههم له مجدداً. |

---

#### 🐛 BUG-06: [_RouterNotifier](file:///c:/Projects/renal_app/kidneytrack/mobile/lib/core/router/app_router.dart#186-199) يحتفظ بـ `WidgetRef` وسط دورة حياة الـ Router

| الحقل | التفاصيل |
|---|---|
| 📁 الملف | [app_router.dart](file:///c:/Projects/renal_app/kidneytrack/mobile/lib/core/router/app_router.dart) — السطر 186-198 |
| 🔴 المشكلة | [_RouterNotifier](file:///c:/Projects/renal_app/kidneytrack/mobile/lib/core/router/app_router.dart#186-199) يُخزِّن `WidgetRef` في حقل `_ref`. الـ `WidgetRef` مرتبط بدورة حياة الـ Widget. تخزينه بهذه الطريقة خارج دورة حياة Widget يُعدّ **ضد قواعد Riverpod** وقد يُسبِّب memory leaks أو استخدام ref منتهية الصلاحية. |
| 💡 السبب | البديل الصحيح هو إنشاء الـ Router داخل `Provider` لا داخل [createRouter(WidgetRef ref)](file:///c:/Projects/renal_app/kidneytrack/mobile/lib/core/router/app_router.dart#68-184). |
| ⚡ الخطورة | **متوسط** — قد يُسبِّب سلوكاً غير متوقع في حالات نادرة. |

---

#### 🐛 BUG-07: `context.push('/register')` بدلاً من `context.go('/register')` في [login_screen.dart](file:///c:/Projects/renal_app/kidneytrack/mobile/lib/features/auth/login_screen.dart)

| الحقل | التفاصيل |
|---|---|
| 📁 الملف | [login_screen.dart](file:///c:/Projects/renal_app/kidneytrack/mobile/lib/features/auth/login_screen.dart) — السطر 153 |
| 🔴 المشكلة | يُستخدَم `context.push` للتنقل من Login إلى Register. هذا يضيف صفحة login للـ navigation stack، مما يُمكِّن المستخدم من العودة إلى login بزر الرجوع من شاشة register بدلاً من الخروج منها. الـ UX المتوقع هو الاستبدال (go) لا التراكم (push). |
| 💡 السبب | خلط بين `push` و [go](file:///c:/Projects/renal_app/kidneytrack/mobile/lib/features/auth/providers/auth_provider.dart#136-141) في GoRouter. |
| ⚡ الخطورة | **منخفض** — تأثير على UX فقط. |

---

#### 🐛 BUG-08: Route `/history/{indicatorCode}` مُستدعى لكن غير معرَّف في الـ Router

| الحقل | التفاصيل |
|---|---|
| 📁 الملف | [dashboard_screen.dart](file:///c:/Projects/renal_app/kidneytrack/mobile/lib/features/dashboard/dashboard_screen.dart) — السطر 226 |
| 🔴 المشكلة | `context.push('/history/${m['code']}')` يحاول التنقل لمسار ديناميكي (مثل `/history/K`) لكن المسار المُعرَّف في الـ Router هو `/history` فقط بدون parameter. سيُسبِّب هذا خطأ routing في وقت التشغيل. |
| 💡 السبب | تعريف Route ناقص — لم يُضَف parameter ديناميكي. |
| ⚡ الخطورة | **حرج** — crash عند الضغط على أي indicator card في الـ dashboard. |

---

### ٣. State Management

---

#### 🐛 BUG-09: `dashboardSummaryProvider` يجلب بيانات المريض مباشرةً بدلاً من استخدام `authNotifierProvider`

| الحقل | التفاصيل |
|---|---|
| 📁 الملف | [dashboard_screen.dart](file:///c:/Projects/renal_app/kidneytrack/mobile/lib/features/dashboard/dashboard_screen.dart) — السطر 24-96 |
| 🔴 المشكلة | يُجري استعلاماً مباشراً على Supabase `from('Patient')` بدلاً من الاستعانة بـ `authNotifierProvider`. هذا يعني: (١) بيانات مكررة وغير متزامنة، (٢) زيادة في استهلاك الشبكة، (٣) بيانات منفصلة عن الـ cache. |
| 💡 السبب | انعدام طبقة repository/service مركزية لبيانات المريض. |
| ⚡ الخطورة | **متوسط** — يبطئ الـ app ويُضعف اتساق البيانات. |

---

#### 🐛 BUG-10: [FluidNotifier](file:///c:/Projects/renal_app/kidneytrack/mobile/lib/features/dashboard/providers/fluid_provider.dart#25-69) يقرأ `authProvider` بـ `_ref.read` في الـ constructor

| الحقل | التفاصيل |
|---|---|
| 📁 الملف | [fluid_provider.dart](file:///c:/Projects/renal_app/kidneytrack/mobile/lib/features/dashboard/providers/fluid_provider.dart) — السطر 35 |
| 🔴 المشكلة | [fetchHistory()](file:///c:/Projects/renal_app/kidneytrack/mobile/lib/features/dashboard/providers/fluid_provider.dart#33-50) تُستدعى في الـ constructor، وتستخدم `_ref.read(authProvider).value`. في وقت إنشاء الـ Provider، `authProvider` قد يكون لا يزال في حالة `loading`، مما يجعل `patient == null` وتُلغى العملية صامتةً. المستخدم سيرى قوائم سوائل فارغة. |
| 💡 السبب | Race condition مع بدء إنشاء [AuthNotifier](file:///c:/Projects/renal_app/kidneytrack/mobile/lib/features/auth/providers/auth_provider.dart#13-161). |
| ⚡ الخطورة | **متوسط** — بيانات السوائل لا تُحمَّل عند أول فتح للـ dashboard. |

---

#### 🐛 BUG-11: `FluidNotifier.addIntake()` يبتلع الأخطاء صامتاً

| الحقل | التفاصيل |
|---|---|
| 📁 الملف | [fluid_provider.dart](file:///c:/Projects/renal_app/kidneytrack/mobile/lib/features/dashboard/providers/fluid_provider.dart) — السطر 64-65 |
| 🔴 المشكلة | `catch (e, st) { // Handle error }` — الكتلة فارغة تماماً. إذا فشل الـ insert لأي سبب (انتهت الجلسة، خطأ RLS، انقطاع الشبكة)، لن يُبلَّغ المستخدم بذلك. |
| 💡 السبب | Error handling ناقص. |
| ⚡ الخطورة | **متوسط** — Silent failure يُضلِّل المستخدم. |

---

#### 🐛 BUG-12: [updatePatient()](file:///c:/Projects/renal_app/kidneytrack/mobile/lib/features/auth/providers/auth_provider.dart#142-160) في حالة فشل تُرجع `false` بدون إبلاغ المستخدم

| الحقل | التفاصيل |
|---|---|
| 📁 الملف | [auth_provider.dart](file:///c:/Projects/renal_app/kidneytrack/mobile/lib/features/auth/providers/auth_provider.dart) — السطر 156-158 |
| 🔴 المشكلة | الـ `catch` block يلتقط الخطأ ويُرجع `false` فقط. الشاشات التي تستدعي [updatePatient](file:///c:/Projects/renal_app/kidneytrack/mobile/lib/features/auth/providers/auth_provider.dart#142-160) (مثل [profile_screen.dart](file:///c:/Projects/renal_app/kidneytrack/mobile/lib/features/profile/profile_screen.dart)) تتحقق من القيمة لكنها لا تعرض رسالة خطأ واضحة. |
| 💡 السبب | الدالة لا تُعيد سبب الفشل. |
| ⚡ الخطورة | **منخفض** — تجربة مستخدم سيئة عند فشل التحديث. |

---

### ٤. Supabase RLS

---

#### 🐛 BUG-13: `dashboardSummaryProvider` يستعلم من `LabResult` و `Alert` بدون ضمان وجود جلسة مُفعَّلة

| الحقل | التفاصيل |
|---|---|
| 📁 الملف | [dashboard_screen.dart](file:///c:/Projects/renal_app/kidneytrack/mobile/lib/features/dashboard/dashboard_screen.dart) — السطر 38-85 |
| 🔴 المشكلة | الـ Provider يتحقق من `user == null` في السطر 26-27، لكن في حالة انتهاء صلاحية الـ Token بعد تحميل الـ Provider أول مرة (وقبل إعادة تحديثه)، ستفشل الاستعلامات بخطأ RLS لأن الـ session منتهية. الـ `catch` يُطلق `rethrow` مما يُظهر `Error: $err` للمستخدم مباشرةً. |
| 💡 السبب | عدم التحقق من صحة الـ session قبل كل استعلام حساس. |
| ⚡ الخطورة | **متوسط** — رسالة خطأ تقنية تظهر للمستخدم. |

---

#### 🐛 BUG-14: `medicalInsightsProvider` يجلب بيانات حتى لو `patient == null` (يعيد بيانات فارغة)

| الحقل | التفاصيل |
|---|---|
| 📁 الملف | [medical_insights_provider.dart](file:///c:/Projects/renal_app/kidneytrack/mobile/lib/features/dashboard/providers/medical_insights_provider.dart) — السطر 8-22 |
| 🔴 المشكلة | هذا سلوك مقصود لكنه يستمر في الاستعلام من `LabResult` في الأسطر 29-34 حتى لو كان `patient.id` من `Patient.quick()` (بدون بيانات من قاعدة البيانات). في هذه الحالة، قد تنجح عمليات RLS أو تفشل حسب السياسات المُعرَّفة. |
| 💡 السبب | حالة `Patient.quick()` يجب أن تمنع أي استعلام لقاعدة البيانات. |
| ⚡ الخطورة | **منخفض** — قد يُسبِّب استعلامات زائدة أو أخطاء. |

---

#### 🐛 BUG-15: [_changeAvatar](file:///c:/Projects/renal_app/kidneytrack/mobile/lib/features/profile/profile_screen.dart#26-73) في [profile_screen.dart](file:///c:/Projects/renal_app/kidneytrack/mobile/lib/features/profile/profile_screen.dart) يُحدِّث Supabase مباشرةً بدون RLS on `avatars`

| الحقل | التفاصيل |
|---|---|
| 📁 الملف | [profile_screen.dart](file:///c:/Projects/renal_app/kidneytrack/mobile/lib/features/profile/profile_screen.dart) — السطر 42-48 |
| 🔴 المشكلة | رفع الصورة على bucket `avatars` ثم تحديث حقل `avatarUrl` في جدول [Patient](file:///c:/Projects/renal_app/kidneytrack/mobile/lib/core/models/patient.dart#1-119) يفترض أن سياسات RLS تسمح لكل مستخدم بتعديل سجله فقط. لا يوجد تحقق من أن `patient.id == user.id` قبل التحديث. |
| 💡 السبب | الكود يعتمد كلياً على RLS دون طبقة تحقق إضافية في الكود. |
| ⚡ الخطورة | **منخفض** — يُعدّ مقبولاً إذا كانت سياسات RLS مُعدَّة بشكل صحيح. |

---

### ٥. Error Handling

---

#### 🐛 BUG-16: Dashboard يعرض `Error: $err` الخام للمستخدم

| الحقل | التفاصيل |
|---|---|
| 📁 الملف | [dashboard_screen.dart](file:///c:/Projects/renal_app/kidneytrack/mobile/lib/features/dashboard/dashboard_screen.dart) — السطر 112-115 |
| 🔴 المشكلة | كلا `summaryAsync.when(error:...)` و `insightsAsync.when(error:...)` يعرضان `Text('Error: $err')`. هذا رسالة تقنية خام غير مناسبة للمستخدمين النهائيين (مرضى الكلى). |
| 💡 السبب | غياب Error UI مخصص. |
| ⚡ الخطورة | **متوسط** — تجربة مستخدم سيئة ومخيفة. |

---

#### 🐛 BUG-17: [_finishOnboarding()](file:///c:/Projects/renal_app/kidneytrack/mobile/lib/features/onboarding/onboarding_screen.dart#102-136) لا تُبقي المستخدم في حالة انتظار عند النجاح

| الحقل | التفاصيل |
|---|---|
| 📁 الملف | [onboarding_screen.dart](file:///c:/Projects/renal_app/kidneytrack/mobile/lib/features/onboarding/onboarding_screen.dart) — السطر 127-128 |
| 🔴 المشكلة | عند نجاح [submitOnboarding](file:///c:/Projects/renal_app/kidneytrack/mobile/lib/features/onboarding/providers/onboarding_provider.dart#16-32)، الكود لا يفعل شيئاً ويترك الـ `_isSaving = true` دون إعادته لـ false. المستخدم سيرى زر "تأكيد" معطلاً لفترة غير محددة حتى يتدخل الـ Router ويُوجِّهه. |
| 💡 السبب | نسيان إعادة `_isSaving = false` في حالة النجاح. |
| ⚡ الخطورة | **منخفض** — تجميد بصري مؤقت. |

---

### ٦. Architecture

---

#### 🐛 BUG-18: `dashboardSummaryProvider` هو FutureProvider داخل ملف الشاشة (UI layer)

| الحقل | التفاصيل |
|---|---|
| 📁 الملف | [dashboard_screen.dart](file:///c:/Projects/renal_app/kidneytrack/mobile/lib/features/dashboard/dashboard_screen.dart) — السطر 24 |
| 🔴 المشكلة | Provider يحتوي على منطق جلب البيانات المباشر (queries) معرَّف في ملف الشاشة. هذا ضد مبدأ الفصل بين الطبقات. الـ provider يجب أن يكون في مجلد `providers/` ويُفضَّل أن يستخدم Repository. |
| 💡 السبب | غياب طبقة Repository/Service لـ Dashboard. |
| ⚡ الخطورة | **متوسط** — يُصعِّب الاختبار والصيانة. |

---

#### 🐛 BUG-19: `authProvider = authNotifierProvider` alias زائد يُربك القارئ

| الحقل | التفاصيل |
|---|---|
| 📁 الملف | [auth_provider.dart](file:///c:/Projects/renal_app/kidneytrack/mobile/lib/features/auth/providers/auth_provider.dart) — السطر 166 |
| 🔴 المشكلة | `final authProvider = authNotifierProvider` يُنشئ alias. الملفات تستخدم كلاهما (`authProvider` و `authNotifierProvider`) بشكل متبادل. هذا يُسبِّب تشتتاً عند القراءة. |
| 💡 السبب | refactoring قديم لم يُكتمَل. |
| ⚡ الخطورة | **منخفض** — code smell فقط. |

---

#### 🐛 BUG-20: `GoRouter` يُنشأ في كل مرة يُبنى فيها [GlomeaApp](file:///c:/Projects/renal_app/kidneytrack/mobile/lib/main.dart#45-68) widget

| الحقل | التفاصيل |
|---|---|
| 📁 الملف | [main.dart](file:///c:/Projects/renal_app/kidneytrack/mobile/lib/main.dart) — السطر 54 |
| 🔴 المشكلة | `AppRouter.createRouter(ref, ...)` يُنشئ instance جديدة من `GoRouter` في كل مرة يُعاد بناء [GlomeaApp](file:///c:/Projects/renal_app/kidneytrack/mobile/lib/main.dart#45-68). هذا قد يُسبِّب إعادة تهيئة الـ navigation state بالكامل. |
| 💡 السبب | يجب حفظ الـ router في `Provider` أو `static final`. |
| ⚡ الخطورة | **متوسط** — إعادة بناء غير ضرورية قد تُخلّ بالـ navigation state. |

---

### ٧. مشاكل أخرى

---

#### 🐛 BUG-21: [_buildStepHeight()](file:///c:/Projects/renal_app/kidneytrack/mobile/lib/features/onboarding/onboarding_screen.dart#463-498) في Onboarding ينشئ `TextEditingController` مجهول الهوية داخل [build](file:///c:/Projects/renal_app/kidneytrack/mobile/lib/main.dart#49-67)

| الحقل | التفاصيل |
|---|---|
| 📁 الملف | [onboarding_screen.dart](file:///c:/Projects/renal_app/kidneytrack/mobile/lib/features/onboarding/onboarding_screen.dart) — السطر 479 |
| 🔴 المشكلة | `TextEditingController(text: _height.toInt().toString())` يُنشأ مباشرةً داخل [build()](file:///c:/Projects/renal_app/kidneytrack/mobile/lib/main.dart#49-67). في كل مرة تُعاد رسم الشاشة، يُنشأ controller جديد. لن يتم dispose له أبداً → **Memory Leak**. |
| 💡 السبب | يجب إنشاء controllers في [initState](file:///c:/Projects/renal_app/kidneytrack/mobile/lib/features/onboarding/onboarding_screen.dart#98-101) والتخلص منها في [dispose](file:///c:/Projects/renal_app/kidneytrack/mobile/lib/features/onboarding/onboarding_screen.dart#89-96). |
| ⚡ الخطورة | **متوسط** — Memory leak في شاشة Onboarding. |

---

#### 🐛 BUG-22: [main.dart](file:///c:/Projects/renal_app/kidneytrack/mobile/lib/main.dart) يُكمِّل تشغيل التطبيق حتى لو فشل `Supabase.initialize()`

| الحقل | التفاصيل |
|---|---|
| 📁 الملف | [main.dart](file:///c:/Projects/renal_app/kidneytrack/mobile/lib/main.dart) — السطر 34-36 |
| 🔴 المشكلة | `catch (e) { debugPrint(..) }` يلتقط الأخطاء فقط بـ print ويُكمِّل `runApp`. إذا فشل تهيئة Supabase (مثلاً: `.env` مفقود أو خطأ في الـ URL)، سيُشغَّل التطبيق وكل استعلام سيفشل لأن Supabase غير مُهيَّأ. |
| 💡 السبب | غياب التحقق من حالة التهيئة. |
| ⚡ الخطورة | **متوسط** — crash غير واضح السبب في بيئة الإنتاج. |

---

## المرحلة الثالثة: خطة التنفيذ (مُرتَّبة حسب الأولوية)

---

### الخطوة 1 — إصلاح `checkAuth()` المفقودة ومنع Compile Error فوري
**الملفات:** [auth_provider.dart](file:///c:/Projects/renal_app/kidneytrack/mobile/lib/features/auth/providers/auth_provider.dart), [profile_screen.dart](file:///c:/Projects/renal_app/kidneytrack/mobile/lib/features/profile/profile_screen.dart)
**ما سيُفعَل:** إضافة دالة `checkAuth()` لـ [AuthNotifier](file:///c:/Projects/renal_app/kidneytrack/mobile/lib/features/auth/providers/auth_provider.dart#13-161) تُعيد استدعاء [_fetchPatient()](file:///c:/Projects/renal_app/kidneytrack/mobile/lib/features/auth/providers/auth_provider.dart#77-106) وتُحدِّث الـ state.
**التأثير المتوقع:** حل خطأ compile-time فوري، تعمل وظيفة تغيير الصورة مرة أخرى.

---

### الخطوة 2 — ربط [AuthNotifier](file:///c:/Projects/renal_app/kidneytrack/mobile/lib/features/auth/providers/auth_provider.dart#13-161) بـ `onAuthStateChange` (BUG-01)
**الملفات:** [auth_provider.dart](file:///c:/Projects/renal_app/kidneytrack/mobile/lib/features/auth/providers/auth_provider.dart)
**ما سيُفعَل:** إضافة `ref.listen(authStateProvider, ...)` داخل [build()](file:///c:/Projects/renal_app/kidneytrack/mobile/lib/main.dart#49-67) في [AuthNotifier](file:///c:/Projects/renal_app/kidneytrack/mobile/lib/features/auth/providers/auth_provider.dart#13-161) ليُعيد جلب بيانات المريض تلقائياً عند كل تغيير في الـ session.
**التأثير المتوقع:** التوجيه التلقائي بعد تسجيل الدخول والتسجيل سيعمل بشكل موثوق.

---

### الخطوة 3 — مسح الـ Cache عند [logout()](file:///c:/Projects/renal_app/kidneytrack/mobile/lib/features/auth/providers/auth_provider.dart#136-141) (BUG-02)
**الملفات:** [auth_provider.dart](file:///c:/Projects/renal_app/kidneytrack/mobile/lib/features/auth/providers/auth_provider.dart)
**ما سيُفعَل:** إضافة مسح `SharedPreferences` (كلا المفاحين `_patientCacheKey` و `_onboardingKey`) في [logout()](file:///c:/Projects/renal_app/kidneytrack/mobile/lib/features/auth/providers/auth_provider.dart#136-141).
**التأثير المتوقع:** منع تسريب بيانات مستخدم سابق لمستخدم جديد.

---

### الخطوة 4 — نقل GoRouter لـ Provider ومنع إعادة إنشائه (BUG-06, BUG-20)
**الملفات:** [app_router.dart](file:///c:/Projects/renal_app/kidneytrack/mobile/lib/core/router/app_router.dart), [main.dart](file:///c:/Projects/renal_app/kidneytrack/mobile/lib/main.dart)
**ما سيُفعَل:** تحويل [createRouter()](file:///c:/Projects/renal_app/kidneytrack/mobile/lib/core/router/app_router.dart#68-184) أو نقل الـ GoRouter لـ `Provider` مستقل حتى لا يُعاد إنشاؤه عند rebuild. استبدال `WidgetRef` بـ `Ref` العادية.
**التأثير المتوقع:** استقرار الـ navigation state، إزالة memory leak محتمل.

---

### الخطوة 5 — إصلاح redirect Race Condition (BUG-05)
**الملفات:** [app_router.dart](file:///c:/Projects/renal_app/kidneytrack/mobile/lib/core/router/app_router.dart)
**ما سيُفعَل:** إضافة فحص `authNotifierProvider.isLoading` داخل الـ redirect، وإرجاع `null` (لا تحويل) إذا البيانات لا تزال تُحمَّل، بدلاً من الاعتماد على metadata فقط.
**التأثير المتوقع:** القضاء على حالة إعادة توجيه Onboarding غير المقصودة.

---

### الخطوة 6 — إصلاح Route `/history/{code}` الناقص (BUG-08)
**الملفات:** [app_router.dart](file:///c:/Projects/renal_app/kidneytrack/mobile/lib/core/router/app_router.dart)
**ما سيُفعَل:** إضافة Route بمعامل ديناميكي (`:indicatorCode`) في الـ Router و تحديث `history_screen.dart` لقراءة هذا المعامل.
**التأثير المتوقع:** القضاء على crash عند الضغط على indicator cards في الـ dashboard.

---

### الخطوة 7 — تبديل `context.push` بـ `context.go` في [login_screen.dart](file:///c:/Projects/renal_app/kidneytrack/mobile/lib/features/auth/login_screen.dart) (BUG-07)
**الملفات:** [login_screen.dart](file:///c:/Projects/renal_app/kidneytrack/mobile/lib/features/auth/login_screen.dart)
**ما سيُفعَل:** تغيير `context.push('/register')` إلى `context.go('/register')`.
**التأثير المتوقع:** تحسين UX وإزالة تراكم الصفحات.

---

### الخطوة 8 — إصلاح Memory Leak في [_buildStepHeight](file:///c:/Projects/renal_app/kidneytrack/mobile/lib/features/onboarding/onboarding_screen.dart#463-498) (BUG-21)
**الملفات:** [onboarding_screen.dart](file:///c:/Projects/renal_app/kidneytrack/mobile/lib/features/onboarding/onboarding_screen.dart)
**ما سيُفعَل:** نقل `TextEditingController` الخاص بالطول إلى حقل ثابت في الـ State مع [dispose](file:///c:/Projects/renal_app/kidneytrack/mobile/lib/features/onboarding/onboarding_screen.dart#89-96) سليم.
**التأثير المتوقع:** إزالة memory leak.

---

### الخطوة 9 — إضافة Error UI مناسب للـ Dashboard (BUG-16, BUG-22)
**الملفات:** [dashboard_screen.dart](file:///c:/Projects/renal_app/kidneytrack/mobile/lib/features/dashboard/dashboard_screen.dart), [main.dart](file:///c:/Projects/renal_app/kidneytrack/mobile/lib/main.dart)
**ما سيُفعَل:** استبدال `Text('Error: $err')` بـ widget مخصص يعرض رسالة ودية مع زر "إعادة المحاولة". إضافة فحص تهيئة Supabase ورسالة خطأ واضحة في [main.dart](file:///c:/Projects/renal_app/kidneytrack/mobile/lib/main.dart).
**التأثير المتوقع:** تجربة مستخدم أفضل عند الأخطاء.

---

### الخطوة 10 — إصلاح [FluidNotifier](file:///c:/Projects/renal_app/kidneytrack/mobile/lib/features/dashboard/providers/fluid_provider.dart#25-69) ومعالجة الأخطاء الصامتة (BUG-10, BUG-11)
**الملفات:** [fluid_provider.dart](file:///c:/Projects/renal_app/kidneytrack/mobile/lib/features/dashboard/providers/fluid_provider.dart)
**ما سيُفعَل:** جعل [FluidNotifier](file:///c:/Projects/renal_app/kidneytrack/mobile/lib/features/dashboard/providers/fluid_provider.dart#25-69) يستمع لـ `authProvider` بدلاً من `read` في الـ constructor، وإضافة error handling في [addIntake()](file:///c:/Projects/renal_app/kidneytrack/mobile/lib/features/dashboard/providers/fluid_provider.dart#51-68).
**التأثير المتوقع:** تحميل بيانات السوائل بشكل موثوق ورسائل خطأ واضحة.

---

### الخطوة 11 — نقل `dashboardSummaryProvider` لملف providers (BUG-18, BUG-09)
**الملفات:** [dashboard_screen.dart](file:///c:/Projects/renal_app/kidneytrack/mobile/lib/features/dashboard/dashboard_screen.dart), `dashboard/providers/dashboard_provider.dart` (جديد)
**ما سيُفعَل:** نقل الـ Provider لملف منفصل، واستخدام `authNotifierProvider` لبيانات المريض بدلاً من استعلام مباشر.
**التأثير المتوقع:** فصل طبقة البيانات عن الـ UI، تحسين قابلية الصيانة.

---

### الخطوة 12 — تنظيف `authProvider` alias وتوحيد الاستخدام (BUG-19)
**الملفات:** [auth_provider.dart](file:///c:/Projects/renal_app/kidneytrack/mobile/lib/features/auth/providers/auth_provider.dart) وجميع الملفات التي تستخدم الـ alias
**ما سيُفعَل:** إزالة `authProvider = authNotifierProvider` وتوحيد الاستخدام على `authNotifierProvider` واحداً.
**التأثير المتوقع:** كود أوضح وأقل تشتتاً.

---
