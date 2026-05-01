import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'app_drawer.dart';
import 'detailed_screen.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  List sales = [];
  Map<String, int> topProducts = {};
  double cash = 0;
  double visa = 0;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    var snapshot =
    await FirebaseFirestore.instance.collection('sales').get();

    sales = snapshot.docs;

    calculateTopProducts();
    calculatePayments();

    setState(() {});
  }

  void calculateTopProducts() {
    Map<String, int> temp = {};

    for (var doc in sales) {
      String name = doc['product_name'];
      int qty = doc['quantity'];

      temp[name] = (temp[name] ?? 0) + qty;
    }

    topProducts = temp;
  }

  void calculatePayments() {
    cash = 0;
    visa = 0;

    for (var doc in sales) {
      if (doc['payment_method'] == 'cash') {
        cash += doc['total_price'];
      } else {
        visa += doc['total_price'];
      }
    }
  }


  Future<void> generatePDF() async {
    final fontData = await rootBundle.load("assets/fonts/Amiri-Regular.ttf");
    final ttf = pw.Font.ttf(fontData);

    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(20),
        theme: pw.ThemeData.withFont(base: ttf),

        build: (context) => [
          pw.Directionality(
            textDirection: pw.TextDirection.rtl,
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [

                pw.Center(
                  child: pw.Text(
                    'Daily pharmacy report',
                    style: pw.TextStyle(
                      fontSize: 22,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                ),

                pw.SizedBox(height: 20),

                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    _pdfBox('كاش', '$cash pound '),
                    _pdfBox('فيزا', '$visa pound '),
                    _pdfBox('الإجمالي', '${cash + visa} pound '),
                  ],
                ),

                pw.SizedBox(height: 20),


                pw.Text('Best Sellerً',
                  style: pw.TextStyle(
                    fontSize: 16,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),

                pw.SizedBox(height: 10),

                pw.Table(
                  border: pw.TableBorder.all(color: PdfColors.grey300),
                  columnWidths: {
                    0: const pw.FlexColumnWidth(3),
                    1: const pw.FlexColumnWidth(1),
                  },
                  children: [
                    pw.TableRow(
                      decoration: const pw.BoxDecoration(
                        color: PdfColors.grey200,
                      ),
                      children: [
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8),
                          child: pw.Text('drug',
                              textAlign: pw.TextAlign.right,
                              style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8),
                          child: pw.Text('Quantity',
                              textAlign: pw.TextAlign.center,
                              style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                        ),
                      ],
                    ),

                    ...topProducts.entries.map((e) => pw.TableRow(
                      children: [
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8),
                          child: pw.Text(e.key,
                              textAlign: pw.TextAlign.right),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8),
                          child: pw.Text(e.value.toString(),
                              textAlign: pw.TextAlign.center),
                        ),
                      ],
                    )),
                  ],
                ),

                pw.SizedBox(height: 25),

                pw.Text(
                  'Sales details',
                  style: pw.TextStyle(
                    fontSize: 16,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),

                pw.SizedBox(height: 10),

                ...sales.map((doc) {
                  final date = (doc['date'] as Timestamp).toDate();

                  return pw.Container(
                    margin: const pw.EdgeInsets.only(bottom: 10),
                    padding: const pw.EdgeInsets.all(10),
                    decoration: pw.BoxDecoration(
                      border: pw.Border.all(color: PdfColors.grey300),
                      borderRadius: pw.BorderRadius.circular(8),
                    ),
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          doc['product_name'],
                          style: pw.TextStyle(
                            fontWeight: pw.FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),

                        pw.SizedBox(height: 5),

                        pw.Text('الكمية: ${doc['quantity']}'),
                        pw.Text('السعر: ${doc['total_price']} جنيه'),
                        pw.Text(
                          'الدفع: ${doc['payment_method'] == "cash" ? "كاش" : "فيزا"}',
                        ),
                        pw.Text(
                          'التاريخ: ${date.day}/${date.month}/${date.year}',
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ],
            ),
          ),
        ],
      ),
    );

    await Printing.layoutPdf(
      onLayout: (format) async => pdf.save(),
    );
  }

  /// 🔹 box
  pw.Widget _pdfBox(String title, String value) {
    return pw.Container(
      width: 110,
      padding: const pw.EdgeInsets.all(10),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey300),
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Column(
        children: [
          pw.Text(
            title,
            style: pw.TextStyle(fontSize: 12),
          ),
          pw.SizedBox(height: 5),
          pw.Text(
            value,
            style: pw.TextStyle(
              fontSize: 14,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    double total = cash + visa;

    var sorted = topProducts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      drawer: const AppDrawer(),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [

              /// 🔹 HEADER
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Builder(
                      builder: (context) => IconButton(
                        icon: const Icon(Icons.menu, size: 28),
                        onPressed: () => Scaffold.of(context).openDrawer(),
                      ),
                    ),
                    const Text(
                      'مركز التقارير اليومية',
                      style:
                      TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),

              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 25),
                child: Text(
                  'نظرة عامة على حالة الصيدلية اليومية',
                  textAlign: TextAlign.right,
                  style: TextStyle(color: Colors.grey),
                ),
              ),

              const SizedBox(height: 20),

              /// 🔹 BUTTONS
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                Expanded(
                child: GestureDetector(
                onTap: () {
              Navigator.push(
              context,
              MaterialPageRoute(
              builder: (_) => SalesDetailsScreen(sales: sales),
              ),
              );
              },
                child: topBtn(
                  'عرض تفصيلي',
                  Colors.white,
                  Colors.black,
                  true,
                ),
              ),
      ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: GestureDetector(
                        onTap: generatePDF,
                        child: topBtn('تحميل تقرير اليوم (PDF)',
                            const Color(0xFF0F172A), Colors.white, false),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 25),

              /// 🔹 TOP SELLING
              sectionCard(
                'الأكثر مبيعاً اليوم',
                Column(
                  children:
                  sorted.take(3).toList().asMap().entries.map((entry) {
                    int index = entry.key;
                    var e = entry.value;

                    return sellingRow(
                      e.key,
                      sorted.isEmpty ? 0 : e.value / sorted.first.value,
                      '${e.value} وحدة',
                      '#${index + 1}',
                    );
                  }).toList(),
                ),
              ),

              /// 🔹 PAYMENTS
              sectionCard(
                'ملخص طرق الدفع',
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    paymentCircle(
                        total == 0
                            ? '0%'
                            : '${((visa / total) * 100).toInt()}%',
                        'فيزا',
                        Colors.green),
                    paymentCircle(
                        total == 0
                            ? '0%'
                            : '${((cash / total) * 100).toInt()}%',
                        'كاش',
                        Colors.blue),
                  ],
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  /// 🔹 BUTTON
  Widget topBtn(String text, Color bg, Color color, bool border) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(14),
        border: border ? Border.all(color: Colors.grey.shade300) : null,
      ),
      child: Center(
        child: Text(text,
            style: TextStyle(
                color: color,
                fontWeight: FontWeight.w600,
                fontSize: 13)),
      ),
    );
  }

  /// 🔹 CARD
  Widget sectionCard(String title, Widget child) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 15,
              offset: const Offset(0, 5))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(title,
              style:
              const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 20),
          child,
        ],
      ),
    );
  }

  /// 🔹 ROW
  Widget sellingRow(String name, double val, String count, String rank) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(rank,
                    style: const TextStyle(
                        color: Colors.blue, fontWeight: FontWeight.bold)),
              ),
              Text(name,
                  style: const TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Text(count,
                  style:
                  const TextStyle(fontSize: 12, color: Colors.grey)),
              const SizedBox(width: 10),
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: val > 1 ? 1 : val,
                    minHeight: 7,
                    backgroundColor: Colors.grey.shade200,
                    color: Colors.blue,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// 🔹 CIRCLE
  Widget paymentCircle(String percent, String label, Color color) {
    double value =
        double.tryParse(percent.replaceAll('%', '')) ?? 0;

    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              width: 70,
              height: 70,
              child: CircularProgressIndicator(
                value: value / 100,
                strokeWidth: 7,
                color: color,
                backgroundColor: color.withOpacity(0.1),
              ),
            ),
            Text(percent,
                style: const TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        const SizedBox(height: 10),
        Text(label, style: const TextStyle(color: Colors.grey)),
      ],
    );
  }
}