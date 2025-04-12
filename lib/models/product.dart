class Product {
  final String? productName;
  final String? brands;
  final String? ingredientsText;
  final Map<String, dynamic>? nutriments;

  Product({
    this.productName,
    this.brands,
    this.ingredientsText,
    this.nutriments,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      productName: json['product_name'] as String?,
      brands: json['brands'] as String?,
      ingredientsText: json['ingredients_text'] as String?,
      nutriments: json['nutriments'] as Map<String, dynamic>?,
    );
  }

  bool get hasData => productName != null || brands != null || ingredientsText != null || nutriments != null;

  double getSugar() => double.tryParse(nutriments?['sugars_100g']?.toString() ?? '0') ?? 0;
  double getFat() => double.tryParse(nutriments?['fat_100g']?.toString() ?? '0') ?? 0;
  double getSalt() => double.tryParse(nutriments?['salt_100g']?.toString() ?? '0') ?? 0;
  String getEnergy() => nutriments?['energy-kcal_100g']?.toString() ?? 'N/A';

  String analyze() {
    final sugar = getSugar();
    final fat = getFat();
    final salt = getSalt();

    if (sugar > 22.5 || fat > 17.5 || salt > 1.5) {
      return 'Potentially unhealthy: High in ${sugar > 22.5 ? 'sugar' : ''} ${fat > 17.5 ? 'fat' : ''} ${salt > 1.5 ? 'salt' : ''}';
    }
    return 'Seems relatively healthy';
  }
}