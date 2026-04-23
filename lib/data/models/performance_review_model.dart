import 'package:hr_management_system/core/enums/app_enums.dart';

/// Performance Review Model
class PerformanceReview {
  final String id;
  final String employeeId;
  final String reviewedBy; // Manager/HR user ID
  final int reviewYear;
  final int reviewQuarter;
  final double overallRating; // 1-5 scale
  final double performanceScore; // 1-100
  final String? strengths;
  final String? areasForImprovement;
  final String? comments;
  final ReviewStatus status;
  final DateTime reviewDate;
  final DateTime? nextReviewDate;
  final DateTime createdAt;
  final DateTime? updatedAt;

  PerformanceReview({
    required this.id,
    required this.employeeId,
    required this.reviewedBy,
    required this.reviewYear,
    required this.reviewQuarter,
    required this.overallRating,
    required this.performanceScore,
    this.strengths,
    this.areasForImprovement,
    this.comments,
    required this.status,
    required this.reviewDate,
    this.nextReviewDate,
    required this.createdAt,
    this.updatedAt,
  });

  String get quarterName => 'Q$reviewQuarter $reviewYear';

  factory PerformanceReview.fromJson(Map<String, dynamic> json) {
    return PerformanceReview(
      id: json['id'] ?? '',
      employeeId: json['employee_id'] ?? '',
      reviewedBy: json['reviewed_by'] ?? '',
      reviewYear: json['review_year'] ?? DateTime.now().year,
      reviewQuarter: json['review_quarter'] ?? 1,
      overallRating: (json['overall_rating'] ?? 0).toDouble(),
      performanceScore: (json['performance_score'] ?? 0).toDouble(),
      strengths: json['strengths'],
      areasForImprovement: json['areas_for_improvement'],
      comments: json['comments'],
      status: ReviewStatus.fromString(
          json['status'] ?? ReviewStatus.pending.toStringValue()),
      reviewDate: json['review_date'] != null
          ? DateTime.parse(json['review_date'])
          : DateTime.now(),
      nextReviewDate: json['next_review_date'] != null
          ? DateTime.parse(json['next_review_date'])
          : null,
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
      'employee_id': employeeId,
      'reviewed_by': reviewedBy,
      'review_year': reviewYear,
      'review_quarter': reviewQuarter,
      'overall_rating': overallRating,
      'performance_score': performanceScore,
      'strengths': strengths,
      'areas_for_improvement': areasForImprovement,
      'comments': comments,
      'status': status.toStringValue(),
      'review_date': reviewDate.toIso8601String(),
      'next_review_date': nextReviewDate?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  PerformanceReview copyWith({
    String? id,
    String? employeeId,
    String? reviewedBy,
    int? reviewYear,
    int? reviewQuarter,
    double? overallRating,
    double? performanceScore,
    String? strengths,
    String? areasForImprovement,
    String? comments,
    ReviewStatus? status,
    DateTime? reviewDate,
    DateTime? nextReviewDate,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return PerformanceReview(
      id: id ?? this.id,
      employeeId: employeeId ?? this.employeeId,
      reviewedBy: reviewedBy ?? this.reviewedBy,
      reviewYear: reviewYear ?? this.reviewYear,
      reviewQuarter: reviewQuarter ?? this.reviewQuarter,
      overallRating: overallRating ?? this.overallRating,
      performanceScore: performanceScore ?? this.performanceScore,
      strengths: strengths ?? this.strengths,
      areasForImprovement: areasForImprovement ?? this.areasForImprovement,
      comments: comments ?? this.comments,
      status: status ?? this.status,
      reviewDate: reviewDate ?? this.reviewDate,
      nextReviewDate: nextReviewDate ?? this.nextReviewDate,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PerformanceReview &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'PerformanceReview(id: $id, employeeId: $employeeId, quarter: $quarterName, rating: $overallRating/5)';
  }
}
