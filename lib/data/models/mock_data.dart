import 'package:hr_management_system/core/enums/app_enums.dart';
import 'package:hr_management_system/data/models/user_model.dart';
import 'package:hr_management_system/data/models/employee_model.dart';
import 'package:hr_management_system/data/models/attendance_model.dart';
import 'package:hr_management_system/data/models/leave_request_model.dart';
import 'package:hr_management_system/data/models/payroll_model.dart';
import 'package:hr_management_system/data/models/performance_review_model.dart';
import 'package:hr_management_system/data/models/notification_model.dart';

/// Mock Data Provider - Contains test data for all models
class MockDataProvider {
  // ==================== MOCK USERS ====================
  static final List<User> mockUsers = [
    User(
      id: 'user_1',
      email: 'admin@hrsystem.com',
      fullName: 'Rajesh Kumar',
      role: UserRole.hrAdmin,
      phoneNumber: '+91-9876543210',
      profileImage: null,
      isActive: true,
      createdAt: DateTime(2024, 1, 15),
    ),
    User(
      id: 'user_2',
      email: 'manager1@hrsystem.com',
      fullName: 'Priya Sharma',
      role: UserRole.manager,
      phoneNumber: '+91-9876543211',
      profileImage: null,
      isActive: true,
      createdAt: DateTime(2024, 2, 10),
    ),
    User(
      id: 'user_3',
      email: 'emp1@hrsystem.com',
      fullName: 'Amit Patel',
      role: UserRole.employee,
      phoneNumber: '+91-9876543212',
      profileImage: null,
      isActive: true,
      createdAt: DateTime(2024, 3, 5),
    ),
    User(
      id: 'user_4',
      email: 'emp2@hrsystem.com',
      fullName: 'Sneha Gupta',
      role: UserRole.employee,
      phoneNumber: '+91-9876543213',
      profileImage: null,
      isActive: true,
      createdAt: DateTime(2024, 3, 8),
    ),
    User(
      id: 'user_5',
      email: 'emp3@hrsystem.com',
      fullName: 'Vikram Singh',
      role: UserRole.employee,
      phoneNumber: '+91-9876543214',
      profileImage: null,
      isActive: true,
      createdAt: DateTime(2024, 4, 1),
    ),
  ];

  // ==================== MOCK EMPLOYEES ====================
  static final List<Employee> mockEmployees = [
    Employee(
      id: 'emp_1',
      userId: 'user_3',
      firstName: 'Amit',
      lastName: 'Patel',
      email: 'emp1@hrsystem.com',
      phoneNumber: '+91-9876543212',
      address: '123 Tech Street',
      city: 'Bangalore',
      state: 'Karnataka',
      zipCode: '560001',
      country: 'India',
      dateOfBirth: DateTime(1995, 6, 15),
      gender: 'Male',
      maritalStatus: 'Single',
      dateOfJoining: DateTime(2022, 3, 1),
      designation: Designation.juniorDeveloper,
      department: 'Engineering',
      manager: 'user_2',
      salary: '500000',
      accountNumber: '123456789012',
      bankName: 'State Bank of India',
      ifscCode: 'SBIN0001234',
      panNumber: 'ABCDE1234F',
      aadharNumber: '123456789012',
      emergencyContact: 'Rajesh Patel',
      emergencyContactNumber: '+91-9876543220',
      isActive: true,
      createdAt: DateTime(2022, 3, 1),
    ),
    Employee(
      id: 'emp_2',
      userId: 'user_4',
      firstName: 'Sneha',
      lastName: 'Gupta',
      email: 'emp2@hrsystem.com',
      phoneNumber: '+91-9876543213',
      address: '456 Innovation Ave',
      city: 'Bangalore',
      state: 'Karnataka',
      zipCode: '560002',
      country: 'India',
      dateOfBirth: DateTime(1998, 8, 22),
      gender: 'Female',
      maritalStatus: 'Single',
      dateOfJoining: DateTime(2023, 2, 15),
      designation: Designation.juniorDeveloper,
      department: 'Engineering',
      manager: 'user_2',
      salary: '520000',
      accountNumber: '123456789013',
      bankName: 'HDFC Bank',
      ifscCode: 'HDFC0001234',
      panNumber: 'ABCDE1235F',
      aadharNumber: '123456789013',
      emergencyContact: 'Kavya Gupta',
      emergencyContactNumber: '+91-9876543221',
      isActive: true,
      createdAt: DateTime(2023, 2, 15),
    ),
    Employee(
      id: 'emp_3',
      userId: 'user_5',
      firstName: 'Vikram',
      lastName: 'Singh',
      email: 'emp3@hrsystem.com',
      phoneNumber: '+91-9876543214',
      address: '789 Dev Park',
      city: 'Bangalore',
      state: 'Karnataka',
      zipCode: '560003',
      country: 'India',
      dateOfBirth: DateTime(1992, 12, 10),
      gender: 'Male',
      maritalStatus: 'Married',
      dateOfJoining: DateTime(2021, 5, 1),
      designation: Designation.seniorDeveloper,
      department: 'Engineering',
      manager: 'user_2',
      salary: '750000',
      accountNumber: '123456789014',
      bankName: 'Axis Bank',
      ifscCode: 'AXIS0001234',
      panNumber: 'ABCDE1236F',
      aadharNumber: '123456789014',
      emergencyContact: 'Priya Singh',
      emergencyContactNumber: '+91-9876543222',
      isActive: true,
      createdAt: DateTime(2021, 5, 1),
    ),
  ];

