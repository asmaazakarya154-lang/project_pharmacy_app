import 'package:flutter/material.dart';

import 'app_drawer.dart';

class PharmacistsScreen extends StatelessWidget {
  const PharmacistsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        drawer: const AppDrawer(),
        appBar: AppBar(
          backgroundColor: Colors.white,
        )
    );
  }
}
