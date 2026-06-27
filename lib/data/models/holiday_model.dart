/// Holiday Model - weekly and custom holidays configuration
class Holiday {
  final String id;
  final String name;
  final DateTime date;
  final DateTime? endDate;
  final bool isCustom;

  Holiday({
    required this.id,
    required this.name,
    required this.date,
    this.endDate,
    this.isCustom = true,
  });

  factory Holiday.fromJson(Map<String, dynamic> json) {
    return Holiday(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      date: json['date'] != null ? DateTime.parse(json['date']) : DateTime.now(),
      endDate: json['end_date'] != null ? DateTime.parse(json['end_date']) : null,
      isCustom: json['is_custom'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'date': date.toIso8601String(),
      'end_date': endDate?.toIso8601String(),
      'is_custom': isCustom,
    };
  }

  Holiday copyWith({
    String? id,
    String? name,
    DateTime? date,
    DateTime? endDate,
    bool? isCustom,
  }) {
    return Holiday(
      id: id ?? this.id,
      name: name ?? this.name,
      date: date ?? this.date,
      endDate: endDate ?? this.endDate,
      isCustom: isCustom ?? this.isCustom,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Holiday &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    final startStr = date.toIso8601String().split("T")[0];
    final endStr = endDate != null ? ' to ${endDate!.toIso8601String().split("T")[0]}' : '';
    return 'Holiday(id: $id, name: $name, range: $startStr$endStr)';
  }
}
