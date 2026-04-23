# HR Management System - Data Models Documentation

## Overview
This document describes all the data models used in the HR Management System application. All models include JSON serialization/deserialization (`fromJson`, `toJson`, `copyWith` methods) and comprehensive mock data for testing.

---

## 📋 Enums (app_enums.dart)

### UserRole
Defines the three user types in the system:
- `hrAdmin` - HR Administrator with full system access
- `manager` - Manager for team supervision and leave approvals
- `employee` - Regular employee with limited access

### LeaveStatus
Status of leave requests:
- `pending` - Awaiting approval
- `approved` - Approved by manager
- `rejected` - Rejected by manager
- `cancelled` - Cancelled by employee

### LeaveType
Types of leaves available:
- `annual` - Annual/vacation leave
- `sick` - Sick leave
- `casual` - Casual leave
- `maternity` - Maternity leave
- `paternity` - Paternity leave
- `unpaid` - Unpaid leave

### AttendanceStatus
Daily attendance marking:
- `present` - Present in office
- `absent` - Absent
- `halfDay` - Half-day work
- `onLeave` - On approved leave
- `remote` - Working from home

### ReviewStatus
Performance review status:
- `pending` - Not yet conducted
- `inProgress` - Currently being reviewed
- `completed` - Review completed

### NotificationType
Types of notifications:
- `leaveApproved` - Leave request approved
- `leaveRejected` - Leave request rejected
- `attendanceReminder` - Mark attendance reminder
- `payslipReady` - Salary slip generated
- `performanceReview` - Review notification
- `announcement` - General announcements

### Designation
Employee positions:
- `intern`, `juniorDeveloper`, `seniorDeveloper`, `technicalLead`, `manager`, `director`, `cto`, `ceo`

---

## 👤 Models

### 1. User Model (`user_model.dart`)
**Purpose:** Authentication and basic user information

**Fields:**
- `id` - Unique user identifier (String)
- `email` - Email address (String)
- `fullName` - User's full name (String?)
- `role` - UserRole enum
- `phoneNumber` - Contact number (String?)
- `profileImage` - Profile picture URL (String?)
- `isActive` - Account status (bool)
- `createdAt` - Account creation date (DateTime)
- `updatedAt` - Last update date (DateTime?)

**Mock Data:** 5 users (1 HR Admin, 1 Manager, 3 Employees)

---

### 2. Employee Model (`employee_model.dart`)
**Purpose:** Extended employee information and HR details

**Fields:**
- `id` - Employee record ID (String)
- `userId` - Reference to User (String)
- `firstName`, `lastName` - Name (String)
- `email`, `phoneNumber` - Contact info (String)
- `address`, `city`, `state`, `zipCode`, `country` - Address (String?)
- `dateOfBirth` - DOB (DateTime)
- `gender`, `maritalStatus` - Personal info (String?)
- `dateOfJoining` - Employment start date (DateTime)
- `designation` - Designation enum
- `department` - Department name (String)
- `manager` - Manager's user ID (String?)
- `salary` - Base salary (String?)
- `accountNumber`, `bankName`, `ifscCode` - Bank details (String?)
- `panNumber`, `aadharNumber` - Government IDs (String?)
- `emergencyContact`, `emergencyContactNumber` - Emergency info (String?)
- `isActive` - Active status (bool)
- `createdAt`, `updatedAt` - Timestamps (DateTime)

**Computed Property:**
- `fullName` - Returns combined first + last name

**Mock Data:** 3 employees with complete details (various designations)

---

### 3. Attendance Model (`attendance_model.dart`)
**Purpose:** Daily attendance tracking with check-in/out times

**Fields:**
- `id` - Record ID (String)
- `employeeId` - Employee reference (String)
- `date` - Attendance date (DateTime)
- `checkInTime` - Clock-in time (DateTime?)
- `checkOutTime` - Clock-out time (DateTime?)
- `status` - AttendanceStatus enum
- `notes` - Additional notes (String?)
- `location` - Work location (String?)
- `latitude`, `longitude` - GPS coordinates (double?)
- `createdAt`, `updatedAt` - Timestamps (DateTime)

**Computed Method:**
- `getWorkDuration()` - Calculates hours worked (Duration?)

**Mock Data:** 4 attendance records with various statuses

---

### 4. LeaveRequest Model (`leave_request_model.dart`)
**Purpose:** Leave application and approval workflow

**Fields:**
- `id` - Request ID (String)
- `employeeId` - Employee reference (String)
- `leaveType` - LeaveType enum
- `startDate`, `endDate` - Leave dates (DateTime)
- `numberOfDays` - Days requested (int)
- `reason` - Leave reason (String?)
- `status` - LeaveStatus enum
- `approvedBy` - Manager's user ID (String?)
- `approvedDate` - Approval date (DateTime?)
- `rejectionReason` - Rejection explanation (String?)
- `createdAt`, `updatedAt` - Timestamps (DateTime)

**Computed Properties:**
- `isPending` - Check if awaiting approval
- `isApproved` - Check if approved
- `isRejected` - Check if rejected

**Mock Data:** 4 leave requests with different statuses

---