  // ==================== MOCK ATTENDANCE ====================
  static final List<Attendance> mockAttendance = [
    Attendance(
      id: 'att_1',
      employeeId: 'emp_1',
      date: DateTime(2024, 4, 23),
      checkInTime: DateTime(2024, 4, 23, 9, 15),
      checkOutTime: DateTime(2024, 4, 23, 18, 30),
      status: AttendanceStatus.present,
      notes: 'Regular attendance',
      location: 'Office - Bangalore',
      latitude: 12.9716,
      longitude: 77.5946,
      createdAt: DateTime(2024, 4, 23),
    ),
    Attendance(
      id: 'att_2',
      employeeId: 'emp_1',
      date: DateTime(2024, 4, 24),
      checkInTime: DateTime(2024, 4, 24, 10, 0),
      checkOutTime: DateTime(2024, 4, 24, 17, 45),
      status: AttendanceStatus.present,
      notes: 'Late by 45 minutes',
      location: 'Office - Bangalore',
      latitude: 12.9716,
      longitude: 77.5946,
      createdAt: DateTime(2024, 4, 24),
    ),
    Attendance(
      id: 'att_3',
      employeeId: 'emp_2',
      date: DateTime(2024, 4, 23),
      checkInTime: DateTime(2024, 4, 23, 9, 0),
      checkOutTime: DateTime(2024, 4, 23, 13, 0),
      status: AttendanceStatus.halfDay,
      notes: 'Doctor appointment in afternoon',
      location: 'Office - Bangalore',
      latitude: 12.9716,
      longitude: 77.5946,
      createdAt: DateTime(2024, 4, 23),
    ),
    Attendance(
      id: 'att_4',
      employeeId: 'emp_3',
      date: DateTime(2024, 4, 24),
      checkInTime: DateTime(2024, 4, 24, 9, 0),
      checkOutTime: DateTime(2024, 4, 24, 18, 0),
      status: AttendanceStatus.present,
      notes: 'Working from office',
      location: 'Office - Bangalore',
      latitude: 12.9716,
      longitude: 77.5946,
      createdAt: DateTime(2024, 4, 24),
    ),
  ];

  // ==================== MOCK LEAVE REQUESTS ====================
  static final List<LeaveRequest> mockLeaveRequests = [
    LeaveRequest(
      id: 'leave_1',
      employeeId: 'emp_1',
      leaveType: LeaveType.annual,
      startDate: DateTime(2024, 5, 1),
      endDate: DateTime(2024, 5, 5),
      numberOfDays: 5,
      reason: 'Summer vacation with family',
      status: LeaveStatus.approved,
      approvedBy: 'user_2',
      approvedDate: DateTime(2024, 4, 20),
      rejectionReason: null,
      createdAt: DateTime(2024, 4, 18),
    ),
    LeaveRequest(
      id: 'leave_2',
      employeeId: 'emp_2',
      leaveType: LeaveType.sick,
      startDate: DateTime(2024, 4, 25),
      endDate: DateTime(2024, 4, 25),
      numberOfDays: 1,
      reason: 'Viral fever',
      status: LeaveStatus.pending,
      approvedBy: null,
      approvedDate: null,
      rejectionReason: null,
      createdAt: DateTime(2024, 4, 24),
    ),
    LeaveRequest(
      id: 'leave_3',
      employeeId: 'emp_3',
      leaveType: LeaveType.casual,
      startDate: DateTime(2024, 5, 10),
      endDate: DateTime(2024, 5, 12),
      numberOfDays: 3,
      reason: 'Personal work',
      status: LeaveStatus.rejected,
      approvedBy: 'user_2',
      approvedDate: DateTime(2024, 4, 21),
      rejectionReason: 'Project deadline - critical phase',
      createdAt: DateTime(2024, 4, 19),
    ),
    LeaveRequest(
      id: 'leave_4',
      employeeId: 'emp_1',
      leaveType: LeaveType.casual,
      startDate: DateTime(2024, 6, 15),
      endDate: DateTime(2024, 6, 16),
      numberOfDays: 2,
      reason: 'Wedding attendance',
      status: LeaveStatus.pending,
      approvedBy: null,
      approvedDate: null,
      rejectionReason: null,
      createdAt: DateTime(2024, 4, 23),
    ),
  ];

