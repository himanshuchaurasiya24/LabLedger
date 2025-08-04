class DiagnosisType {
  final int id;
  final String name;
  final String category;
  final int price;

  DiagnosisType({
    required this.id,
    required this.name,
    required this.category,
    required this.price,
  });

  factory DiagnosisType.fromJson(Map<String, dynamic> json) {
    return DiagnosisType(
      id: json['id'],
      name: json['name'],
      category: json['category'],
      price: json['price'],
    );
  }
}
