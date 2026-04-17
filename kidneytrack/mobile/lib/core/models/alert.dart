import '../theme/app_types.dart';

class AlertModel {
  final String id;
  final IndicatorStatus status;
  final String title;
  final String message;
  final DateTime date;
  final bool isRead;

  AlertModel({
    required this.id,
    required this.status,
    required this.title,
    required this.message,
    required this.date,
    required this.isRead,
  });

  factory AlertModel.fromJson(Map<String, dynamic> json) {
    // Map backend AlertType to IndicatorStatus
    final backendType = json['alertType'] as String;
    IndicatorStatus status;
    switch (backendType) {
      case 'CRITICAL':
        status = IndicatorStatus.critical;
        break;
      case 'WARNING':
        status = IndicatorStatus.warning;
        break;
      default:
        status = IndicatorStatus.safe;
    }

    return AlertModel(
      id: json['id'],
      status: status,
      title: json['indicatorName'] ?? 'تنبيه',
      message: json['messageAr'] ?? '',
      date: DateTime.parse(json['createdAt']),
      isRead: json['isRead'] ?? false,
    );
  }
}
