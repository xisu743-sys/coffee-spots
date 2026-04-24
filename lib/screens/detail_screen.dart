import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:image_picker/image_picker.dart';
import '../db/database.dart';
import '../models/coffee_shop.dart';

class DetailScreen extends StatefulWidget {
  final CoffeeShop shop;
  const DetailScreen({super.key, required this.shop});

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  late CoffeeShop _shop;
  LatLng? _mapLocation;
  bool _loadingMap = false;

  @override
  void initState() {
    super.initState();
    _shop = widget.shop;
    if (_shop.address.isNotEmpty) {
      _geocodeAddress(_shop.address);
    }
  }

  // Converts an address string into lat/lng using OpenStreetMap's free geocoding API
  Future<void> _geocodeAddress(String address) async {
    setState(() => _loadingMap = true);
    try {
      final encoded = Uri.encodeComponent(address);
      final response = await http.get(
        Uri.parse(
            'https://nominatim.openstreetmap.org/search?q=$encoded&format=json&limit=1'),
        headers: {'User-Agent': 'CoffeeSpots/1.0'},
      ).timeout(const Duration(seconds: 8));

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as List;
        if (data.isNotEmpty) {
          setState(() {
            _mapLocation = LatLng(
              double.parse(data[0]['lat']),
              double.parse(data[0]['lon']),
            );
          });
        }
      }
    } catch (_) {
      // If geocoding fails (no internet, bad address), just skip the map silently
    }
    setState(() => _loadingMap = false);
  }

  Future<void> _openMaps() async {
    final encoded = Uri.encodeComponent(_shop.address);
    final uri =
        Uri.parse('https://www.google.com/maps/search/?api=1&query=$encoded');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _addPhoto() async {
    final picker = ImagePicker();
    final picked =
        await picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (picked == null) return;

    final updated = _shop.copyWith(photoPath: picked.path);
    await DatabaseHelper.updateShop(updated);
    setState(() => _shop = updated);
  }

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
                            const SizedBox(height: 60),
                            const Icon(Icons.add_a_photo_outlined,
                                size: 52, color: Color(0xFFC8936C)),
                            const SizedBox(height: 10),
                            Text(
                              'Tap to add a photo',
                              style: TextStyle(
                                  color: Colors.brown.shade300, fontSize: 15),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Come back after your visit!',
                              style: TextStyle(
                                  color: Colors.brown.shade200, fontSize: 13),
                            ),
                          ],
                        ),
                      ),
              ),
            ),
          ),

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
                  _buildInfoRow(Icons.local_cafe_outlined, 'Drink', _shop.drink,
                      const Color(0xFFC8936C)),
                  const Divider(height: 28, color: Color(0xFFEEE0D5)),
                  _buildInfoRow(Icons.person_outline, 'Recommended by',
                      _shop.recommendedBy, const Color(0xFF8B5E3C)),

                  // Address + embedded map section
                  if (_shop.address.isNotEmpty) ...[
                    const Divider(height: 28, color: Color(0xFFEEE0D5)),
                    _buildInfoRow(Icons.location_on_outlined, 'Address',
                        _shop.address, Colors.grey.shade600),
                    const SizedBox(height: 16),
                    _buildMapSection(),
                  ],

                  const SizedBox(height: 24),
                  if (_shop.address.isNotEmpty)
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton.icon(
                        onPressed: _openMaps,
                        icon: const Icon(Icons.open_in_new),
                        label: const Text(
                          'Open in Maps',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF4A2C2A),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
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

  // The embedded map tile — shows a live map with a red pin on the address
  Widget _buildMapSection() {
    if (_loadingMap) {
      return const SizedBox(
        height: 120,
        child: Center(
          child: CircularProgressIndicator(color: Color(0xFFC8936C)),
        ),
      );
    }

    if (_mapLocation == null) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.map_outlined, size: 16, color: Colors.grey.shade500),
            const SizedBox(width: 6),
            Text(
              'Location',
              style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade500,
                  fontWeight: FontWeight.w500),
            ),
          ],
        ),
        const SizedBox(height: 8),
        // Tapping the map opens it in Google Maps for full interaction
        GestureDetector(
          onTap: _openMaps,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: SizedBox(
              height: 180,
              child: FlutterMap(
                options: MapOptions(
                  initialCenter: _mapLocation!,
                  initialZoom: 15.0,
                  // Disable pan/zoom so user can scroll the page without getting stuck
                  interactionOptions: const InteractionOptions(
                      flags: InteractiveFlag.none),
                ),
                children: [
                  TileLayer(
                    urlTemplate:
                        'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.example.coffee_spots',
                  ),
                  MarkerLayer(
                    markers: [
                      Marker(
                        point: _mapLocation!,
                        child: const Icon(Icons.location_pin,
                            color: Color(0xFFD32F2F), size: 40),
                      ),
                    ],
                  ),
                  // Attribution required by OpenStreetMap's terms of use
                  const SimpleAttributionWidget(
                    source: Text('© OpenStreetMap contributors',
                        style: TextStyle(fontSize: 10)),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Tap map to open full view',
          style: TextStyle(fontSize: 11, color: Colors.grey.shade400),
        ),
      ],
    );
  }

  Widget _buildInfoRow(
      IconData icon, String label, String value, Color iconColor) {
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
                style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                    fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 3),
              Text(value,
                  style: const TextStyle(
                      fontSize: 16, color: Color(0xFF4A2C2A))),
            ],
          ),
        ),
      ],
    );
  }
}
