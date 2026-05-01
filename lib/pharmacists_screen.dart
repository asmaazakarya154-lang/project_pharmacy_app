import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'app_drawer.dart';

class PharmacistsScreen extends StatelessWidget {
  const PharmacistsScreen({super.key});

  Future<void> deletePharmacist(BuildContext context, String docId, String name) async {
    return showDialog(
      context: context,
      builder: (context) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          title: const Text('حذف بيانات'),
          content: Text('هل أنت متأكد من حذف الصيدلي "$name"؟'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('إلغاء')),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () async {
                await FirebaseFirestore.instance.collection('pharmacists').doc(docId).delete();
                Navigator.pop(context);
              },
              child: const Text('حذف', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  void showPharmacistDialog(BuildContext context, {String? docId, Map? existingData}) {
    final nameController = TextEditingController(text: existingData?['name']);
    final phoneController = TextEditingController(text: existingData?['phone']);
    final addressController = TextEditingController(text: existingData?['address']);
    final nationalIdController = TextEditingController(text: existingData?['nationalId']);
    String shift = existingData?['shift'] ?? 'صباحي';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => Directionality(
          textDirection: TextDirection.rtl,
          child: AlertDialog(
            title: Text(docId == null ? 'إضافة صيدلي جديد' : 'تعديل البيانات'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(controller: nameController, decoration: const InputDecoration(labelText: 'اسم الصيدلي')),
                  TextField(controller: phoneController, decoration: const InputDecoration(labelText: 'رقم الهاتف'), keyboardType: TextInputType.phone),
                  TextField(controller: addressController, decoration: const InputDecoration(labelText: 'العنوان')),
                  TextField(controller: nationalIdController, decoration: const InputDecoration(labelText: 'الرقم القومي'), keyboardType: TextInputType.number),
                  const SizedBox(height: 15),
                  DropdownButton<String>(
                    value: shift,
                    isExpanded: true,
                    items: ['صباحي', 'مسائي', 'ليلي'].map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                    onChanged: (val) => setState(() => shift = val!),
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
                    'phone': phoneController.text,
                    'address': addressController.text,
                    'nationalId': nationalIdController.text,
                    'shift': shift,
                    'addedAt': FieldValue.serverTimestamp(),
                  };
                  if (docId == null) {
                    await FirebaseFirestore.instance.collection('pharmacists').add(data);
                  } else {
                    await FirebaseFirestore.instance.collection('pharmacists').doc(docId).update(data);
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
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 5),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Builder(builder: (context) => IconButton(
                      icon: const Icon(Icons.menu, color: Colors.black, size: 28),
                      onPressed: () => Scaffold.of(context).openDrawer()
                  )),
                  const Text('إدارة الصيادلة', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(right: 25, bottom: 20),
              child: Text('إضافة وتحديث بيانات الصيادلة', style: TextStyle(color: Colors.grey)),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Directionality(
                textDirection: TextDirection.rtl,
                child: ElevatedButton.icon(
                  onPressed: () => showPharmacistDialog(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2563EB),
                    minimumSize: const Size(double.infinity, 55),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  ),
                  icon: const Icon(Icons.add_circle_outline, color: Colors.white),
                  label: const Text('إضافة صيدلي جديد', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance.collection('pharmacists').snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                  final docs = snapshot.data!.docs;

                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: docs.length,
                    itemBuilder: (context, index) {
                      final data = docs[index].data() as Map<String, dynamic>;
                      final id = docs[index].id;

                      return Container(
                        margin: const EdgeInsets.only(bottom: 15),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: Column(
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      infoRow('الصيدلي:', data['name'], true),
                                      infoRow('رقم الهاتف:', data['phone'], false),
                                      infoRow('العنوان:', data['address'] ?? 'غير محدد', false),
                                      infoRow('الرقم القومي:', data['nationalId'] ?? 'غير مسجل', false),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 15),
                                Container(
                                  width: 80, height: 80,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF1F5F9),
                                    borderRadius: BorderRadius.circular(15),
                                    border: Border.all(color: Colors.blue.shade100),
                                  ),
                                  child: const Icon(Icons.person_outline, size: 50, color: Color(0xFF64748B)),
                                ),
                              ],
                            ),
                            const SizedBox(height: 15),
                            Row(
                              children: [
                                actionBtn('حذف', Colors.red.shade50, Colors.red, () => deletePharmacist(context, id, data['name'])),
                                const SizedBox(width: 10),
                                actionBtn('تعديل', Colors.green.shade50, Colors.green, () => showPharmacistDialog(context, docId: id, existingData: data)),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget infoRow(String label, String value, bool isHeader) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: RichText(
        textDirection: TextDirection.rtl,
        text: TextSpan(
          children: [
            TextSpan(text: '$label  ', style: const TextStyle(color: Color(0xFF2563EB), fontWeight: FontWeight.bold, fontSize: 14)),
            TextSpan(text: value, style: TextStyle(color: isHeader ? Colors.black : Colors.black54, fontSize: 14, fontWeight: isHeader ? FontWeight.bold : FontWeight.normal)),
          ],
        ),
      ),
    );
  }

  Widget actionBtn(String label, Color bg, Color text, VoidCallback tap) {
    return Expanded(
      child: InkWell(
        onTap: tap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(10)),
          child: Text(label, textAlign: TextAlign.center, style: TextStyle(color: text, fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }
}