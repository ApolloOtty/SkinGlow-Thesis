import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:convert';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import 'product_detail_page.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'product.dart';

class SkincareProductPage extends StatefulWidget {
  const SkincareProductPage({super.key});

  @override
  _SkincareProductPageState createState() => _SkincareProductPageState();
}

class _SkincareProductPageState extends State<SkincareProductPage> {
  final List<Product> _products = [];

  @override
  void initState() {
    super.initState();
    _initializeTimeZone();
    _loadProducts();
  }

  Future<void> _initializeTimeZone() async {
    tz.initializeTimeZones();
    await NotificationService.init();
  }

  Future<void> _loadProducts() async {
    final prefs = await SharedPreferences.getInstance();
    final productsString = prefs.getString('products');
    if (productsString != null) {
      final List<dynamic> productsJson = jsonDecode(productsString);
      setState(() {
        _products.addAll(
            productsJson.map((json) => Product.fromJson(json)).toList());
      });
    }
  }

  Future<void> _saveProducts() async {
    final prefs = await SharedPreferences.getInstance();
    final productsJson =
        jsonEncode(_products.map((product) => product.toJson()).toList());
    await prefs.setString('products', productsJson);
  }

  void _addNewProduct(String name, DateTime openingDate,
      {int? expirationInMonths,
      DateTime? expirationDate,
      String? goodComments,
      String? badComments,
      String? imagePath}) {
    if (name.isNotEmpty &&
        (expirationInMonths != null || expirationDate != null)) {
      setState(() {
        _products.add(Product(
          name: name,
          openingDate: openingDate,
          expirationInMonths: expirationInMonths,
          expirationDate: expirationDate,
          imagePath: imagePath,
          goodComments: goodComments,
          badComments: badComments,
        ));
        _saveProducts();
      });
    }
  }

  void _editProduct(Product editedProduct) {
    setState(() {
      final index =
          _products.indexWhere((product) => product.name == editedProduct.name);
      if (index != -1) {
        _products[index] = editedProduct;
        _saveProducts();
      }
    });
  }

  void _deleteProduct(Product product) {
    setState(() {
      _products.remove(product);
      _saveProducts();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Skincare Products'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          const SizedBox(height: 16.0),
          ElevatedButton(
            onPressed: () {
              showModalBottomSheet(
                context: context,
                builder: (BuildContext context) {
                  return _AddProductForm(addProduct: _addNewProduct);
                },
              );
            },
            child: const Text('Add New Product'),
          ),
          const SizedBox(height: 16.0),
          const Text(
            'Products',
            style: TextStyle(
              fontSize: 24.0,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16.0),
          Column(
            children: _products.map((product) {
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ProductDetailsPage(
                        product: product,
                        onEdit: _editProduct,
                        onRemove: _deleteProduct,
                      ),
                    ),
                  );
                },
                child: Container(
                  margin: const EdgeInsets.only(bottom: 8.0),
                  padding: const EdgeInsets.all(12.0),
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color:
                        product.isExpired ? Colors.red[200] : Colors.grey[200],
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: Row(
                    children: [
                      if (product.imagePath != null)
                        Image.file(
                          File(product.imagePath!),
                          width: 50,
                          height: 50,
                          fit: BoxFit.cover,
                        ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              product.name,
                              style: const TextStyle(
                                  fontSize: 16.0, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 4.0),
                            Text(
                              'Opened: ${DateFormat('yyyy-MM-dd').format(product.openingDate)}',
                              style: const TextStyle(fontSize: 12.0),
                            ),
                            if (product.expirationDate != null)
                              Text(
                                'Expires: ${DateFormat('yyyy-MM-dd').format(product.expirationDate!)}',
                                style: const TextStyle(fontSize: 12.0),
                              ),
                          ],
                        ),
                      ),
                      if (product.isExpired)
                        const Icon(Icons.warning, color: Colors.red),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class _AddProductForm extends StatefulWidget {
  final void Function(String name, DateTime openingDate,
      {int? expirationInMonths,
      DateTime? expirationDate,
      String? goodComments,
      String? badComments,
      String? imagePath}) addProduct;

  const _AddProductForm({required this.addProduct});

  @override
  __AddProductFormState createState() => __AddProductFormState();
}

class __AddProductFormState extends State<_AddProductForm> {
  late TextEditingController _nameController;
  late TextEditingController _expirationController;
  late TextEditingController _goodCommentsController;
  late TextEditingController _badCommentsController;
  DateTime _selectedDate = DateTime.now();
  DateTime? _selectedExpirationDate;
  String? _imagePath;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _expirationController = TextEditingController();
    _goodCommentsController = TextEditingController();
    _badCommentsController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _expirationController.dispose();
    _goodCommentsController.dispose();
    _badCommentsController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _selectExpirationDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedExpirationDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedExpirationDate) {
      setState(() {
        _selectedExpirationDate = picked;
      });
    }
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _imagePath = image.path;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Product Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 8.0),
            Row(
              children: [
                Expanded(
                  child: Text(
                    "Opening Date: ${DateFormat('yyyy-MM-dd').format(_selectedDate)}",
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.calendar_today),
                  onPressed: () => _selectDate(context),
                ),
              ],
            ),
            const SizedBox(height: 8.0),
            TextField(
              controller: _expirationController,
              decoration: InputDecoration(
                labelText: 'Expiration (months, leave blank if picking a date)',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 8.0),
            Row(
              children: [
                Expanded(
                  child: Text(
                    "Expiration Date: ${_selectedExpirationDate != null ? DateFormat('yyyy-MM-dd').format(_selectedExpirationDate!) : 'Not set'}",
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.calendar_today),
                  onPressed: () => _selectExpirationDate(context),
                ),
              ],
            ),
            const SizedBox(height: 8.0),
            TextField(
              controller: _goodCommentsController,
              decoration: InputDecoration(
                labelText: "What's good about this product? (optional)",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 8.0),
            TextField(
              controller: _badCommentsController,
              decoration: InputDecoration(
                labelText: "What's not good about this product? (optional)",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 8.0),
            ElevatedButton.icon(
              onPressed: _pickImage,
              icon: const Icon(Icons.image),
              label: const Text('Pick Image'),
            ),
            if (_imagePath != null)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Image.file(
                  File(_imagePath!),
                  height: 100,
                ),
              ),
            const SizedBox(height: 8.0),
            ElevatedButton(
              onPressed: () {
                widget.addProduct(
                  _nameController.text,
                  _selectedDate,
                  expirationInMonths: _expirationController.text.isNotEmpty
                      ? int.parse(_expirationController.text)
                      : null,
                  expirationDate: _selectedExpirationDate,
                  goodComments: _goodCommentsController.text.isNotEmpty
                      ? _goodCommentsController.text
                      : null,
                  badComments: _badCommentsController.text.isNotEmpty
                      ? _badCommentsController.text
                      : null,
                  imagePath: _imagePath,
                );
                Navigator.pop(context);
              },
              child: const Text('Save Product'),
            ),
          ],
        ),
      ),
    );
  }
}
