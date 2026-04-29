import 'package:hr_management_system/core/enums/app_enums.dart';

/// Report Model - System generated reports
class Report {
  final String id;
  final String title;
  final String description;
  final ReportType type;
  final String generatedBy; // User ID who generated the report
  final ReportStatus status;
  final DateTime? dateRangeStart;
  final DateTime? dateRangeEnd;
  final String? fileUrl; // URL to the generated report file (PDF, CSV, etc.)
  final DateTime createdAt;
  final DateTime? updatedAt;

  Report({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.generatedBy,
    required this.status,
    this.dateRangeStart,
    this.dateRangeEnd,
    this.fileUrl,
    required this.createdAt,
    this.updatedAt,
  });

  factory Report.fromJson(Map<String, dynamic> json) {
    return Report(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      type: ReportType.fromString(json['type'] ?? ReportType.other.toStringValue()),
      generatedBy: json['generated_by'] ?? '',
      status: ReportStatus.fromString(json['status'] ?? ReportStatus.pending.toStringValue()),
      dateRangeStart: json['date_range_start'] != null
          ? DateTime.parse(json['date_range_start'])
          : null,
      dateRangeEnd: json['date_range_end'] != null
          ? DateTime.parse(json['date_range_end'])
          : null,
      fileUrl: json['file_url'],
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'type': type.toStringValue(),
      'generated_by': generatedBy,
      'status': status.toStringValue(),
      'date_range_start': dateRangeStart?.toIso8601String(),
      'date_range_end': dateRangeEnd?.toIso8601String(),
      'file_url': fileUrl,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  Report copyWith({
    String? id,
    String? title,
    String? description,
    ReportType? type,
    String? generatedBy,
    ReportStatus? status,
    DateTime? dateRangeStart,
    DateTime? dateRangeEnd,
    String? fileUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Report(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      type: type ?? this.type,
      generatedBy: generatedBy ?? this.generatedBy,
      status: status ?? this.status,
      dateRangeStart: dateRangeStart ?? this.dateRangeStart,
      dateRangeEnd: dateRangeEnd ?? this.dateRangeEnd,
      fileUrl: fileUrl ?? this.fileUrl,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Report && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'Report(id: $id, title: $title, type: ${type.displayName}, status: ${status.displayName})';
  }
}