  // ==================== MOCK PAYROLL ====================
  static final List<Payroll> mockPayroll = [
    Payroll(
      id: 'payroll_1',
      employeeId: 'emp_1',
      month: 3,
      year: 2024,
      baseSalary: 500000,
      bonus: 50000,
      deductions: 75000,
      allowances: 20000,
      netSalary: 495000,
      paymentDate: DateTime(2024, 3, 31),
      payslipUrl: 'https://storage.example.com/payslips/emp_1_mar_2024.pdf',
      transactionId: 'TXN123456789',
      isPaid: true,
      notes: 'Regular salary with annual bonus',
      createdAt: DateTime(2024, 3, 31),
    ),
    Payroll(
      id: 'payroll_2',
      employeeId: 'emp_1',
      month: 4,
      year: 2024,
      baseSalary: 500000,
      bonus: 0,
      deductions: 75000,
      allowances: 20000,
      netSalary: 445000,
      paymentDate: DateTime(2024, 4, 30),
      payslipUrl: 'https://storage.example.com/payslips/emp_1_apr_2024.pdf',
      transactionId: 'TXN123456790',
      isPaid: true,
      notes: 'Regular salary',
      createdAt: DateTime(2024, 4, 30),
    ),
    Payroll(
      id: 'payroll_3',
      employeeId: 'emp_2',
      month: 4,
      year: 2024,
      baseSalary: 520000,
      bonus: 0,
      deductions: 78000,
      allowances: 20000,
      netSalary: 462000,
      paymentDate: DateTime(2024, 4, 30),
      payslipUrl: 'https://storage.example.com/payslips/emp_2_apr_2024.pdf',
      transactionId: 'TXN123456791',
      isPaid: true,
      notes: 'Regular salary',
      createdAt: DateTime(2024, 4, 30),
    ),
    Payroll(
      id: 'payroll_4',
      employeeId: 'emp_3',
      month: 4,
      year: 2024,
      baseSalary: 750000,
      bonus: 0,
      deductions: 112500,
      allowances: 30000,
      netSalary: 667500,
      paymentDate: DateTime(2024, 4, 30),
      payslipUrl: null, // Not yet generated
      transactionId: null,
      isPaid: false,
      notes: 'Payment pending',
      createdAt: DateTime(2024, 4, 30),
    ),
  ];

  // ==================== MOCK PERFORMANCE REVIEWS ====================
  static final List<PerformanceReview> mockPerformanceReviews = [
    PerformanceReview(
      id: 'review_1',
      employeeId: 'emp_1',
      reviewedBy: 'user_2',
      reviewYear: 2024,
      reviewQuarter: 1,
      overallRating: 4.0,
      performanceScore: 78.5,
      strengths: 'Good coding skills, collaborative approach',
      areasForImprovement: 'Time management, documentation',
      comments: 'Solid performer, shows potential for growth',
      status: ReviewStatus.completed,
      reviewDate: DateTime(2024, 4, 10),
      nextReviewDate: DateTime(2024, 7, 10),
      createdAt: DateTime(2024, 4, 10),
    ),
    PerformanceReview(
      id: 'review_2',
      employeeId: 'emp_2',
      reviewedBy: 'user_2',
      reviewYear: 2024,
      reviewQuarter: 1,
      overallRating: 4.5,
      performanceScore: 85.0,
      strengths: 'Excellent problem-solving, quick learner',
      areasForImprovement: 'Communication skills',
      comments: 'Outstanding performer, exceeds expectations',
      status: ReviewStatus.completed,
      reviewDate: DateTime(2024, 4, 12),
      nextReviewDate: DateTime(2024, 7, 12),
      createdAt: DateTime(2024, 4, 12),
    ),
    PerformanceReview(
      id: 'review_3',
      employeeId: 'emp_3',
      reviewedBy: 'user_2',
      reviewYear: 2024,
      reviewQuarter: 1,
      overallRating: 3.5,
      performanceScore: 70.0,
      strengths: 'Leadership qualities, mentoring skills',
      areasForImprovement: 'Project delivery, cost optimization',
      comments: 'Meets expectations, room for improvement',
      status: ReviewStatus.inProgress,
      reviewDate: DateTime(2024, 4, 15),
      nextReviewDate: DateTime(2024, 7, 15),
      createdAt: DateTime(2024, 4, 15),
    ),
  ];

