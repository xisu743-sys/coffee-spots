import 'dart:io';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:image_picker/image_picker.dart';
import '../db/database.dart';
import '../models/coffee_shop.dart';

// The full detail view of one coffee shop.
// Shows the photo (or "tap to add"), all info, and the Open in Maps button.
class DetailScreen extends StatefulWidget {
  final CoffeeShop shop;
  const DetailScreen({super.key, required this.shop});

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  late CoffeeShop _shop;

  @override
  void initState() {
    super.initState();
    _shop = widget.shop;
  }

  // Opens the address in Google Maps
  Future<void> _openMaps() async {
    final encoded = Uri.encodeComponent(_shop.address);
    final uri = Uri.parse('https://www.google.com/maps/search/?api=1&query=$encoded');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  // Lets the user pick a photo from their gallery and saves it
  Future<void> _addPhoto() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (picked == null) return;

    final updated = _shop.copyWith(photoPath: picked.path);
    await DatabaseHelper.updateShop(updated);
    setState(() => _shop = updated);
  }

  // Asks for confirmation, then deletes the shop and goes back
  Future<void> _deleteShop() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete this spot?'),
        content: const Text('This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (confirm == true) {
      await DatabaseHelper.deleteShop(_shop.id);
      if (mounted) Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Collapsible header with photo
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            actions: [
              IconButton(
                icon: const Icon(Icons.delete_outline),
                onPressed: _deleteShop,
                tooltip: 'Delete shop',
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: GestureDetector(
                onTap: _addPhoto,
                child: _shop.photoPath != null
                    ? Image.file(File(_shop.photoPath!), fit: BoxFit.cover)
                    : Container(
                        color: const Color(0xFFF5E6D3),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const SizedBox(height: 60), // space for status bar
                            const Icon(Icons.add_a_photo_outlined, size: 52, color: Color(0xFFC8936C)),
                            const SizedBox(height: 10),
                            Text(
                              'Tap to add a photo',
                              style: TextStyle(color: Colors.brown.shade300, fontSize: 15),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Come back after your visit!',
                              style: TextStyle(color: Colors.brown.shade200, fontSize: 13),
                            ),
                          ],
                        ),
                      ),
              ),
            ),
          ),

          // Shop details below the photo
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _shop.name,
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF4A2C2A),
                    ),
                  ),
                  const SizedBox(height: 24),
                  _buildInfoRow(Icons.local_cafe_outlined, 'Drink', _shop.drink, const Color(0xFFC8936C)),
                  const Divider(height: 28, color: Color(0xFFEEE0D5)),
                  _buildInfoRow(Icons.person_outline, 'Recommended by', _shop.recommendedBy, const Color(0xFF8B5E3C)),
                  if (_shop.address.isNotEmpty) ...[
                    const Divider(height: 28, color: Color(0xFFEEE0D5)),
                    _buildInfoRow(Icons.location_on_outlined, 'Address', _shop.address, Colors.grey.shade600),
                  ],
                  const SizedBox(height: 32),
                  // Map button — only shows if an address was entered
                  if (_shop.address.isNotEmpty)
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton.icon(
                        onPressed: _openMaps,
                        icon: const Icon(Icons.map_outlined),
                        label: const Text(
                          'Open in Maps',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF4A2C2A),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value, Color iconColor) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: iconColor, size: 22),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 3),
              Text(value, style: const TextStyle(fontSize: 16, color: Color(0xFF4A2C2A))),
            ],
          ),
        ),
      ],
    );
  }
}
