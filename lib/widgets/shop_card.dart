import 'dart:io';
import 'package:flutter/material.dart';
import '../models/coffee_shop.dart';

// A single card in the grid — shows photo (or coffee icon), name, drink, and who recommended it
class ShopCard extends StatelessWidget {
  final CoffeeShop shop;
  final VoidCallback onTap;

  const ShopCard({super.key, required this.shop, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF4A2C2A).withValues(alpha: 0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top half: photo or placeholder icon
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              child: AspectRatio(
                aspectRatio: 1,
                child: shop.photoPath != null
                    ? Image.file(File(shop.photoPath!), fit: BoxFit.cover)
                    : Container(
                        color: const Color(0xFFF5E6D3),
                        child: const Center(
                          child: Icon(
                            Icons.local_cafe_outlined,
                            size: 40,
                            color: Color(0xFFC8936C),
                          ),
                        ),
                      ),
              ),
            ),
            // Bottom half: shop details
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    shop.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: Color(0xFF4A2C2A),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 3),
                  Text(
                    shop.drink,
                    style: const TextStyle(fontSize: 12, color: Color(0xFFC8936C)),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 3),
                  Row(
                    children: [
                      const Icon(Icons.person_outline, size: 11, color: Color(0xFF9E9E9E)),
                      const SizedBox(width: 3),
                      Expanded(
                        child: Text(
                          shop.recommendedBy,
                          style: const TextStyle(fontSize: 11, color: Color(0xFF9E9E9E)),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
