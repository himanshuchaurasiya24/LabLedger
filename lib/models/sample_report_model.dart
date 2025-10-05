import 'dart:convert';
import 'dart:io'; // Import for File support

// ✅ Renamed class to SampleReportModel
class SampleReportModel {
  // --- Properties ---
  final int? id;
  final String category;
  final String diagnosisName;
  final String sampleReportFile;
  final File? sampleReportFileLocal; 

  // --- Constructor ---
  // ✅ Renamed constructor
  const SampleReportModel({
    this.id,
    required this.category,
    required this.diagnosisName,
    required this.sampleReportFile,
    this.sampleReportFileLocal,
  });

  // --- copyWith Method ---
  // ✅ Renamed return type
  SampleReportModel copyWith({
    int? id,
    String? category,
    String? diagnosisName,
    String? sampleReportFile,
    File? sampleReportFileLocal,
  }) {
    // ✅ Renamed class instantiation
    return SampleReportModel(
      id: id ?? this.id,
      category: category ?? this.category,
      diagnosisName: diagnosisName ?? this.diagnosisName,
      sampleReportFile: sampleReportFile ?? this.sampleReportFile,
      sampleReportFileLocal: sampleReportFileLocal ?? this.sampleReportFileLocal,
    );
  }

  // --- JSON Serialization ---
  Map<String, String> toPostMap() {
    return {
      'category': category,
      'diagnosis_name': diagnosisName,
    };
  }
  
  String toJson() => json.encode(toPostMap());

  // --- JSON Deserialization ---
  // ✅ Renamed factory constructor
  factory SampleReportModel.fromJson(Map<String, dynamic> json) {
    // ✅ Renamed class instantiation
    return SampleReportModel(
      id: json['id'],
      category: json['category'] ?? '',
      diagnosisName: json['diagnosis_name'] ?? '',
      sampleReportFile: json['sample_report_file'] ?? '',
    );
  }

  // --- Equality and hashCode ---
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
  
    // ✅ Renamed type check
    return other is SampleReportModel &&
      other.id == id &&
      other.category == category &&
      other.diagnosisName == diagnosisName &&
      other.sampleReportFile == sampleReportFile;
  }

  @override
  int get hashCode {
    return id.hashCode ^
      category.hashCode ^
      diagnosisName.hashCode ^
      sampleReportFile.hashCode;
  }

  // --- toString Method ---
  @override
  String toString() {
    // ✅ Renamed class name in string output
    return 'SampleReportModel(id: $id, category: $category, diagnosisName: $diagnosisName, sampleReportFile: $sampleReportFile)';
  }
}