### 5. Payroll Model (`payroll_model.dart`)
**Purpose:** Employee salary and payment information

**Fields:**
- `id` - Payroll record ID (String)
- `employeeId` - Employee reference (String)
- `month`, `year` - Salary period (int)
- `baseSalary` - Base salary amount (double)
- `bonus` - Bonus amount (double?)
- `deductions` - Total deductions (double?)
- `allowances` - Allowances (double?)
- `netSalary` - Final salary (double)
- `paymentDate` - Payment date (DateTime)
- `payslipUrl` - PDF URL (String?)
- `transactionId` - Payment transaction ID (String?)
- `isPaid` - Payment status (bool)
- `notes` - Additional notes (String?)
- `createdAt`, `updatedAt` - Timestamps (DateTime)

**Computed Method:**
- `getMonthName()` - Returns month name as string

**Mock Data:** 4 payroll records for different employees

---

### 6. PerformanceReview Model (`performance_review_model.dart`)
**Purpose:** Employee performance evaluation

**Fields:**
- `id` - Review ID (String)
- `employeeId` - Employee reference (String)
- `reviewedBy` - Manager/HR user ID (String)
- `reviewYear`, `reviewQuarter` - Review period (int)
- `overallRating` - Rating 1-5 (double)
- `performanceScore` - Score 1-100 (double)
- `strengths` - Employee strengths (String?)
- `areasForImprovement` - Areas to improve (String?)
- `comments` - Reviewer comments (String?)
- `status` - ReviewStatus enum
- `reviewDate` - Review date (DateTime)
- `nextReviewDate` - Scheduled next review (DateTime?)
- `createdAt`, `updatedAt` - Timestamps (DateTime)

**Computed Property:**
- `quarterName` - Returns "Q1 2024" format

**Mock Data:** 3 performance reviews with various statuses

---

### 7. Notification Model (`notification_model.dart`)
**Purpose:** System notifications for users

**Fields:**
- `id` - Notification ID (String)
- `userId` - Recipient user ID (String)
- `type` - NotificationType enum
- `title` - Notification title (String)
- `message` - Notification message (String)
- `relatedId` - Related entity ID (String?)
- `relatedType` - Related entity type (String?)
- `data` - Additional data (Map<String, dynamic>?)
- `isRead` - Read status (bool)
- `createdAt` - Creation date (DateTime)
- `readAt` - Read date (DateTime?)

**Mock Data:** 5 notifications with different types and states

---

## 📊 Mock Data Provider (`mock_data.dart`)

Complete mock dataset for testing with utility methods:

### Mock Data Collections
- **mockUsers**: 5 users (different roles)
- **mockEmployees**: 3 employees with full details
- **mockAttendance**: 4 attendance records
- **mockLeaveRequests**: 4 leave requests
- **mockPayroll**: 4 payroll records
- **mockPerformanceReviews**: 3 reviews
- **mockNotifications**: 5 notifications

### Utility Methods
```dart
// Get all data
getAllMockData() -> Map<String, dynamic>

// Filter by role
getMockUsersByRole(UserRole role) -> List<User>

// Get employee records
getMockAttendanceByEmployee(String employeeId)
getMockLeaveRequestsByEmployee(String employeeId)
getMockPayrollByEmployee(String employeeId)

// Get user notifications
getMockNotificationsByUser(String userId)
getUnreadNotifications(String userId)

// Get statistics
getMockStatistics() -> Map<String, dynamic>
```

---

## 🔄 Common Model Features

All models implement:

### JSON Serialization
```dart
// Convert to JSON
Map<String, dynamic> toJson()

// Create from JSON
factory Model.fromJson(Map<String, dynamic> json)
```

### Immutability
```dart
// Create modified copy
Model copyWith({
  String? id,
  // ... other optional fields
})
```

### Equality & Hashing
```dart
@override
bool operator ==(Object other)

@override
int get hashCode
```

### String Representation
```dart
@override
String toString()
```

---

## 📱 Database Schema Preview

Based on these models, the PostgreSQL schema will include:

```
Tables:
- users (authentication + basic info)
- employees (extended employee details)
- attendance (daily records with timestamps)
- leave_requests (leave applications)
- payroll (salary records)
- performance_reviews (annual evaluations)
- notifications (user notifications)

Relationships:
- users (1) ← → (1) employees
- users (1) ← → (many) attendance
- users (1) ← → (many) leave_requests
- users (1) ← → (many) payroll
- users (1) ← → (many) performance_reviews
- users (1) ← → (many) notifications
```

---

## ✅ Next Steps

1. **Define Database Schema** - Use these models to create PostgreSQL tables
2. **Create Repositories** - Data access layer for Supabase
3. **Implement Riverpod Providers** - State management
4. **Build Repository Tests** - Unit tests using mock data
5. **Create UI Screens** - Use models in Flutter widgets

---

## 📝 Notes

- All models use snake_case for JSON field names (Supabase convention)
- Models use camelCase for Dart property names
- Mock data includes realistic sample values
- All timestamps are in UTC ISO 8601 format
- Foreign key relationships are maintained via ID fields
- Models support null-safe Dart syntax

---

**Generated for HR Management System v1.0**
