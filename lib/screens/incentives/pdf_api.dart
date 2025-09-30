import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:labledger/constants/constants.dart';
import 'package:labledger/models/incentive_model.dart';
import 'package:labledger/providers/authentication_provider.dart';
import 'package:labledger/screens/incentives/pdf_layouts/pdf_type3.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

Future<Uint8List> createPDF({
  required List<DoctorReport> reports,
  required Map<String, bool> selectedFields,
  required WidgetRef ref,
}) async {
  final pdf = pw.Document();

  // Load a font that supports the Rupee symbol
  final liteFont = await rootBundle.load(
    "assets/fonts/GoogleSansDisplay-Regular.ttf",
  );
  final ttf = pw.Font.ttf(liteFont);

  final boldFont = await rootBundle.load(
    "assets/fonts/GoogleSansDisplay-Bold.ttf",
  );
  final boldTTF = pw.Font.ttf(boldFont);
  // Get center details
  final authResponse = await ref.read(currentUserProvider.future);
  final centerDetail = authResponse.centerDetail;
  pdf.addPage(
    pw.MultiPage(
      pageFormat: PdfPageFormat.a4.portrait,
      margin: pw.EdgeInsets.all(defaultPadding / 2),

      build: (pw.Context context) {
        return reports.map((doctorReport) {
          return pw.Column(
            mainAxisAlignment: pw.MainAxisAlignment.start,
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              buildBillsTableType3(
                doctorReport,
                selectedFields,
                ref,
                ttf,
                boldTTF,
                centerDetail,
              ),
              pw.SizedBox(height: 5),
            ],
          );
        }).toList();
      },
    ),
  );

  return pdf.save();
}
