import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'product.dart';

class EditProductPage extends StatefulWidget {
  final Product product;
  final Function(Product) onEdit;

  const EditProductPage({
    Key? key,
    required this.product,
    required this.onEdit,
  }) : super(key: key);

  @override
  _EditProductPageState createState() => _EditProductPageState();
}

class _EditProductPageState extends State<EditProductPage> {
  late TextEditingController _nameController;
  late TextEditingController _expirationController;
  late TextEditingController _goodCommentsController;
  late TextEditingController _badCommentsController;
  late DateTime _selectedDate;
  DateTime? _selectedExpirationDate;
  String? _imagePath;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.product.name);
    _expirationController = TextEditingController(
      text: widget.product.expirationInMonths?.toString() ?? '',
    );
    _goodCommentsController =
        TextEditingController(text: widget.product.goodComments);
    _badCommentsController =
        TextEditingController(text: widget.product.badComments);
    _selectedDate = widget.product.openingDate;
    _selectedExpirationDate = widget.product.expirationDate;
    _imagePath = widget.product.imagePath;
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
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit ${widget.product.name}'),
        backgroundColor: Colors.teal,
      ),
      body: Padding(
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
                  labelText:
                      'Expiration (months, leave blank if picking a date)',
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
                  widget.onEdit(Product(
                    name: _nameController.text,
                    openingDate: _selectedDate,
                    expirationInMonths: _expirationController.text.isNotEmpty
                        ? int.parse(_expirationController.text)
                        : null,
                    expirationDate: _selectedExpirationDate,
                    imagePath: _imagePath,
                    goodComments: _goodCommentsController.text.isNotEmpty
                        ? _goodCommentsController.text
                        : null,
                    badComments: _badCommentsController.text.isNotEmpty
                        ? _badCommentsController.text
                        : null,
                  ));
                  Navigator.pop(context);
                },
                child: const Text('Save Changes'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
