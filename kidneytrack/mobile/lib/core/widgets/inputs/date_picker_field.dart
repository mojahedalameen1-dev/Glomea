// DB Schema Check:
// - Patient.birthDate → TIMESTAMP, nullable, range: 1900-01-01 to today
// - Patient.dialysisStartDate → TIMESTAMP, nullable, range: 1960-01-01 to today
// - Medication.start_date → DATE, NOT NULL, range: 1960-01-01 to future
// - Medication.end_date → DATE, nullable
// - LabResult.recordedAt → TIMESTAMPTZ, range: 1960-01-01 to today
// - DailyReading.reading_date → DATE, range: 1960-01-01 to today

import 'package:flutter/material.dart';
import 'package:intl/intl.dart' as intl;
import './app_text_field.dart';

class DatePickerField extends StatelessWidget {
  final String label;
  final DateTime? selectedDate;
  final ValueChanged<DateTime> onDateSelected;
  final DateTime? firstDate;
  final DateTime? lastDate;

  DatePickerField({
    super.key,
    required this.label,
    this.selectedDate,
    required this.onDateSelected,
    this.firstDate,
    this.lastDate,
  }) : assert(firstDate == null || lastDate == null || !firstDate.isAfter(lastDate), 
          'firstDate ($firstDate) cannot be after lastDate ($lastDate)');

  DateTime _safeInitialDate({
    required DateTime? currentValue,
    required DateTime firstDate,
    required DateTime lastDate,
  }) {
    final today = DateTime.now();
    // Default fallback is today, unless today is after lastDate or before firstDate
    DateTime fallback = today;
    if (fallback.isAfter(lastDate)) fallback = lastDate;
    if (fallback.isBefore(firstDate)) fallback = firstDate;

    if (currentValue == null) return fallback;
    if (currentValue.isBefore(firstDate)) return firstDate;
    if (currentValue.isAfter(lastDate)) return lastDate;
    return currentValue;
  }

  @override
  Widget build(BuildContext context) {
    final effectiveFirstDate = firstDate ?? DateTime(1900);
    final effectiveLastDate = lastDate ?? DateTime.now();

    return AppTextField(
      label: label,
      readOnly: true,
      controller: TextEditingController(
        text: selectedDate != null 
          ? intl.DateFormat('yyyy-MM-dd').format(selectedDate!) 
          : '',
      ),
      hint: 'اختر التاريخ',
      onTap: () async {
        final DateTime initial = _safeInitialDate(
          currentValue: selectedDate,
          firstDate: effectiveFirstDate,
          lastDate: effectiveLastDate,
        );

        final DateTime? picked = await showDatePicker(
          context: context,
          initialDate: initial,
          firstDate: effectiveFirstDate,
          lastDate: effectiveLastDate,
        );
        if (picked != null && picked != selectedDate) {
          onDateSelected(picked);
        }
      },
      suffixIcon: const Icon(Icons.calendar_today_outlined),
    );
  }
}
