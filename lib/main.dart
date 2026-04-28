import 'package:flutter/material.dart';
import 'auth/login/login_screen.dart';
import 'utils/app_routes.dart';
import 'home_screen.dart';


void main() {
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
        AppRoutes.homeRouteName :(context ) => HomeScreen(),
        AppRoutes.loginRouteName :(context ) => LoginScreen(),

      },
    );
  }
}