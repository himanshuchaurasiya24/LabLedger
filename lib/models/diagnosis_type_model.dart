class DiagnosisType {
  final int? id;
  final String name;
  final int category; // Changed to int - stores category ID
  final String? categoryName; // For display purposes
  final int price;

  DiagnosisType({
    this.id,
    required this.name,
    required this.category,
    this.categoryName,
    required this.price,
  });

  factory DiagnosisType.fromJson(Map<String, dynamic> json) {
    return DiagnosisType(
      id: json['id'],
      name: json['name'],
      category: json['category'], // Backend sends category ID
      categoryName:
          json['category_name'], // Backend sends category name for display
      price: json['price'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'name': name,
      'category': category, // Send category ID to backend
      'price': price,
    };
    if (id != null) {
      data['id'] = id as dynamic; // Cast to dynamic to avoid type issue
    }
    return data;
  }
}
