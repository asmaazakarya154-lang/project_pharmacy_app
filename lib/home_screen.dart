import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'app_drawer.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      drawer: const AppDrawer(),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('medicines').snapshots(),
        builder: (context, medicineSnapshot) {
          if (!medicineSnapshot.hasData) return const Center(child: CircularProgressIndicator());

          final docs = medicineSnapshot.data!.docs;

          final lowStock = docs.where((d) => (d['quantity'] as int) <= 5).toList();
          final nearExpiry = docs.where((d) {
            try {
              final date = DateTime.parse(d['expiryDate']);
              return date.difference(DateTime.now()).inDays <= 30;
            } catch (e) { return false; }
          }).toList();

          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(25, 60, 25, 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Builder(
                        builder: (context) => IconButton(
                          icon: const Icon(Icons.menu, color: Colors.black, size: 28),
                          onPressed: () => Scaffold.of(context).openDrawer(),
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: const [
                          Text(
                            'مرحباً بك مجدداً',
                            style: TextStyle(fontSize: 28, fontWeight: FontWeight.w600, color: Color(
                                0xFF1E293B)),
                          ),
                        Text(
                          'نظرة عامة على حالة الصيدلية اليوم',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w400, color: Color(
                              0xFF64748B)),
                        ),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 40),

                  StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance.collection('sales').snapshots(),
                    builder: (context, salesSnapshot) {
                      double totalSalesValue = 0;
                      if (salesSnapshot.hasData) {
                        for (var doc in salesSnapshot.data!.docs) {
                          totalSalesValue += (doc['totalAmount'] as num).toDouble();
                        }
                      }

                      return _buildStatCard(
                        title: 'إجمالي المبيعات',
                        value: '${totalSalesValue.toStringAsFixed(0)} ج.م',
                        color: const Color(0xFFEFF6FF),
                        icon: Icons.shopping_cart_outlined,
                        textColor: Colors.blue.shade700,
                      );
                    },
                  ),

                  const SizedBox(height: 15),

                  _buildStatCard(
                    title: 'أدوية ناقصة',
                    value: '${lowStock.length}',
                    color: const Color(0xFFFEF2F2),
                    icon: Icons.report_problem_outlined,
                    textColor: Colors.red.shade700,
                  ),
                  const SizedBox(height: 15),
                  _buildStatCard(
                    title: 'قرب انتهاء الصلاحية',
                    value: '${nearExpiry.length}',
                    color: const Color(0xFFFFFBEB),
                    icon: Icons.access_time_rounded,
                    textColor: Colors.orange.shade700,
                  ),

                  const SizedBox(height: 40),

                  _buildSectionHeader('تنبيهات نقص المخزون', Icons.report_problem_outlined, Colors.red),
                  const SizedBox(height: 12),
                  ...lowStock.map((d) => _buildListTile(d['name'], 'باقي ${d['quantity']} علب', const Color(0xFFFEF2F2), Colors.red)),

                  const SizedBox(height: 25),

                  _buildSectionHeader('تنبيهات انتهاء الصلاحية', Icons.access_time_rounded, Colors.orange),
                  const SizedBox(height: 12),
                  ...nearExpiry.map((d) => _buildListTile(d['name'], d['expiryDate'], const Color(0xFFFFFBEB), Colors.orange)),

                  const SizedBox(height: 50),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatCard({required String title, required String value, required Color color, required IconData icon, required Color textColor}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(title, style: TextStyle(color: textColor, fontSize: 13, fontWeight: FontWeight.bold)),
                Text(value, style: TextStyle(color: textColor, fontSize: 18, fontWeight: FontWeight.w900)),
              ],
            ),
          ),
          const SizedBox(width: 20),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: textColor, size: 20),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Text(title, style: TextStyle(fontWeight: FontWeight.w900, color: color, fontSize: 15)),
        const SizedBox(width: 10),
        Icon(icon, color: color, size: 20),
      ],
    );
  }

  Widget _buildListTile(String name, String info, Color bgColor, Color textColor) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        children: [
          Text(info, style: TextStyle(color: textColor, fontWeight: FontWeight.w900, fontSize: 12)),
          const Spacer(),
          Text(name, style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1E293B), fontSize: 14)),
        ],
      ),
    );
  }
}