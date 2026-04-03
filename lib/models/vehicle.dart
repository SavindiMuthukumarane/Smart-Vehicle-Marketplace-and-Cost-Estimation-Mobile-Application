class Vehicle {
  final String id;
  final String sellerId;
  final String brand;
  final String model;
  final int year;
  final double price;
  final String category; // SUV, Sedan, Electric, Hatchback
  final String fuelType; // Petrol, Diesel, Electric, Hybrid
  final String transmission; // Automatic, Manual
  final int mileage;
  final String description;
  final List<String> images;

  Vehicle({
    required this.id,
    required this.sellerId,
    required this.brand,
    required this.model,
    required this.year,
    required this.price,
    required this.category,
    required this.fuelType,
    required this.transmission,
    required this.mileage,
    required this.description,
    required this.images,
  });

  Vehicle copyWith({
    String? id,
    String? sellerId,
    String? brand,
    String? model,
    int? year,
    double? price,
    String? category,
    String? fuelType,
    String? transmission,
    int? mileage,
    String? description,
    List<String>? images,
  }) {
    return Vehicle(
      id: id ?? this.id,
      sellerId: sellerId ?? this.sellerId,
      brand: brand ?? this.brand,
      model: model ?? this.model,
      year: year ?? this.year,
      price: price ?? this.price,
      category: category ?? this.category,
      fuelType: fuelType ?? this.fuelType,
      transmission: transmission ?? this.transmission,
      mileage: mileage ?? this.mileage,
      description: description ?? this.description,
      images: images ?? this.images,
    );
  }
}
