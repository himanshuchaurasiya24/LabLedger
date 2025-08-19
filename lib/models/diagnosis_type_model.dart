class DiagnosisType {
  final int? id;            // nullable, because not required when creating
  final String name;
  final String category;
  final int price;

  DiagnosisType({
    this.id,                // optional
    required this.name,
    required this.category,
    required this.price,
  });

  factory DiagnosisType.fromJson(Map<String, dynamic> json) {
    return DiagnosisType(
      id: json['id'],       // will be null when posting
      name: json['name'],
      category: json['category'],
      price: json['price'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "name": name,
      "category": category,
      "price": price,
      // no id, no center_detail here when adding
    };
  }
}
