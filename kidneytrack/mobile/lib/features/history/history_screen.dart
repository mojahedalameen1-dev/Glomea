import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart' as intl;
import 'package:kidneytrack_mobile/l10n/app_localizations.dart';
import 'package:kidneytrack_mobile/core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/data/lab_indicators.dart';
import '../../core/models/daily_reading.dart';
import '../auth/providers/auth_provider.dart';
import 'providers/history_provider.dart';
import '../../core/widgets/charts/trend_line_chart.dart';
import 'widgets/history_filter_chips.dart';
import 'widgets/log_cards.dart';
import 'widgets/history_state_views.dart';
import '../../core/models/lab_result.dart';

class HistoryEvent {
  final DateTime date;
  final dynamic data;
  final HistoryCategory category;

  HistoryEvent({
    required this.date,
    required this.data,
    required this.category,
  });
}

class HistoryScreen extends ConsumerStatefulWidget {
  final String? indicatorCode;
  final String? searchQuery;
  const HistoryScreen({super.key, this.indicatorCode, this.searchQuery});

  @override
  ConsumerState<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends ConsumerState<HistoryScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _showTimeline = true;
  HistoryCategory _selectedCategory = HistoryCategory.all;
  HistoryFilter _currentFilter = HistoryFilter.month;

  final Map<int, HistoryFilter> _tabFilters = {
    0: HistoryFilter.month,
    1: HistoryFilter.month,
    2: HistoryFilter.month,
    3: HistoryFilter.month,
    4: HistoryFilter.month,
    5: HistoryFilter.month,
  };

