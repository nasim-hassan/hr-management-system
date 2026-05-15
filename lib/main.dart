import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'config/supabase_config.dart';
import 'core/theme/app_theme.dart';
import 'config/app_routes.dart';
import 'presentation/screens/main_layout.dart';
import 'presentation/screens/splash_screen.dart';
import 'presentation/screens/login_screen.dart';
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
      title: 'HR Management System',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.light,
      home: const SplashScreen(),
      routes: {
        '/login': (context) => const LoginScreen(),
        '/home': (context) => const MainLayout(),
      },
      onGenerateRoute: (settings) {
        if (settings.name == AppRoutes.employees) {
          return MaterialPageRoute(builder: (_) => const EmployeeListScreen());
        }
        
        if (settings.name != null && settings.name!.startsWith('/employees/')) {
          final parts = settings.name!.split('/');
          if (parts.length == 3) {
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
