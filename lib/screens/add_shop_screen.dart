import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../db/database.dart';
import '../models/coffee_shop.dart';

// The form screen where you enter details about a new coffee shop
class AddShopScreen extends StatefulWidget {
  const AddShopScreen({super.key});

  @override
  State<AddShopScreen> createState() => _AddShopScreenState();
}

class _AddShopScreenState extends State<AddShopScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _drinkController = TextEditingController();
  final _recommendedByController = TextEditingController();
  final _addressController = TextEditingController();
  bool _saving = false;

  @override
  void dispose() {
    // Always clean up controllers when this screen closes
    _nameController.dispose();
    _drinkController.dispose();
    _recommendedByController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);

    final shop = CoffeeShop(
      id: const Uuid().v4(), // random unique ID
      name: _nameController.text.trim(),
      drink: _drinkController.text.trim(),
      recommendedBy: _recommendedByController.text.trim(),
      address: _addressController.text.trim(),
      createdAt: DateTime.now(),
    );

    await DatabaseHelper.insertShop(shop);
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Coffee Spot')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Tell me about this spot ☕',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF4A2C2A),
                ),
              ),
              const SizedBox(height: 24),
              _buildField(_nameController, 'Shop Name', 'e.g. Seesaw Coffee', Icons.store_outlined),
              const SizedBox(height: 16),
              _buildField(_drinkController, 'Recommended Drink', 'e.g. Oat Flat White', Icons.local_cafe_outlined),
              const SizedBox(height: 16),
              _buildField(_recommendedByController, 'Recommended By', 'e.g. Sarah', Icons.person_outline),
              const SizedBox(height: 16),
              _buildField(
                _addressController,
                'Address',
                'e.g. 123 Coffee Lane, Shanghai',
                Icons.location_on_outlined,
                required: false,
              ),
              const SizedBox(height: 8),
              Text(
                'Address is optional — add it to get a map link',
                style: TextStyle(fontSize: 12, color: Colors.brown.shade300),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _saving ? null : _save,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4A2C2A),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: _saving
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Save Spot', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildField(
    TextEditingController controller,
    String label,
    String hint,
    IconData icon, {
    bool required = true,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, color: const Color(0xFFC8936C)),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE8D5C4), width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFC8936C), width: 2),
        ),
        labelStyle: const TextStyle(color: Color(0xFF8B5E3C)),
      ),
      validator: required
          ? (value) => (value == null || value.trim().isEmpty) ? 'Please enter $label' : null
          : null,
    );
  }
}
