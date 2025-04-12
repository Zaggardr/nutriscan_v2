import 'package:flutter/material.dart';
import '../models/product.dart';

class ProductDetailsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final Product product = ModalRoute.of(context)!.settings.arguments as Product;

    print('Displaying product: ${product.productName}, Brands: ${product.brands}');

    return Scaffold(
      appBar: AppBar(title: Text('Product Details')),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.green[50]!, Colors.white],
          ),
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.productName ?? 'Unknown Product',
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 8),
                    _buildInfoTile('Brand', product.brands ?? 'N/A'),
                    _buildInfoTile('Ingredients', product.ingredientsText ?? 'N/A'),
                    SizedBox(height: 16),
                    Text('Nutrition (per 100g)', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    _buildNutritionTile('Energy', product.getEnergy(), 'kcal'),
                    _buildNutritionTile('Fat', product.getFat().toString(), 'g'),
                    _buildNutritionTile('Sugar', product.getSugar().toString(), 'g'),
                    _buildNutritionTile('Salt', product.getSalt().toString(), 'g'),
                    SizedBox(height: 16),
                    Container(
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: product.analyze().contains('unhealthy') ? Colors.red[100] : Colors.green[100],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        product.analyze(),
                        style: TextStyle(
                          fontSize: 16,
                          color: product.analyze().contains('unhealthy') ? Colors.red[900] : Colors.green[900],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoTile(String title, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('$title: ', style: TextStyle(fontWeight: FontWeight.bold)),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  Widget _buildNutritionTile(String title, String value, String unit) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text('$title: ', style: TextStyle(fontWeight: FontWeight.bold)),
          Text('$value $unit'),
        ],
      ),
    );
  }
}