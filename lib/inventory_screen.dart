import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'app_drawer.dart';

class InventoryScreen extends StatelessWidget {
  const InventoryScreen({super.key});

  Future<void> _confirmDelete(BuildContext context, String docId, String medicineName) async {
    return showDialog(
      context: context,
      builder: (context) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          title: const Text('تأكيد الحذف'),
          content: Text('هل أنت متأكد من حذف دواء "$medicineName" نهائياً؟'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('إلغاء', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () async {
                await FirebaseFirestore.instance.collection('medicines').doc(docId).delete();
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('تم حذف الدواء بنجاح'), backgroundColor: Colors.red),
                );
              },
              child: const Text('حذف الآن', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  bool _isNearExpiry(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return false;
    try {
      DateTime expiryDate = DateTime.parse(dateStr);
      DateTime now = DateTime.now();
      return expiryDate.difference(now).inDays < 30;
    } catch (e) {
      return false;
    }
  }

  void _showMedicineDialog(BuildContext context, {String? docId, Map? existingData}) {
    final nameController = TextEditingController(text: existingData?['name']);
    final quantityController = TextEditingController(text: existingData?['quantity']?.toString());
    final priceController = TextEditingController(text: existingData?['price']?.toString());
    final dateController = TextEditingController(text: existingData?['expiryDate']);
    final stripsController = TextEditingController(text: existingData?['stripsPerBox']?.toString() ?? '2');
    bool isScheduled = existingData?['isScheduled'] ?? false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => Directionality(
          textDirection: TextDirection.rtl,
          child: AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            title: Text(docId == null ? 'إضافة دواء جديد' : 'تعديل البيانات'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(controller: nameController, decoration: const InputDecoration(labelText: 'اسم الدواء')),
                  TextField(controller: quantityController, decoration: const InputDecoration(labelText: 'الكمية (علب)'), keyboardType: TextInputType.number),
                  TextField(controller: priceController, decoration: const InputDecoration(labelText: 'السعر للعلبة'), keyboardType: TextInputType.number),
                  TextField(controller: stripsController, decoration: const InputDecoration(labelText: 'عدد الأشرطة في العلبة'), keyboardType: TextInputType.number),
                  TextField(controller: dateController, decoration: const InputDecoration(labelText: 'تاريخ الصلاحية (YYYY-MM-DD)')),
                  SwitchListTile(
                    title: const Text("دواء مجدول؟"),
                    value: isScheduled,
                    activeColor: Colors.purple,
                    onChanged: (val) => setState(() => isScheduled = val),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: const Text('إلغاء')),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2563EB)),
                onPressed: () async {
                  final data = {
                    'name': nameController.text,
                    'quantity': int.tryParse(quantityController.text) ?? 0,
                    'price': double.tryParse(priceController.text) ?? 0.0,
                    'expiryDate': dateController.text,
                    'stripsPerBox': int.tryParse(stripsController.text) ?? 2,
                    'isScheduled': isScheduled,
                  };
                  if (docId == null) {
                    await FirebaseFirestore.instance.collection('medicines').add(data);
                  } else {
                    await FirebaseFirestore.instance.collection('medicines').doc(docId).update(data);
                  }
                  Navigator.pop(context);
                },
                child: const Text('حفظ', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      drawer: const AppDrawer(),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Builder(builder: (context) => IconButton(
                      icon: const Icon(Icons.menu, color: Colors.black, size: 28),
                      onPressed: () => Scaffold.of(context).openDrawer()
                  )),
                  const Text(
                    'إدارة المخزون',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
                  ),
                ],
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(right: 20, bottom: 10),
              child: Text(
                'إضافة وتحديث بيانات الأدوية والأسعار',
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Directionality(
                textDirection: TextDirection.rtl,
                child: ElevatedButton.icon(
                  onPressed: () => _showMedicineDialog(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2563EB),
                    minimumSize: const Size(double.infinity, 55),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  ),
                  icon: const Icon(Icons.add_circle_outline, color: Colors.white),
                  label: const Text('إضافة دواء جديد', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    reverse: true,
                    child: SizedBox(
                      width: 900,
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
                            color: const Color(0xFFF8FAFC),
                            child: Row(
                              children: const [
                                Expanded(flex: 1, child: Text('إجراءات', textAlign: TextAlign.center, style: TextStyle(fontSize: 13, color: Colors.grey, fontWeight: FontWeight.bold))),
                                Expanded(flex: 1, child: Text('الحالة', textAlign: TextAlign.center, style: TextStyle(fontSize: 13, color: Colors.grey, fontWeight: FontWeight.bold))),
                                Expanded(flex: 1, child: Text('الصلاحية', textAlign: TextAlign.center, style: TextStyle(fontSize: 13, color: Colors.grey, fontWeight: FontWeight.bold))),
                                Expanded(flex: 1, child: Text('السعر', textAlign: TextAlign.center, style: TextStyle(fontSize: 13, color: Colors.grey, fontWeight: FontWeight.bold))),
                                Expanded(flex: 1, child: Text('أشرطة / علبة', textAlign: TextAlign.center, style: TextStyle(fontSize: 13, color: Colors.grey, fontWeight: FontWeight.bold))),
                                Expanded(flex: 1, child: Text('الكمية (علب)', textAlign: TextAlign.center, style: TextStyle(fontSize: 13, color: Colors.grey, fontWeight: FontWeight.bold))),
                                Expanded(flex: 2, child: Text('الدواء', textAlign: TextAlign.right, style: TextStyle(fontSize: 13, color: Colors.grey, fontWeight: FontWeight.bold))),
                              ],
                            ),
                          ),
                          Expanded(
                            child: StreamBuilder<QuerySnapshot>(
                              stream: FirebaseFirestore.instance.collection('medicines').snapshots(),
                              builder: (context, snapshot) {
                                if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                                return ListView.separated(
                                  itemCount: snapshot.data!.docs.length,
                                  separatorBuilder: (context, index) => const Divider(height: 1),
                                  itemBuilder: (context, index) {
                                    final doc = snapshot.data!.docs[index];
                                    return _buildInventoryRow(context: context, docId: doc.id, data: doc.data() as Map<String, dynamic>);
                                  },
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInventoryRow({required BuildContext context, required String docId, required Map<String, dynamic> data}) {
    bool isScheduled = data['isScheduled'] ?? false;
    int quantity = data['quantity'] ?? 0;
    String expiry = data['expiryDate'] ?? '';
    bool nearExpiry = _isNearExpiry(expiry);
    String medName = data['name'] ?? '';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
      child: Row(
        children: [
          Expanded(
            flex: 1,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GestureDetector(onTap: () => _showMedicineDialog(context, docId: docId, existingData: data), child: const Text('تعديل', style: TextStyle(color: Colors.blue, fontSize: 12, fontWeight: FontWeight.bold))),
                const SizedBox(width: 15),
                GestureDetector(
                  onTap: () => _confirmDelete(context, docId, medName),
                  child: const Text('حذف', style: TextStyle(color: Colors.red, fontSize: 12, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 1,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: isScheduled ? Colors.purple.withOpacity(0.1) : Colors.grey.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(isScheduled ? 'مجدول' : 'عادي', style: TextStyle(fontSize: 11, color: isScheduled ? Colors.purple : Colors.grey, fontWeight: FontWeight.bold)),
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: nearExpiry ? Colors.red.withOpacity(0.1) : Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(expiry, textAlign: TextAlign.center, style: TextStyle(fontSize: 11, color: nearExpiry ? Colors.red : Colors.orange, fontWeight: FontWeight.bold)),
            ),
          ),
          Expanded(flex: 1, child: Text('${data['price'] ?? 0} ج.م', textAlign: TextAlign.center, style: const TextStyle(fontSize: 12, color: Colors.blue, fontWeight: FontWeight.bold))),
          Expanded(flex: 1, child: Text('${data['stripsPerBox'] ?? 2}', textAlign: TextAlign.center, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold))),
          Expanded(
            flex: 1,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: quantity > 5 ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text('$quantity علبة', style: TextStyle(fontSize: 11, color: quantity > 5 ? Colors.green : Colors.red, fontWeight: FontWeight.bold)),
              ),
            ),
          ),
          Expanded(flex: 2, child: Text(medName, textAlign: TextAlign.right, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold))),
        ],
      ),
    );
  }
}