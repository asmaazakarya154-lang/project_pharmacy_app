import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class SalesDetailsScreen extends StatelessWidget {
  final List sales;

  const SalesDetailsScreen({super.key, required this.sales});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('تفاصيل المبيعات'),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: sales.length,
        itemBuilder: (context, index) {
          var doc = sales[index];

          Timestamp time = doc['date']; // لازم يكون Timestamp في Firebase
          DateTime date = time.toDate();

          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    doc['product_name'],
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),

                  Text(" التاريخ: ${date.day}/${date.month}/${date.year}"),
                  Text(" عدد العلب: ${doc['quantity']}"),
                  Text(" السعر الكلي: ${doc['total_price']} جنيه"),
                  Text(
                    doc['payment_method'] == 'cash'
                        ? " كاش"
                        : " فيزا",
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}