  // ==================== MOCK NOTIFICATIONS ====================
  static final List<Notification> mockNotifications = [
    Notification(
      id: 'notif_1',
      userId: 'user_3',
      type: NotificationType.leaveApproved,
      title: 'Leave Request Approved',
      message: 'Your leave request for May 1-5 has been approved.',
      relatedId: 'leave_1',
      relatedType: 'LeaveRequest',
      data: {'leaveType': 'annual', 'days': 5},
      isRead: true,
      createdAt: DateTime(2024, 4, 20),
      readAt: DateTime(2024, 4, 20, 10, 30),
    ),
    Notification(
      id: 'notif_2',
      userId: 'user_4',
      type: NotificationType.attendanceReminder,
      title: 'Attendance Reminder',
      message: 'Please mark your attendance for today.',
      relatedId: 'emp_2',
      relatedType: 'Employee',
      data: {'date': '2024-04-24'},
      isRead: false,
      createdAt: DateTime(2024, 4, 24, 9, 0),
    ),
    Notification(
      id: 'notif_3',
      userId: 'user_3',
      type: NotificationType.payslipReady,
      title: 'Payslip Ready for Download',
      message: 'Your April 2024 payslip is now available for download.',
      relatedId: 'payroll_2',
      relatedType: 'Payroll',
      data: {'month': 4, 'year': 2024},
      isRead: true,
      createdAt: DateTime(2024, 4, 30),
      readAt: DateTime(2024, 5, 1, 8, 15),
    ),
    Notification(
      id: 'notif_4',
      userId: 'user_4',
      type: NotificationType.performanceReview,
      title: 'Q1 Performance Review Completed',
      message: 'Your Q1 2024 performance review has been completed.',
      relatedId: 'review_2',
      relatedType: 'PerformanceReview',
      data: {'quarter': 'Q1', 'year': 2024},
      isRead: false,
      createdAt: DateTime(2024, 4, 12),
    ),
    Notification(
      id: 'notif_5',
      userId: 'user_1',
      type: NotificationType.announcement,
      title: 'New Holiday Policy',
      message: 'The updated holiday policy for 2024 is now available in the HR portal.',
      relatedId: null,
      relatedType: null,
      data: {},
      isRead: true,
      createdAt: DateTime(2024, 4, 15),
      readAt: DateTime(2024, 4, 15, 14, 0),
    ),
  ];

  // ==================== STATIC METHODS ====================

  /// Get all mock data
  static Map<String, dynamic> getAllMockData() {
    return {
      'users': mockUsers,
      'employees': mockEmployees,
      'attendance': mockAttendance,
      'leaveRequests': mockLeaveRequests,
      'payroll': mockPayroll,
      'performanceReviews': mockPerformanceReviews,
      'notifications': mockNotifications,
    };
  }

  /// Get mock user by role
  static List<User> getMockUsersByRole(UserRole role) {
    return mockUsers.where((user) => user.role == role).toList();
  }

  /// Get mock attendance for employee
  static List<Attendance> getMockAttendanceByEmployee(String employeeId) {
    return mockAttendance
        .where((att) => att.employeeId == employeeId)
        .toList();
  }

  /// Get mock leave requests for employee
  static List<LeaveRequest> getMockLeaveRequestsByEmployee(String employeeId) {
    return mockLeaveRequests
        .where((leave) => leave.employeeId == employeeId)
        .toList();
  }

  /// Get mock payroll for employee
  static List<Payroll> getMockPayrollByEmployee(String employeeId) {
    return mockPayroll.where((payroll) => payroll.employeeId == employeeId).toList();
  }

  /// Get mock notifications for user
  static List<Notification> getMockNotificationsByUser(String userId) {
    return mockNotifications
        .where((notif) => notif.userId == userId)
        .toList();
  }

  /// Get unread notifications for user
  static List<Notification> getUnreadNotifications(String userId) {
    return mockNotifications
        .where((notif) => notif.userId == userId && !notif.isRead)
        .toList();
  }

  /// Get summary statistics
  static Map<String, dynamic> getMockStatistics() {
    return {
      'totalEmployees': mockEmployees.length,
      'totalUsers': mockUsers.length,
      'attendanceToday': mockAttendance
          .where((att) =>
              att.date.day == DateTime.now().day &&
              att.date.month == DateTime.now().month &&
              att.date.year == DateTime.now().year)
          .length,
      'pendingLeaveRequests': mockLeaveRequests
          .where((leave) => leave.status == LeaveStatus.pending)
          .length,
      'pendingPayrolls': mockPayroll
          .where((payroll) => !payroll.isPaid)
          .length,
    };
  }
}
