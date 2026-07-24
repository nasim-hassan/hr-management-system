/// Employee Model - Narrowed to identity, address, manager link, and bank details
class Employee {
  final String id;
  final String? userId; // Optional reference to User table
  final String firstName;
  final String lastName;
  final String email;
  final String phoneNumber;
  final String? address;
  final String? city;
  final String? zipCode;
  final String? country;
  final String? nidNumber;
  final String? manager; // Manager's user ID
  final String? accountNumber;
  final String? accountHolderName;
  final String? bankName;
  final String? branchName;
  final String? department;
  final String? designation;
  final double? baseSalary;
  final double? allowances;
  final bool isActive;
  final DateTime createdAt;
  final DateTime? updatedAt;

  Employee({
    required this.id,
    this.userId,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phoneNumber,
    this.address,
    this.city,
    this.zipCode,
    this.country,
    this.nidNumber,
    this.manager,
    this.accountNumber,
    this.accountHolderName,
    this.bankName,
    this.branchName,
    this.department,
    this.designation,
    this.baseSalary,
    this.allowances,
    required this.isActive,
    required this.createdAt,
    this.updatedAt,
  });

  String get fullName => '$firstName $lastName ($id)';

  factory Employee.fromJson(Map<String, dynamic> json) {
    DateTime parseDateTime(dynamic value) {
      if (value == null) return DateTime.now();
      if (value is String) {
        try {
          if (value.length == 10 && !value.contains('T')) {
            return DateTime.parse('${value}T00:00:00Z');
          }
          return DateTime.parse(value);
        } catch (_) {
          return DateTime.now();
        }
      }
      return DateTime.now();
    }

    double? parseNullableDouble(dynamic value) {
      if (value == null) return null;
      if (value is num) return value.toDouble();
      return double.tryParse(value.toString());
    }

    return Employee(
      id: json['id']?.toString() ?? '',
      userId: json['user_id']?.toString(),
      firstName: json['first_name'] ?? '',
      lastName: json['last_name'] ?? '',
      email: json['email'] ?? '',
      phoneNumber: json['phone_number'] ?? '',
      address: json['address'],
      city: json['city'],
      zipCode: json['zip_code'],
      country: json['country'],
      nidNumber: json['nid_number'],
      manager: json['manager'],
      accountNumber: json['account_number'],
      accountHolderName: json['account_holder_name'],
      bankName: json['bank_name'],
      branchName: json['branch_name'],
      department: json['department'],
      designation: json['designation'],
      baseSalary: parseNullableDouble(json['base_salary']),
      allowances: parseNullableDouble(json['allowances']),
      isActive: json['is_active'] ?? true,
      createdAt: parseDateTime(json['created_at']),
      updatedAt: json['updated_at'] != null ? parseDateTime(json['updated_at']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'first_name': firstName,
      'last_name': lastName,
      'email': email,
      'phone_number': phoneNumber,
      'address': address,
      'city': city,
      'zip_code': zipCode,
      'country': country,
      'nid_number': nidNumber,
      'manager': manager,
      'account_number': accountNumber,
      'account_holder_name': accountHolderName,
      'bank_name': bankName,
      'branch_name': branchName,
      'department': department,
      'designation': designation,
      'base_salary': baseSalary,
      'allowances': allowances,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  Employee copyWith({
    String? id,
    String? userId,
    String? firstName,
    String? lastName,
    String? email,
    String? phoneNumber,
    String? address,
    String? city,
    String? zipCode,
    String? country,
    String? nidNumber,
    String? manager,
    String? accountNumber,
    String? accountHolderName,
    String? branchName,
    String? bankName,
    String? department,
    String? designation,
    double? baseSalary,
    double? allowances,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Employee(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      address: address ?? this.address,
      city: city ?? this.city,
      zipCode: zipCode ?? this.zipCode,
      country: country ?? this.country,
      nidNumber: nidNumber ?? this.nidNumber,
      manager: manager ?? this.manager,
      accountNumber: accountNumber ?? this.accountNumber,
      accountHolderName: accountHolderName ?? this.accountHolderName,
      bankName: bankName ?? this.bankName,
      branchName: branchName ?? this.branchName,
      department: department ?? this.department,
      designation: designation ?? this.designation,
      baseSalary: baseSalary ?? this.baseSalary,
      allowances: allowances ?? this.allowances,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Employee &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'Employee(id: $id, fullName: $fullName)';
  }
}
