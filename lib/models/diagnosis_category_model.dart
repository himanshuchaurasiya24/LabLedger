class DiagnosisCategory {
  final int id;
  final String name;
  final String? description;
  final bool isFranchiseLab;
  final bool isActive;

  DiagnosisCategory({
    required this.id,
    required this.name,
    this.description,
    required this.isFranchiseLab,
    required this.isActive,
  });

  factory DiagnosisCategory.fromJson(Map<String, dynamic> json) {
    return DiagnosisCategory(
      id: json['id'] as int,
      name: json['name'] as String,
      description: json['description'] as String?,
      isFranchiseLab: json['is_franchise_lab'] as bool? ?? false,
      isActive: json['is_active'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'is_franchise_lab': isFranchiseLab,
      'is_active': isActive,
    };
  }
}
