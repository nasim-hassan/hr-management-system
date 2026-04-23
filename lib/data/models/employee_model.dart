import 'package:hr_management_system/core/enums/app_enums.dart';

/// Employee Model - Extended employee information
class Employee {
  final String id;
  final String userId; // Reference to User
  final String firstName;
  final String lastName;
  final String email;
  final String phoneNumber;
  final String? address;
  final String? city;
  final String? state;
  final String? zipCode;
  final String? country;
  final DateTime dateOfBirth;
  final String? gender;
  final String? maritalStatus;
  final DateTime dateOfJoining;
  final Designation designation;
  final String department;
  final String? manager; // Manager's user ID
  final String? salary;
  final String? accountNumber;
  final String? bankName;
  final String? ifscCode;
  final String? panNumber;
  final String? aadharNumber;
  final String? emergencyContact;
  final String? emergencyContactNumber;
  final bool isActive;
  final DateTime createdAt;
  final DateTime? updatedAt;

  Employee({
    required this.id,
    required this.userId,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phoneNumber,
    this.address,
    this.city,
    this.state,
    this.zipCode,
    this.country,
    required this.dateOfBirth,
    this.gender,
    this.maritalStatus,
    required this.dateOfJoining,
    required this.designation,
    required this.department,
    this.manager,
    this.salary,
    this.accountNumber,
    this.bankName,
    this.ifscCode,
    this.panNumber,
    this.aadharNumber,
    this.emergencyContact,
    this.emergencyContactNumber,
    required this.isActive,
    required this.createdAt,
    this.updatedAt,
  });

  String get fullName => '$firstName $lastName';

  factory Employee.fromJson(Map<String, dynamic> json) {
    return Employee(
      id: json['id'] ?? '',
      userId: json['user_id'] ?? '',
      firstName: json['first_name'] ?? '',
      lastName: json['last_name'] ?? '',
      email: json['email'] ?? '',
      phoneNumber: json['phone_number'] ?? '',
      address: json['address'],
      city: json['city'],
      state: json['state'],
      zipCode: json['zip_code'],
      country: json['country'],
      dateOfBirth: json['date_of_birth'] != null
          ? DateTime.parse(json['date_of_birth'])
          : DateTime.now(),
      gender: json['gender'],
      maritalStatus: json['marital_status'],
      dateOfJoining: json['date_of_joining'] != null
          ? DateTime.parse(json['date_of_joining'])
          : DateTime.now(),
      designation:
          Designation.fromString(json['designation'] ?? 'intern'),
      department: json['department'] ?? '',
      manager: json['manager'],
      salary: json['salary'],
      accountNumber: json['account_number'],
      bankName: json['bank_name'],
      ifscCode: json['ifsc_code'],
      panNumber: json['pan_number'],
      aadharNumber: json['aadhar_number'],
      emergencyContact: json['emergency_contact'],
      emergencyContactNumber: json['emergency_contact_number'],
      isActive: json['is_active'] ?? true,
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
      'user_id': userId,
      'first_name': firstName,
      'last_name': lastName,
      'email': email,
      'phone_number': phoneNumber,
      'address': address,
      'city': city,
      'state': state,
      'zip_code': zipCode,
      'country': country,
      'date_of_birth': dateOfBirth.toIso8601String(),
      'gender': gender,
      'marital_status': maritalStatus,
      'date_of_joining': dateOfJoining.toIso8601String(),
      'designation': designation.toStringValue(),
      'department': department,
      'manager': manager,
      'salary': salary,
      'account_number': accountNumber,
      'bank_name': bankName,
      'ifsc_code': ifscCode,
      'pan_number': panNumber,
      'aadhar_number': aadharNumber,
      'emergency_contact': emergencyContact,
      'emergency_contact_number': emergencyContactNumber,
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
    String? state,
    String? zipCode,
    String? country,
    DateTime? dateOfBirth,
    String? gender,
    String? maritalStatus,
    DateTime? dateOfJoining,
    Designation? designation,
    String? department,
    String? manager,
    String? salary,
    String? accountNumber,
    String? bankName,
    String? ifscCode,
    String? panNumber,
    String? aadharNumber,
    String? emergencyContact,
    String? emergencyContactNumber,
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
      state: state ?? this.state,
      zipCode: zipCode ?? this.zipCode,
      country: country ?? this.country,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      gender: gender ?? this.gender,
      maritalStatus: maritalStatus ?? this.maritalStatus,
      dateOfJoining: dateOfJoining ?? this.dateOfJoining,
      designation: designation ?? this.designation,
      department: department ?? this.department,
      manager: manager ?? this.manager,
      salary: salary ?? this.salary,
      accountNumber: accountNumber ?? this.accountNumber,
      bankName: bankName ?? this.bankName,
      ifscCode: ifscCode ?? this.ifscCode,
      panNumber: panNumber ?? this.panNumber,
      aadharNumber: aadharNumber ?? this.aadharNumber,
      emergencyContact: emergencyContact ?? this.emergencyContact,
      emergencyContactNumber:
          emergencyContactNumber ?? this.emergencyContactNumber,
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
    return 'Employee(id: $id, fullName: $fullName, designation: ${designation.displayName})';
  }
}
