import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:labledger/constants/constants.dart';
import 'package:labledger/models/incentive_model.dart';
import 'package:labledger/providers/authentication_provider.dart';
import 'package:labledger/screens/incentives/pdf_layouts/pdf_type1.dart';
import 'package:labledger/screens/incentives/pdf_layouts/pdf_type2.dart';
import 'package:labledger/screens/incentives/pdf_layouts/pdf_type3.dart';
import 'package:labledger/screens/incentives/pdf_layouts/pdf_type4.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

Future<Uint8List> createPDF({
  required List<DoctorReport> reports,
  required Map<String, bool> selectedFields,
  required WidgetRef ref,
  required int pdfIndex,
}) async {
  final pdf = pw.Document();

  final liteFont = await rootBundle.load("assets/fonts/Ubuntu-Regular.ttf");
  final ttf = pw.Font.ttf(liteFont);

  final boldFont = await rootBundle.load("assets/fonts/Ubuntu-Bold.ttf");
  final boldTTF = pw.Font.ttf(boldFont);
  final authResponse = await ref.read(currentUserProvider.future);
  final centerDetail = authResponse.centerDetail;

  pdf.addPage(
    pw.MultiPage(
      pageFormat: PdfPageFormat.a4.portrait,
      margin: pw.EdgeInsets.all(defaultPadding / 2),

      build: (pw.Context context) {
        return reports.map((doctorReport) {
          List pdfLayouts = [
            buildBillsTableType1(
              doctorReport,
              selectedFields,
              ref,
              ttf,
              boldTTF,
              centerDetail,
            ),
            buildBillsTableType2(
              doctorReport,
              selectedFields,
              ref,
              ttf,
              boldTTF,
              centerDetail,
            ),
            buildBillsTableType3(
              doctorReport,
              selectedFields,
              ref,
              ttf,
              boldTTF,
              centerDetail,
            ),
            buildBillsTableType4(
              doctorReport,
              selectedFields,
              ref,
              ttf,
              boldTTF,
              centerDetail,
            ),
          ];
          return pw.Column(
            mainAxisAlignment: pw.MainAxisAlignment.start,
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [pdfLayouts[pdfIndex], pw.SizedBox(height: 5)],
          );
        }).toList();
      },
    ),
  );

  return pdf.save();
}
