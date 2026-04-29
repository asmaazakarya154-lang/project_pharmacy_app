import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'utils/app_routes.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final User? user = FirebaseAuth.instance.currentUser;
    final String userEmail = user?.email ?? 'admin@gmail.com';
    final String? currentRoute = ModalRoute.of(context)?.settings.name;

    String userName = userEmail.split('@')[0];

    String initials = userName.length >= 2
        ? userName.substring(0, 2).toUpperCase()
        : userName.toUpperCase();

    return Drawer(
      child: Container(
        color: const Color(0xFF0F172A),
        child: Column(
          children: [
            const SizedBox(height: 60),


            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  const Text(
                    'إدارة الصيدلية',
                    style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(width: 12),
                  Image.asset('assets/icons/pill.png', width: 24, height: 24, color: Colors.blue),
                ],
              ),
            ),
            const SizedBox(height: 40),


            _drawerItem(
              context: context,
              icon: Icons.grid_view_rounded,
              title: 'لوحة التحكم',
              isSelected: currentRoute == AppRoutes.homeRouteName,
              routeName: AppRoutes.homeRouteName,
            ),
            _drawerItem(
              context: context,
              title: 'المخزون',
              isSelected: currentRoute == AppRoutes.inventoryRouteName,
              isAsset: true,
              assetPath: 'assets/icons/pill.png',
              routeName: AppRoutes.inventoryRouteName,
            ),
            _drawerItem(
              context: context,
              title: 'التقارير',
              isAsset: true,
              assetPath: 'assets/icons/reports.png',
              isSelected: currentRoute == AppRoutes.reportsRouteName,
              routeName: AppRoutes.reportsRouteName,
            ),
            _drawerItem(
              context: context,
              title: 'إدارة الصيادلة',
              isAsset: true,
              assetPath: 'assets/icons/pharmacists.png',
              isSelected: currentRoute == AppRoutes.pharmacistsRouteName,
              routeName: AppRoutes.pharmacistsRouteName,            ),

            const Spacer(),


            Container(
              margin: const EdgeInsets.symmetric(horizontal: 15),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF1E293B).withOpacity(0.5),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          userName,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Text(
                          userEmail,
                          style: const TextStyle(color: Colors.grey, fontSize: 10),
                          textDirection: TextDirection.ltr,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    width: 45,
                    height: 45,
                    decoration: const BoxDecoration(
                      color: Color(0xFF2563EB),
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      initials,
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 10),


            Padding(
              padding: const EdgeInsets.only(right: 25, bottom: 30, left: 25),
              child: InkWell(
                onTap: () async {
                  await FirebaseAuth.instance.signOut();
                  Navigator.of(context).pushNamedAndRemoveUntil(AppRoutes.loginRouteName, (route) => false);
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    const Text(
                      'خروج',
                      style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(width: 10),
                    Icon(Icons.logout_rounded, color: Colors.grey.withOpacity(0.8), size: 22),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _drawerItem({
    required BuildContext context,
    required String title,
    IconData? icon,
    required bool isSelected,
    bool isAsset = false,
    String? assetPath,
    String? routeName,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 4),
      decoration: BoxDecoration(
        color: isSelected ? const Color(0xFF2563EB) : Colors.transparent,
        borderRadius: BorderRadius.circular(15),
      ),
      child: ListTile(
        onTap: () {
          if (routeName != null) {
            Navigator.pop(context);
            Navigator.pushReplacementNamed(context, routeName);
          }
        },
        trailing: isAsset && assetPath != null
            ? Image.asset(
          assetPath,
          width: 20,
          height: 20,
          color: isSelected ? Colors.white : Colors.white.withOpacity(0.5),
        )
            : Icon(
          icon,
          color: isSelected ? Colors.white : Colors.white.withOpacity(0.5),
          size: 20,
        ),
        title: Text(
          title,
          textAlign: TextAlign.right,
          style: TextStyle(
            color: isSelected ? Colors.white : const Color(0xFF94A3B8),
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}