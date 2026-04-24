import 'package:flutter/material.dart';
import '../db/database.dart';
import '../models/coffee_shop.dart';
import '../widgets/shop_card.dart';
import 'add_shop_screen.dart';
import 'detail_screen.dart';

// The main screen — shows your collection of saved coffee shops as a grid
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<CoffeeShop> _shops = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadShops();
  }

  Future<void> _loadShops() async {
    final shops = await DatabaseHelper.getAllShops();
    setState(() {
      _shops = shops;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.local_cafe, color: Color(0xFFC8936C)),
            SizedBox(width: 8),
            Text(
              'Coffee Spots',
              style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 0.5),
            ),
          ],
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFFC8936C)))
          : _shops.isEmpty
              ? _buildEmptyState()
              : _buildGrid(),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          // Go to the Add screen; when we come back, refresh the grid
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddShopScreen()),
          );
          _loadShops();
        },
        icon: const Icon(Icons.add),
        label: const Text('Add Shop'),
      ),
    );
  }

  // Shown when no shops have been saved yet
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.local_cafe_outlined, size: 80, color: Colors.brown.shade200),
          const SizedBox(height: 16),
          Text(
            'No coffee spots yet',
            style: TextStyle(
              fontSize: 18,
              color: Colors.brown.shade300,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tap + to save your first spot',
            style: TextStyle(fontSize: 14, color: Colors.brown.shade200),
          ),
        ],
      ),
    );
  }

  // The 2-column card grid
  Widget _buildGrid() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 0.78,
        ),
        itemCount: _shops.length,
        itemBuilder: (context, index) {
          return ShopCard(
            shop: _shops[index],
            onTap: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => DetailScreen(shop: _shops[index])),
              );
              _loadShops(); // refresh in case photo was added or shop was deleted
            },
          );
        },
      ),
    );
  }
}
