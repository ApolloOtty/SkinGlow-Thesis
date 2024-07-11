import 'package:flutter/material.dart';
import 'dart:io';
import 'package:intl/intl.dart';
import 'edit_product_page.dart';
import 'product.dart';

class ProductDetailsPage extends StatelessWidget {
  final Product product;
  final Function(Product) onEdit;
  final Function(Product) onRemove;

  const ProductDetailsPage({
    Key? key,
    required this.product,
    required this.onEdit,
    required this.onRemove,
  }) : super(key: key);

  void _editProduct(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditProductPage(
          product: product,
          onEdit: onEdit,
        ),
      ),
    );
  }

  void _removeProduct(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove Product'),
        content: const Text('Are you sure you want to remove this product?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              onRemove(product);
              Navigator.of(context).pop();
              Navigator.of(context)
                  .pop(); // Go back to the previous page after deletion
            },
            child: const Text('Remove'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text(
          product.name,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.teal,
        centerTitle: true,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => _editProduct(context),
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () => _removeProduct(context),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20.0),
            ),
            elevation: 5,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (product.imagePath != null)
                    Container(
                      decoration: BoxDecoration(
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 10.0,
                            offset: const Offset(0, 5),
                          ),
                        ],
                        borderRadius: BorderRadius.circular(15.0),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(15.0),
                        child: Image.file(
                          File(product.imagePath!),
                          height: 200,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  const SizedBox(height: 24.0),
                  Text(
                    product.name,
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.blueGrey[900],
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16.0),
                  _buildInfoRow('Opening Date',
                      DateFormat('yyyy-MM-dd').format(product.openingDate)),
                  if (product.expirationInMonths != null &&
                      product.expirationInMonths! > 0)
                    _buildInfoRow(
                        'Expires in', '${product.expirationInMonths} months'),
                  if (product.expirationDate != null)
                    _buildInfoRow(
                        'Expiration Date',
                        DateFormat('yyyy-MM-dd')
                            .format(product.expirationDate!)),
                  const SizedBox(height: 16.0),
                  if (product.goodComments != null)
                    _buildCommentsSection('Good Comments',
                        product.goodComments!, Colors.green[700]!),
                  if (product.badComments != null)
                    _buildCommentsSection(
                        'Bad Comments', product.badComments!, Colors.red[700]!),
                  const SizedBox(height: 16.0),
                  if (product.isExpired)
                    const Text(
                      'This product is expired.',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.blueGrey,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.blueGrey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCommentsSection(String title, String comments, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 4.0),
        Text(
          comments,
          style: const TextStyle(fontSize: 16),
        ),
      ],
    );
  }
}
