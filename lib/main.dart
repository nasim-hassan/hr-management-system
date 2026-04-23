import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'config/environment.dart';
import 'config/supabase_config.dart';
import 'core/theme/app_theme.dart';
import 'config/app_routes.dart';
import 'presentation/screens/main_layout.dart';
import 'presentation/screens/employee_list_screen.dart';
import 'presentation/screens/employee_details_screen.dart';
import 'presentation/screens/employee_form_screen.dart';
import 'data/models/employee_model.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Supabase
  await SupabaseConfig.initialize();

  runApp(
    const ProviderScope(
      child: HRManagementApp(),
    ),
  );
}

class HRManagementApp extends ConsumerWidget {
  const HRManagementApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      title: Environment.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.light,
      home: const MainLayout(), // Skip splash, go directly to MainLayout
      onGenerateRoute: (settings) {
        if (settings.name == AppRoutes.employees) {
          return MaterialPageRoute(builder: (_) => const EmployeeListScreen());
        }
        
        if (settings.name != null && settings.name!.startsWith('/employees/')) {
          final parts = settings.name!.split('/');
          if (parts.length == 3) {
            final id = parts[2];
            // View details
            final args = settings.arguments as Employee?;
            if (args != null) {
              return MaterialPageRoute(
                builder: (_) => EmployeeDetailsScreen(employee: args),
              );
            }
          } else if (parts.length == 4 && parts[3] == 'edit') {
            final id = parts[2];
            // Edit or Add
            if (id == 'new') {
              return MaterialPageRoute(
                builder: (_) => const EmployeeFormScreen(),
              );
            } else {
              final args = settings.arguments as Employee?;
              return MaterialPageRoute(
                builder: (_) => EmployeeFormScreen(employee: args),
              );
            }
          }
        }
        
        return null;
      },
    );
  }
}

/// Splash Screen - Initial entry point (Optional - can be enabled later)
/// To use splash screen, replace `AdminDashboardScreen()` with `SplashScreen()` in HRManagementApp.home
class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToNextScreen();
  }

  Future<void> _navigateToNextScreen() async {
    // Simulate loading delay (set to 0 to skip)
    await Future.delayed(const Duration(seconds: 0)); // Changed from 2 to 0

    if (!mounted) return;

    // Check if user is authenticated
    final isAuthenticated = SupabaseConfig.isAuthenticated;

    if (isAuthenticated) {
      // Navigate to dashboard based on role
      if (mounted) {
        Navigator.of(context).pushReplacementNamed(AppRoutes.adminDashboard);
      }
    } else {
      // Navigate to login
      if (mounted) {
        Navigator.of(context).pushReplacementNamed(AppRoutes.login);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primaryColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // App Logo
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: const Center(
                child: Text(
                  'HR',
                  style: TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryColor,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            // App Name
            const Text(
              Environment.appName,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            // Version
            const Text(
              'Version ${Environment.appVersion}',
              style: TextStyle(
                fontSize: 12,
                color: Colors.white70,
              ),
            ),
            const SizedBox(height: 48),
            // Loading Indicator
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}
