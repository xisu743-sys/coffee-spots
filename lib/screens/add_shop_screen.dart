import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';
import '../config.dart';
import '../db/database.dart';
import '../models/coffee_shop.dart';

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
  List<dynamic> _addressSuggestions = [];
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    // Listen for every keystroke in the address field
    _addressController.addListener(_onAddressChanged);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _nameController.dispose();
    _drinkController.dispose();
    _recommendedByController.dispose();
    _addressController.removeListener(_onAddressChanged);
    _addressController.dispose();
    super.dispose();
  }

  // Called every time the address field changes — waits 500ms before searching
  void _onAddressChanged() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () async {
      final query = _addressController.text.trim();
      if (query.length < 3) {
        setState(() => _addressSuggestions = []);
        return;
      }
      final results = await _fetchSuggestions(query);
      if (mounted) setState(() => _addressSuggestions = results);
    });
  }

  // Calls Google Places API to find matching businesses and addresses worldwide
  Future<List<dynamic>> _fetchSuggestions(String query) async {
    try {
      final encoded = Uri.encodeComponent(query);
      final response = await http.get(
        Uri.parse(
          'https://maps.googleapis.com/maps/api/place/autocomplete/json'
          '?input=$encoded'
          '&key=$googlePlacesApiKey'
          '&language=zh',
        ),
      ).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'OK') {
          return data['predictions'] as List;
        }
      }
    } catch (_) {}
    return [];
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);

    final shop = CoffeeShop(
      id: const Uuid().v4(),
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
              _buildField(_nameController, 'Shop Name', 'e.g. Seesaw Coffee',
                  Icons.store_outlined),
              const SizedBox(height: 16),
              _buildField(_drinkController, 'Recommended Drink',
                  'e.g. Oat Flat White', Icons.local_cafe_outlined),
              const SizedBox(height: 16),
              _buildField(_recommendedByController, 'Recommended By',
                  'e.g. Sarah', Icons.person_outline),
              const SizedBox(height: 16),

              // Address field + autocomplete suggestions
              _buildField(
                _addressController,
                'Address',
                'e.g. Seesaw Coffee, Shanghai',
                Icons.location_on_outlined,
                required: false,
              ),
              if (_addressSuggestions.isNotEmpty) _buildSuggestions(),

              const SizedBox(height: 8),
              Text(
                'Address is optional — add it to get a map inside the app',
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
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: _saving
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Save Spot',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // The dropdown list of address suggestions that appears while typing
  Widget _buildSuggestions() {
    return Container(
      margin: const EdgeInsets.only(top: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE8D5C4)),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 4))
        ],
      ),
      child: Column(
        children: _addressSuggestions.map((suggestion) {
          final name = suggestion['description'] as String;
          return InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () {
              // Fill the field with the selected address and hide suggestions
              _addressController.removeListener(_onAddressChanged);
              _addressController.text = name;
              _addressController.addListener(_onAddressChanged);
              setState(() => _addressSuggestions = []);
            },
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              child: Row(
                children: [
                  const Icon(Icons.location_on_outlined,
                      size: 16, color: Color(0xFFC8936C)),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      name,
                      style: const TextStyle(fontSize: 13),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
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
          ? (value) =>
              (value == null || value.trim().isEmpty)
                  ? 'Please enter $label'
                  : null
          : null,
    );
  }
}
