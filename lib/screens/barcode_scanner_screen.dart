import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../models/product.dart';

class BarcodeScannerScreen extends StatefulWidget {
  @override
  _BarcodeScannerScreenState createState() => _BarcodeScannerScreenState();
}

class _BarcodeScannerScreenState extends State<BarcodeScannerScreen> {
  final TextEditingController _barcodeController = TextEditingController();
  bool _isLoading = false;
  bool _isScanning = false;
  MobileScannerController _scannerController = MobileScannerController();
  int _currentIndex = 0; // For bottom navigation

  // Bottom navigation items
  final List<BottomNavigationBarItem> _bottomNavItems = [
    BottomNavigationBarItem(
      icon: Icon(Icons.search),
      label: 'Scan',
      backgroundColor: Colors.black,
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.favorite_border),
      label: 'History',
      backgroundColor: Colors.black,
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.person_outline),
      label: 'Profile',
      backgroundColor: Colors.black,
    ),
  ];

  Future<void> _startBarcodeScan() async {
    setState(() {
      _isScanning = true;
      _currentIndex = 0; // Ensure scan view is active
    });
  }

  Future<void> _fetchProductInfo(String barcode) async {
    setState(() => _isLoading = true);
    _isScanning = false;

    try {
      print('Fetching product for barcode: $barcode');
      final url = Uri.parse(
        'https://world.openfoodfacts.org/api/v0/product/$barcode.json',
      );
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print(
          'API Response: ${data['product']?['product_name']} (Barcode: $barcode)',
        );

        if (data['status'] == 1) {
          final product = Product.fromJson(data['product']);
          print('Product Name from API: ${product.productName}');
          Navigator.pushNamed(context, '/product', arguments: product);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Product not found for barcode: $barcode')),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'API request failed with status: ${response.statusCode}',
            ),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error fetching data: $e')));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _barcodeController.dispose();
    _scannerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:
          _isScanning
              ? null
              : AppBar(
                title: Text('Nutrition Scanner'),
                backgroundColor: Colors.transparent,
                elevation: 0,
                actions: [
                  IconButton(
                    icon: Icon(Icons.logout),
                    onPressed: () {
                      Navigator.pushReplacementNamed(context, '/login');
                    },
                  ),
                ],
              ),
      extendBody: true, // Important for bottom bar styling
      body: _buildCurrentScreen(),
      bottomNavigationBar: _buildSnapchatBottomBar(),
    );
  }

  Widget _buildCurrentScreen() {
    switch (_currentIndex) {
      case 0:
        return _isScanning ? _buildScannerView() : _buildInputView();
      case 1:
        return Center(child: Text('History Screen')); // Placeholder
      case 2:
        return Center(child: Text('Profile Screen')); // Placeholder
      default:
        return _buildInputView();
    }
  }

  Widget _buildSnapchatBottomBar() {
    return Container(
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 94, 94, 94),
        borderRadius: BorderRadius.vertical(top: Radius.circular(0)),
      ),
      child: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
            _isScanning = (index == 0 && _isScanning);
          });
        },
        items: _bottomNavItems,
        backgroundColor: Colors.transparent,
        selectedItemColor: const Color.fromARGB(255, 20, 20, 20),
        unselectedItemColor: Colors.white,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
    );
  }

  Widget _buildScannerView() {
    return Stack(
      children: [
        MobileScanner(
          controller: _scannerController,
          onDetect: (capture) {
            final List<Barcode> barcodes = capture.barcodes;
            if (barcodes.isNotEmpty) {
              final String barcode = barcodes.first.rawValue ?? '';
              if (barcode.isNotEmpty) {
                _barcodeController.text = barcode;
                _fetchProductInfo(barcode);
              }
            }
          },
        ),
        Positioned(
          top: 40,
          left: 20,
          child: IconButton(
            icon: Icon(Icons.close, color: Colors.white),
            onPressed: () => setState(() => _isScanning = false),
          ),
        ),
        Align(
          alignment: Alignment.bottomCenter,
          child: Container(
            margin: EdgeInsets.only(bottom: 70), // Above bottom bar
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.4),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              'Point your camera at a barcode',
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInputView() {
    return ListView(
      padding: EdgeInsets.all(38.0),
      children: [
        SizedBox(height: 16),

        // Add barcode scanner icon/logo
        Icon(
          Icons.qr_code_scanner,
          size: 200,
          color: const Color.fromARGB(255, 179, 181, 179),
        ),
        SizedBox(height: 16),

        // Scanner un produit section
        Text(
          'Scanner un produit',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 16),

        // Scanner le code-barres du produit
        Text(
          'Scanner le code-barres du produit',
          style: TextStyle(fontSize: 16),
        ),
        SizedBox(height: 8),
        MaterialButton(
          padding: EdgeInsets.symmetric(vertical: 6, horizontal: 60),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          color: const Color.fromARGB(255, 94, 94, 94),
          onPressed: _isLoading ? null : _startBarcodeScan,
          child: Text(
            'Démarrer le scan',
            style: TextStyle(fontSize: 16, color: Colors.white),
          ),
        ),
        SizedBox(height: 32),

        // Code-barres section
        Text(
          'Code-barres',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 16),

        // Entrez manuellement le code-barre
        Text(
          'Entrez manuellement le code-barre:',
          style: TextStyle(fontSize: 16),
        ),
        SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 4,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: TextField(
              controller: _barcodeController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: 'Entrez le code-barres ici',
                hintStyle: TextStyle(color: Colors.grey),
              ),
            ),
          ),
        ),
        SizedBox(height: 16),
        MaterialButton(
          padding: EdgeInsets.symmetric(vertical: 6, horizontal: 60),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          color: const Color.fromARGB(255, 94, 94, 94),
          onPressed: _isLoading
              ? null
              : () {
                  if (_barcodeController.text.isNotEmpty) {
                    _fetchProductInfo(_barcodeController.text);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Veuillez entrer un code-barres'),
                      ),
                    );
                  }
                },
          child: Text(
            'Analyser le produit',
            style: TextStyle(fontSize: 14, color: Colors.white),
          ),
        ),
      ],
    );
  }
}
