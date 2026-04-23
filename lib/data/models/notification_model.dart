import 'package:hr_management_system/core/enums/app_enums.dart';

/// Notification Model
class Notification {
  final String id;
  final String userId; // Recipient user ID
  final NotificationType type;
  final String title;
  final String message;
  final String? relatedId; // ID of related entity (leave request, etc.)
  final String? relatedType; // Type of related entity
  final Map<String, dynamic>? data; // Additional data
  final bool isRead;
  final DateTime createdAt;
  final DateTime? readAt;

  Notification({
    required this.id,
    required this.userId,
    required this.type,
    required this.title,
    required this.message,
    this.relatedId,
    this.relatedType,
    this.data,
    required this.isRead,
    required this.createdAt,
    this.readAt,
  });

  factory Notification.fromJson(Map<String, dynamic> json) {
    return Notification(
      id: json['id'] ?? '',
      userId: json['user_id'] ?? '',
      type: NotificationType.fromString(
          json['type'] ?? NotificationType.announcement.toStringValue()),
      title: json['title'] ?? '',
      message: json['message'] ?? '',
      relatedId: json['related_id'],
      relatedType: json['related_type'],
      data: json['data'],
      isRead: json['is_read'] ?? false,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
      readAt:
          json['read_at'] != null ? DateTime.parse(json['read_at']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'type': type.toStringValue(),
      'title': title,
      'message': message,
      'related_id': relatedId,
      'related_type': relatedType,
      'data': data,
      'is_read': isRead,
      'created_at': createdAt.toIso8601String(),
      'read_at': readAt?.toIso8601String(),
    };
  }

  Notification copyWith({
    String? id,
    String? userId,
    NotificationType? type,
    String? title,
    String? message,
    String? relatedId,
    String? relatedType,
    Map<String, dynamic>? data,
    bool? isRead,
    DateTime? createdAt,
    DateTime? readAt,
  }) {
    return Notification(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      type: type ?? this.type,
      title: title ?? this.title,
      message: message ?? this.message,
      relatedId: relatedId ?? this.relatedId,
      relatedType: relatedType ?? this.relatedType,
      data: data ?? this.data,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt ?? this.createdAt,
      readAt: readAt ?? this.readAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Notification &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'Notification(id: $id, title: $title, isRead: $isRead)';
  }
}