  @override
  void initState() {
    super.initState();
    // Initial length depends on existing data
    final hasNutrients =
        ref.read(nutrientDataExistsProvider).valueOrNull ?? false;
    _tabController = TabController(length: hasNutrients ? 6 : 5, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Safety check for dynamic tabs
    // Sync TabController when data availability changes
    ref.listen(nutrientDataExistsProvider, (prev, next) {
      final nutrientDataExists = next.valueOrNull ?? false;
      final totalTabs = nutrientDataExists ? 6 : 5;

      if (_tabController.length != totalTabs) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          final oldIndex = _tabController.index;
          _tabController.dispose();
          _tabController = TabController(
            length: totalTabs,
            vsync: this,
            initialIndex: oldIndex.clamp(0, totalTabs - 1),
          );
          setState(() {});
        });
      }
    });

    final nutrientDataExists =
        ref.watch(nutrientDataExistsProvider).valueOrNull ?? false;

    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: isDark ? AppColors.bgBackDark : AppColors.bgBack,
      appBar: AppBar(
        title: Text(l10n.healthDataHistory),
        actions: [
          IconButton(
            icon: Icon(_showTimeline ? Icons.show_chart : Icons.history),
            onPressed: () => setState(() => _showTimeline = !_showTimeline),
            tooltip: _showTimeline ? l10n.showCharts : l10n.showTimeline,
          ),
        ],
        bottom: !_showTimeline
            ? TabBar(
                controller: _tabController,
                isScrollable: true,
                tabAlignment: TabAlignment.start,
                labelStyle:
                    AppTextStyles.label.copyWith(fontWeight: FontWeight.bold),
                unselectedLabelStyle: AppTextStyles.label,
                tabs: [
                  Tab(text: l10n.weightFluid),
                  Tab(text: l10n.bloodPressure),
                  Tab(text: l10n.kidneyLabs),
                  Tab(text: l10n.heartSugar),
                  Tab(text: l10n.mineralsVitamins),
                  if (nutrientDataExists) Tab(text: l10n.nutritionSummary),
                ],
              )
            : PreferredSize(
                preferredSize: const Size.fromHeight(60),
                child: Column(
                  children: [
                    HistoryFilterChips(
                      selected: _selectedCategory,
                      onSelected: (cat) =>
                          setState(() => _selectedCategory = cat),
                    ),
                  ],
                ),
              ),
      ),
      body: _showTimeline
          ? _buildTimelineView()
          : TabBarView(
              controller: _tabController,
              children: [
                _buildWeightFluidTab(),
                _buildBloodPressureTab(),
                _buildLabGroupTab(['K', 'CREAT', 'UREA', 'NA'], 2),
                _buildLabGroupTab(
                    ['hba1c', 'total_cholesterol', 'ldl', 'triglycerides'], 3),
                _buildLabGroupTab(
                    ['calcium', 'vitamin_d', 'phosphorus_blood', 'urine_acr'],
                    4),
                if (nutrientDataExists) _buildNutritionTab(),
              ],
            ),
    );
  }

  Widget _buildTimelineView() {
    final creatinine = ref.watch(
        labHistoryProvider((indicatorCode: 'CREAT', filter: _currentFilter)));
    final potassium = ref.watch(
        labHistoryProvider((indicatorCode: 'K', filter: _currentFilter)));
    final urea = ref.watch(
        labHistoryProvider((indicatorCode: 'UREA', filter: _currentFilter)));
    final sodium = ref.watch(
        labHistoryProvider((indicatorCode: 'NA', filter: _currentFilter)));

    final dailyReadings =
        ref.watch(dailyReadingsHistoryProvider(_currentFilter));
    final fluids = ref.watch(fluidIntakeHistoryProvider(_currentFilter));
    final meds = ref.watch(medicationHistoryProvider(_currentFilter));
    final foods = ref.watch(foodHistoryProvider(_currentFilter));

    // Check loading/error
    final allProviders = [
      creatinine,
      potassium,
      urea,
      sodium,
      dailyReadings,
      fluids,
      meds,
      foods
    ];
    if (allProviders.any((p) => p.isLoading)) {
      return ListView.builder(
        itemCount: 5,
        itemBuilder: (_, __) => const SkeletonLogCard(),
      );
    }

    if (allProviders.any((p) => p.hasError)) {
      final error = allProviders.firstWhere((p) => p.hasError).error;
      return HistoryErrorView(
        message: '$error',
        onRetry: () {
          ref.invalidate(labHistoryProvider);
          ref.invalidate(dailyReadingsHistoryProvider);
          ref.invalidate(fluidIntakeHistoryProvider);
          ref.invalidate(foodHistoryProvider);
        },
      );
    }

    final List<HistoryEvent> events = [];

    final isAr = Localizations.localeOf(context).languageCode == 'ar';

    for (final p in [creatinine, potassium, urea, sodium]) {
      p.whenData((list) => events.addAll(list.map((l) => HistoryEvent(
          date: l.recordedAt, data: l, category: HistoryCategory.labs))));
    }

    // Add Vitals
    dailyReadings.whenData((list) => events.addAll(list.map((r) => HistoryEvent(
        date: r.date, data: r, category: HistoryCategory.vitals))));

    // Add Fluids & Food
    fluids.whenData((list) => events.addAll(list.map((f) => HistoryEvent(
        date: f.consumedAt, data: f, category: HistoryCategory.food))));
    foods.whenData((list) => events.addAll(list.map((f) => HistoryEvent(
        date: f.consumedAt, data: f, category: HistoryCategory.food))));

    // Add Meds
    meds.whenData((list) => events.addAll(list.map((m) => HistoryEvent(
        date: m.scheduledAt, data: m, category: HistoryCategory.medications))));

    // Search Filter
    final query = widget.searchQuery?.toLowerCase().trim();
    final searchedEvents = query == null || query.isEmpty
        ? events
        : events.where((e) {
            final name = labIndicators[e.data is LabResult
                        ? (e.data as LabResult).indicatorCode
                        : '']?[isAr ? 'nameAr' : 'nameEn']
                    ?.toString()
                    .toLowerCase() ??
                '';
            final msg = (e.data is LabResult)
                ? (e.data as LabResult).indicatorCode.toLowerCase()
                : '';
            return name.contains(query) || msg.contains(query);
          }).toList();
    // Category Filter
    final filteredEvents = _selectedCategory == HistoryCategory.all
        ? searchedEvents
        : searchedEvents.where((e) => e.category == _selectedCategory).toList();

    // Sort descending
    filteredEvents.sort((a, b) => b.date.compareTo(a.date));

    if (filteredEvents.isEmpty) {
      if (_selectedCategory == HistoryCategory.all) {
        return HistoryEmptyFilterView(onClearFilters: () {});
      }
      return HistoryEmptyFilterView(
          onClearFilters: () =>
              setState(() => _selectedCategory = HistoryCategory.all));
    }

    // Group by Date for Lazy Rendering
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: _buildTimeFilterRow(),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            itemCount: filteredEvents.length,
            itemBuilder: (context, index) {
              final event = filteredEvents[index];
              final prevEvent = index > 0 ? filteredEvents[index - 1] : null;
              final isNewDate = prevEvent == null ||
                  intl.DateFormat('yyyy-MM-dd').format(event.date) !=
                      intl.DateFormat('yyyy-MM-dd').format(prevEvent.date);

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (isNewDate) _buildDateHeader(event.date),
                  _buildEventCard(event),
                ],
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildTimeFilterRow() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: HistoryFilter.values.map((f) {
          final isSelected = _currentFilter == f;
          return Padding(
            padding: const EdgeInsets.only(left: 8),
            child: ChoiceChip(
              label: Text(f.label),
              selected: isSelected,
              onSelected: (_) => setState(() => _currentFilter = f),
              selectedColor: AppColors.primary,
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : AppColors.textPrimary,
                fontSize: 12,
              ),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildDateHeader(DateTime date) {
    final l10n = AppLocalizations.of(context)!;
    final localeCode = Localizations.localeOf(context).languageCode;
    final now = DateTime.now();
    final todayStr = DateTime(now.year, now.month, now.day);
    final yesterdayStr = todayStr.subtract(const Duration(days: 1));
    final readingDate = DateTime(date.year, date.month, date.day);

    String label;
    if (readingDate == todayStr) {
      label = l10n.today;
    } else if (readingDate == yesterdayStr) {
      label = l10n.yesterday;
    } else {
      label = intl.DateFormat('d MMMM yyyy', localeCode).format(date);
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      child: Text(
        label,
        style: AppTextStyles.h3.copyWith(
          fontSize: 14,
          color: AppColors.primary,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildEventCard(HistoryEvent event) {
    return switch (event.category) {
      HistoryCategory.labs => LabLogCard(result: event.data),
      HistoryCategory.vitals => VitalsLogCard(reading: event.data),
      HistoryCategory.medications => MedicationLogCard(log: event.data),
      HistoryCategory.food => ConsumptionLogCard(entry: event.data),
      _ => const SizedBox.shrink(),
    };
  }

  // ── Tab 1: Weight & Fluids ────────────────────────────────────────────────
  Widget _buildWeightFluidTab() {
    final filter = _tabFilters[0]!;
    final readingsAsync = ref.watch(dailyReadingsHistoryProvider(filter));
    final patientAsync = ref.watch(authNotifierProvider);
    final fluidTrendAsync = ref.watch(fluidIntakeTrendProvider(filter));

    final l10n = AppLocalizations.of(context)!;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildFilterRow(0),
          const SizedBox(height: 16),
          _buildCard(
            title: l10n.weightTrend,
            child: readingsAsync.when(
              data: (data) {
                if (data.isEmpty) return Center(child: Text(l10n.noWeightData));
                final patient = patientAsync.value;
                final dryWeight = patient?.dryWeightKg ?? 70.0;

                final weightSpots = data
                    .where((r) => r.weightKg != null)
                    .map((r) => FlSpot(
                        r.date.millisecondsSinceEpoch.toDouble(), r.weightKg!))
                    .toList();

                final dryWeightSpots = data
                    .map((r) => FlSpot(
                        r.date.millisecondsSinceEpoch.toDouble(), dryWeight))
                    .toList();

                return TrendLineChart(
                  lines: [
                    LineChartBarData(
                      spots: weightSpots,
                      color: AppColors.primary,
                      barWidth: 3,
                      isCurved: true,
                    ),
                    LineChartBarData(
                      spots: dryWeightSpots,
                      color: Colors.teal.withValues(alpha: 0.5),
                      barWidth: 2,
                      dashArray: [5, 5],
                      dotData: const FlDotData(show: false),
                    ),
                  ],
                  targetLines: [
                    HorizontalLine(
                      y: dryWeight,
                      color: Colors.teal.withValues(alpha: 0.3),
                      strokeWidth: 1,
                      dashArray: [5, 5],
                      label: HorizontalLineLabel(
                          show: true,
                          labelResolver: (_) => l10n.dryWeight,
                          style: const TextStyle(fontSize: 9)),
                    ),
                  ],
                  showAreaFill: true,
                  areaFillColor: AppColors.primary.withValues(alpha: 0.1),
                  yAxisLabel: l10n.unitKg,
                  tooltipValueFormatter: (v) => v.toStringAsFixed(1),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Text('Error: $e'),
            ),
          ),
          const SizedBox(height: 16),
          _buildCard(
            title: l10n.totalFluidIntake,
            child: fluidTrendAsync.when(
              data: (data) {
                if (data.isEmpty) return Center(child: Text(l10n.noFluidData));

                final sortedKeys = data.keys.toList()..sort();
                final spots = sortedKeys
                    .map((d) =>
                        FlSpot(d.millisecondsSinceEpoch.toDouble(), data[d]!))
                    .toList();

                const goal = 1500.0; // Default or from profile

                return TrendLineChart(
                  lines: [
                    LineChartBarData(
                      spots: spots,
                      color: Colors.cyan,
                      barWidth: 3,
                      isCurved: false,
                    ),
                  ],
                  targetLines: [
                    HorizontalLine(
                      y: goal,
                      color: Colors.cyan.withValues(alpha: 0.4),
                      strokeWidth: 2,
                      dashArray: [8, 4],
                      label: HorizontalLineLabel(
                          show: true,
                          labelResolver: (_) => l10n.goalMl(goal.toInt())),
                    ),
                  ],
                  yAxisLabel: l10n.unitMl,
                  tooltipValueFormatter: (v) => v.toStringAsFixed(0),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Text('Error: $e'),
            ),
          ),
        ],
      ),
    );
  }

  // ── Tab 2: Blood Pressure ─────────────────────────────────────────────────
  Widget _buildBloodPressureTab() {
    final filter = _tabFilters[1]!;
    final readingsAsync = ref.watch(dailyReadingsHistoryProvider(filter));
    final patient = ref.watch(authNotifierProvider).value;

    final l10n = AppLocalizations.of(context)!;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildFilterRow(1),
          const SizedBox(height: 16),
          _buildCard(
            title: l10n.bpTrend,
            child: readingsAsync.when(
              data: (data) {
                final bpData = data
                    .where((r) => r.systolic != null && r.diastolic != null)
                    .toList();
                if (bpData.isEmpty) return Center(child: Text(l10n.noBpData));

                final sysSpots = bpData
                    .map((r) => FlSpot(r.date.millisecondsSinceEpoch.toDouble(),
                        r.systolic!.toDouble()))
                    .toList();

                final diaSpots = bpData
                    .map((r) => FlSpot(r.date.millisecondsSinceEpoch.toDouble(),
                        r.diastolic!.toDouble()))
                    .toList();

                return TrendLineChart(
                  lines: [
                    LineChartBarData(
                      spots: sysSpots,
                      color: Colors.red,
                      barWidth: 2.5,
                    ),
                    LineChartBarData(
                      spots: diaSpots,
                      color: Colors.orange,
                      barWidth: 2.5,
                    ),
                  ],
                  targetLines: [
                    HorizontalLine(
                      y: (patient?.targetSystolic ?? 130).toDouble(),
                      color: Colors.red.withValues(alpha: 0.3),
                      dashArray: [8, 4],
                      label: HorizontalLineLabel(
                          show: true,
                          labelResolver: (_) => l10n.targetSystolicLabel,
                          style: const TextStyle(fontSize: 8)),
                    ),
                    HorizontalLine(
                      y: (patient?.targetDiastolic ?? 80).toDouble(),
                      color: Colors.orange.withValues(alpha: 0.3),
                      dashArray: [8, 4],
                      label: HorizontalLineLabel(
                          show: true,
                          labelResolver: (_) => l10n.targetDiastolicLabel,
                          style: const TextStyle(fontSize: 8),
                          alignment: Alignment.bottomRight),
                    ),
                  ],
                  yAxisLabel: 'mmHg',
                  tooltipValueFormatter: (v) => v.toStringAsFixed(0),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Text('Error: $e'),
            ),
          ),
        ],
      ),
    );
  }

  // ── Tabs 3, 4, 5: Lab Groups ──────────────────────────────────────────────
  Widget _buildLabGroupTab(List<String> codes, int tabIndex) {
    final filter = _tabFilters[tabIndex]!;

    final l10n = AppLocalizations.of(context)!;
    final isAr = Localizations.localeOf(context).languageCode == 'ar';

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildFilterRow(tabIndex),
        const SizedBox(height: 16),
        ...codes.map((code) => Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: _buildCard(
                title: labIndicators[code]?[isAr ? 'nameAr' : 'nameEn'] ?? code,
                child: ref
                    .watch(labHistoryProvider(
                        (indicatorCode: code, filter: filter)))
                    .when(
                      data: (results) {
                        if (results.isEmpty)
                          return Center(
                              child: Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Text(l10n.noResults)));
                        final unit = labIndicators[code]?['unit'] ?? '';
                        final spots = results
                            .map((r) => FlSpot(
                                r.recordedAt.millisecondsSinceEpoch.toDouble(),
                                r.value))
                            .toList();

                        final List<HorizontalLine> horizontalLines = [];
                        final normalMin = labIndicators[code]?['normalMin'];
                        final normalMax = labIndicators[code]?['normalMax'];

                        if (normalMin != null) {
                          horizontalLines.add(HorizontalLine(
                            y: (normalMin as num).toDouble(),
                            color: Colors.red.withValues(alpha: 0.2),
                            dashArray: [4, 4],
                            label: HorizontalLineLabel(
                                show: true,
                                labelResolver: (_) => l10n.minLimit,
                                style: const TextStyle(fontSize: 8)),
                          ));
                        }
                        if (normalMax != null) {
                          horizontalLines.add(HorizontalLine(
                            y: (normalMax as num).toDouble(),
                            color: Colors.red.withValues(alpha: 0.2),
                            dashArray: [4, 4],
                            label: HorizontalLineLabel(
                                show: true,
                                labelResolver: (_) => l10n.maxLimit,
                                style: const TextStyle(fontSize: 8)),
                          ));
                        }

                        return TrendLineChart(
                          lines: [
                            LineChartBarData(
                              spots: spots,
                              color: tabIndex == 2
                                  ? Colors.purple
                                  : (tabIndex == 3
                                      ? Colors.deepOrange
                                      : Colors.green),
                              barWidth: 3,
                              isCurved: true,
                            ),
                          ],
                          targetLines: horizontalLines,
                          yAxisLabel: unit,
                          tooltipValueFormatter: (v) => v.toStringAsFixed(1),
                        );
                      },
                      loading: () =>
                          const Center(child: CircularProgressIndicator()),
                      error: (e, _) => Text('Error: $e'),
                    ),
              ),
            )),
      ],
    );
  }

  // ── Shared UI Components ──────────────────────────────────────────────────
  Widget _buildFilterRow(int tabIndex) {
    final current = _tabFilters[tabIndex] ?? HistoryFilter.month;
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: HistoryFilter.values.map((f) {
          final isSelected = current == f;
          return Padding(
            padding: const EdgeInsets.only(left: 8),
            child: ChoiceChip(
              label: Text(f.label),
              selected: isSelected,
              onSelected: (_) => setState(() => _tabFilters[tabIndex] = f),
              selectedColor: AppColors.primary,
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : AppColors.textPrimary,
                fontSize: 12,
              ),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildCard({required String title, required Widget child}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.bgSurfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: isDark
            ? Border.all(color: AppColors.borderBaseDark.withValues(alpha: 0.1))
            : null,
        boxShadow: isDark
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: AppTextStyles.h3.copyWith(
                color:
                    isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
              )),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }

  // ── Tab 6: Nutrition Summary ──────────────────────────────────────────────
  Widget _buildNutritionTab() {
    final filter = _tabFilters[5] ?? HistoryFilter.month;
    final readingsAsync = ref.watch(dailyReadingsHistoryProvider(filter));

    final l10n = AppLocalizations.of(context)!;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildFilterRow(5),
          const SizedBox(height: 16),
          _buildNutrientTrend(
            title: l10n.potassiumTrend,
            readingsAsync: readingsAsync,
            valueSelector: (r) => r.potassiumMg?.toDouble(),
            color: Colors.orange,
            unit: 'mg',
          ),
          const SizedBox(height: 16),
          _buildNutrientTrend(
            title: l10n.phosphorusTrend,
            readingsAsync: readingsAsync,
            valueSelector: (r) => r.phosphorusMg?.toDouble(),
            color: Colors.purple,
            unit: 'mg',
          ),
          const SizedBox(height: 16),
          _buildNutrientTrend(
            title: l10n.sodiumTrend,
            readingsAsync: readingsAsync,
            valueSelector: (r) => r.sodiumMg?.toDouble(),
            color: Colors.blue,
            unit: 'mg',
          ),
          const SizedBox(height: 16),
          _buildNutrientTrend(
            title: l10n.proteinTrend,
            readingsAsync: readingsAsync,
            valueSelector: (r) => r.proteinG?.toDouble(),
            color: Colors.green,
            unit: 'g',
          ),
        ],
      ),
    );
  }

  Widget _buildNutrientTrend({
    required String title,
    required AsyncValue<List<DailyReading>> readingsAsync,
    required double? Function(DailyReading) valueSelector,
    required Color color,
    required String unit,
  }) {
    return _buildCard(
      title: title,
      child: readingsAsync.when(
        data: (data) {
          final spots = data
              .where((r) => valueSelector(r) != null)
              .map((r) => FlSpot(
                  r.date.millisecondsSinceEpoch.toDouble(), valueSelector(r)!))
              .toList();

          if (spots.isEmpty)
            return Center(
                child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(AppLocalizations.of(context)!.noResults)));

          return TrendLineChart(
            lines: [
              LineChartBarData(
                spots: spots,
                color: color,
                barWidth: 3,
                isCurved: true,
              ),
            ],
            yAxisLabel: unit,
            tooltipValueFormatter: (v) => v.toStringAsFixed(1),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Text('Error: $e'),
      ),
    );
  }
}
