import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:pharmacy_app/pharmacists_screen.dart';
import 'auth/login/login_screen.dart';
import 'home_screen.dart';
import 'inventory_screen.dart';
import 'reports_screen.dart';
import 'utils/app_routes.dart';



void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  Widget firstScreen;
  if (FirebaseAuth.instance.currentUser != null) {
    firstScreen = const HomeScreen();
  } else {
    firstScreen = const LoginScreen();
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,

      initialRoute: AppRoutes.loginRouteName,

      routes: {
        AppRoutes.loginRouteName: (context) => const LoginScreen(),
        AppRoutes.homeRouteName: (context) => const HomeScreen(),
        AppRoutes.inventoryRouteName: (context) => const InventoryScreen(),
        AppRoutes.reportsRouteName: (context) => const ReportsScreen(),
        AppRoutes.pharmacistsRouteName: (context) => const PharmacistsScreen(),

      },
    );
  }
}