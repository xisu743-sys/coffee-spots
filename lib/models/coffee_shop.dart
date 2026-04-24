// This is the "blueprint" for a coffee shop entry.
// Every shop you save will have these exact fields.
class CoffeeShop {
  final String id;
  final String name;
  final String drink;
  final String recommendedBy;
  final String address;
  final String? photoPath; // null means no photo yet
  final DateTime createdAt;

  CoffeeShop({
    required this.id,
    required this.name,
    required this.drink,
    required this.recommendedBy,
    required this.address,
    this.photoPath,
    required this.createdAt,
  });

  // Converts a CoffeeShop object into a Map so we can save it to the database
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'drink': drink,
      'recommendedBy': recommendedBy,
      'address': address,
      'photoPath': photoPath,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  // Turns a database row (Map) back into a CoffeeShop object
  factory CoffeeShop.fromMap(Map<String, dynamic> map) {
    return CoffeeShop(
      id: map['id'],
      name: map['name'],
      drink: map['drink'],
      recommendedBy: map['recommendedBy'],
      address: map['address'],
      photoPath: map['photoPath'],
      createdAt: DateTime.parse(map['createdAt']),
    );
  }

  // Creates an updated copy of this shop (used when adding a photo)
  CoffeeShop copyWith({String? photoPath}) {
    return CoffeeShop(
      id: id,
      name: name,
      drink: drink,
      recommendedBy: recommendedBy,
      address: address,
      photoPath: photoPath ?? this.photoPath,
      createdAt: createdAt,
    );
  }
}
