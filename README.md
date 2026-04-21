# HR Management System

A comprehensive mobile HR Management System built with **Flutter** and **Supabase**.

## Overview

The HR Management System is a cross-platform mobile application designed to streamline human resource operations for organizations. It provides a centralized digital platform for managing employee information, attendance tracking, leave requests, payroll oversight, and performance monitoring.

## Features

### Core Features
- 🔐 **Secure Authentication** - Login with email/password via Supabase Auth
- 👥 **Role-Based Access Control** - HR Admin, Manager, Employee roles
- 📱 **Employee Profile Management** - View and manage employee information
- ⏰ **Attendance Tracking** - Daily check-in/check-out functionality
- 📋 **Leave Management** - Request and approve leave requests
- 💰 **Payroll Overview** - View salary information and download payslips (PDF)
- 📊 **Reports & Analytics** - Generate attendance and payroll reports
- 🔔 **Notifications** - Real-time push notifications
- 🎯 **Performance Monitoring** - Track employee performance metrics
- 📴 **Offline Support** - View cached data offline

## Project Structure

```
lib/
├── config/                 # App configuration
│   ├── app_routes.dart
│   └── environment.dart
├── core/                   # Core utilities and constants
│   ├── constants/
│   ├── enums/
│   ├── extensions/
│   ├── utils/
│   └── theme/
├── data/                   # Data layer (repositories, models)
│   ├── datasources/
│   │   ├── remote/         # API calls
│   │   └── local/          # Local storage
│   ├── models/
│   └── repositories/
├── domain/                 # Business logic (entities, use cases)
│   ├── entities/
│   ├── repositories/
│   └── usecases/
├── features/               # Feature modules
│   ├── auth/               # Authentication
│   ├── dashboard/          # Role-based dashboards
│   ├── employee/           # Employee management
│   ├── attendance/         # Attendance tracking
│   ├── leave/              # Leave requests
│   ├── payroll/            # Payroll & slips
│   ├── reports/            # Reports & analytics
│   ├── notifications/      # Notification handling
│   └── profile/            # User profile
└── main.dart               # Application entry point
```

## Tech Stack

- **Framework**: Flutter
- **Language**: Dart 3.0+
- **Backend**: Supabase (PostgreSQL)
- **Authentication**: Supabase Auth
- **State Management**: Provider/Riverpod
- **Local Storage**: Hive, SharedPreferences
- **Notifications**: Firebase Cloud Messaging
- **API Communication**: Supabase Client, Dio
- **PDF Generation**: PDF package
- **Target OS**: Android 10+

## Setup Instructions

### Prerequisites
- Flutter SDK 3.0+
- Dart SDK
- Android Studio or VS Code
- A Supabase account

### 1. Clone and Install Dependencies

```bash
git clone https://github.com/yourusername/hr-management-system.git
cd hr-management-system
flutter pub get
```

### 2. Configure Supabase

Create `lib/config/environment.dart`:

```dart
class Environment {
  static const String supabaseUrl = 'your-supabase-url';
  static const String supabaseAnonKey = 'your-anon-key';
}
```

### 3. Run the App

```bash
flutter run
```

## Development Workflow

### File Structure Conventions

- **Models** (`data/models/`) - JSON serializable data classes
- **Repositories** (`data/repositories/`) - Data access layer
- **Use Cases** (`domain/usecases/`) - Business logic
- **Providers** (`features/*/presentation/providers/`) - State management
- **UI** (`features/*/presentation/pages/`, `widgets/`) - UI components

### Adding New Features

1. Create feature folder in `features/`
2. Add data layer (models, repositories)
3. Add domain layer (entities, use cases)
4. Add presentation layer (pages, widgets, providers)

## API Documentation

### Authentication
- Login: POST `/auth/login`
- Register: POST `/auth/register`
- Logout: POST `/auth/logout`
- Refresh Token: POST `/auth/refresh`

### Attendance
- Check-in: POST `/attendance/checkin`
- Check-out: POST `/attendance/checkout`
- Get History: GET `/attendance/history`

### Leave Management
- Submit Request: POST `/leave/request`
- Get Requests: GET `/leave/requests`
- Approve: PUT `/leave/{id}/approve`
- Reject: PUT `/leave/{id}/reject`

### Payroll
- Get Slips: GET `/payroll/slips`
- Get Salary: GET `/payroll/salary`
- Download Payslip: GET `/payroll/slip/{id}/pdf`

## Testing

```bash
# Run unit tests
flutter test

# Run widget tests
flutter test --tags widget

# Run integration tests
flutter test integration_test/
```

## Deployment

### Android Build

```bash
flutter build apk --release
```

### Requirements Met
✅ Secure authentication with Supabase ✅ Role-based access control ✅ Employee profile management ✅ Attendance tracking ✅ Leave request and approval ✅ Payroll overview ✅ Notifications ✅ Report generation ✅ Offline support (limited)

## Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit changes (`git commit -m 'Add amazing feature'`)
4. Push to branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License - see LICENSE file for details.

## Support

For support, email hr-support@company.com or open an issue on GitHub.

---

**Status**: 🚀 In Development
**Last Updated**: April 2026
