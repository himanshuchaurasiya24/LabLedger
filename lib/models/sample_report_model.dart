import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:labledger/models/diagnosis_type_model.dart';

class SampleReportModel {
  final int? id;
  final String diagnosisName;
  final DiagnosisType? diagnosisTypeOutput; // full object (from API)
  final int? diagnosisType;                 // only id for posting/updating
  final File? sampleReportFileLocal;        // for posting
  final String? sampleReportFileUrl;        // for fetching

  SampleReportModel({
    this.id,
    required this.diagnosisName,
    this.diagnosisTypeOutput,
    this.diagnosisType,
    this.sampleReportFileLocal,
    this.sampleReportFileUrl,
  });

  // From JSON (fetch API data)
  factory SampleReportModel.fromJson(Map<String, dynamic> json) {
    return SampleReportModel(
      id: json['id'],
      diagnosisName: json['diagnosis_name'],
      diagnosisTypeOutput: json['diagnosis_type_output'] != null
          ? DiagnosisType.fromJson(json['diagnosis_type_output'])
          : null,
      diagnosisType: json['diagnosis_type_output'] != null
          ? json['diagnosis_type_output']['id']
          : null,
      sampleReportFileUrl: json['sample_report_file'],
    );
  }

  // Fields for posting/updating
  Map<String, String> toPostMap() {
    return {
      "diagnosis_name": diagnosisName,
      "diagnosis_type": (diagnosisType ?? diagnosisTypeOutput?.id)?.toString() ?? "",
    };
  }

  // Multipart request for posting/updating with file
  Future<http.MultipartRequest> toMultipartRequest(Uri uri, String token) async {
    var request = http.MultipartRequest("POST", uri);

    // add text fields
    request.fields.addAll(toPostMap());

    // add file if present
    if (sampleReportFileLocal != null) {
      request.files.add(await http.MultipartFile.fromPath(
        "sample_report_file",
        sampleReportFileLocal!.path,
      ));
    }

    // auth header
    request.headers['Authorization'] = 'Bearer $token';

    return request;
  }
}
