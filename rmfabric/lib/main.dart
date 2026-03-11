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
import 'repositories/stock_repository.dart';
import 'providers/auth_provider.dart' as app_auth;
import 'providers/product_provider.dart';
import 'providers/sales_provider.dart';
import 'providers/expense_provider.dart';
import 'providers/report_provider.dart';
import 'providers/stock_provider.dart';
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
  final stockRepo = StockRepository(firestoreService);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => app_auth.AuthProvider(authService),
        ),
        Provider<ProductRepository>.value(value: productRepo),
        Provider<SalesRepository>.value(value: salesRepo),
        Provider<ExpenseRepository>.value(value: expenseRepo),
        Provider<ReportRepository>.value(value: reportRepo),
        Provider<StockRepository>.value(value: stockRepo),
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
      builder: (context, child) {
        return Consumer<app_auth.AuthProvider>(
          builder: (context, auth, _) {
            if (auth.status == app_auth.AuthStatus.authenticated &&
                auth.currentUser != null) {
              return MultiProvider(
                key: ValueKey(auth.currentUser!.userId),
                providers: [
                  ChangeNotifierProvider(
                    create: (ctx) =>
                        ProductProvider(ctx.read<ProductRepository>()),
                  ),
                  ChangeNotifierProvider(
                    create: (ctx) => SalesProvider(ctx.read<SalesRepository>()),
                  ),
                  ChangeNotifierProvider(
                    create: (ctx) =>
                        ExpenseProvider(ctx.read<ExpenseRepository>()),
                  ),
                  ChangeNotifierProvider(
                    create: (ctx) =>
                        ReportProvider(ctx.read<ReportRepository>()),
                  ),
                  ChangeNotifierProvider(
                    create: (ctx) => StockProvider(ctx.read<StockRepository>()),
                  ),
                ],
                child: child!,
              );
            }
            return child!;
          },
        );
      },
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

        return user.isAdmin ? const AdminDashboard() : const SellerDashboard();
    }
  }
}
