import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';

import 'core/theme/app_theme.dart';
import 'services/auth_service.dart';
import 'services/firestore_service.dart';
import 'repositories/product_repository.dart';
import 'repositories/sales_repository.dart';
import 'repositories/expense_repository.dart';
import 'repositories/report_repository.dart';
import 'providers/auth_provider.dart' as app_auth;
import 'providers/product_provider.dart';
import 'providers/sales_provider.dart';
import 'providers/expense_provider.dart';
import 'providers/report_provider.dart';
import 'screens/auth/login_screen.dart';
import 'screens/seller/seller_dashboard.dart';
import 'screens/admin/admin_dashboard.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp();
  } catch (e) {
    debugPrint('Firebase init error: $e');
  }

  // Singletons
  final authService = AuthService();
  final firestoreService = FirestoreService();

  // Repositories
  final productRepo = ProductRepository(firestoreService);
  final salesRepo = SalesRepository(firestoreService);
  final expenseRepo = ExpenseRepository(firestoreService);
  final reportRepo = ReportRepository(firestoreService);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => app_auth.AuthProvider(authService),
        ),
        ChangeNotifierProvider(create: (_) => ProductProvider(productRepo)),
        ChangeNotifierProvider(create: (_) => SalesProvider(salesRepo)),
        ChangeNotifierProvider(create: (_) => ExpenseProvider(expenseRepo)),
        ChangeNotifierProvider(create: (_) => ReportProvider(reportRepo)),
      ],
      child: const RmFabricApp(),
    ),
  );
}

class RmFabricApp extends StatelessWidget {
  const RmFabricApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'RmFabric',
      theme: AppTheme.theme,
      debugShowCheckedModeBanner: false,
      home: const AppRouter(),
    );
  }
}

class AppRouter extends StatelessWidget {
  const AppRouter({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<app_auth.AuthProvider>(context);

    switch (auth.status) {
      case app_auth.AuthStatus.unknown:
        return const Scaffold(body: Center(child: CircularProgressIndicator()));

      case app_auth.AuthStatus.unauthenticated:
        return const LoginScreen();

      case app_auth.AuthStatus.authenticated:
        final user = auth.currentUser;
        if (user == null) return const LoginScreen();
        if (user.isAdmin) return const AdminDashboard();
        return const SellerDashboard();
    }
  }
}
