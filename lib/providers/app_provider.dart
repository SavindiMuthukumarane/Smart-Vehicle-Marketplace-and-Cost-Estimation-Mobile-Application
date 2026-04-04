import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/vehicle.dart';
import '../models/user_profile.dart';

class AppProvider with ChangeNotifier {
  UserProfile? currentUser;
  List<Vehicle> allVehicles = [];
  bool isLoading = true;
  Set<String> favoriteVehicleIds = {}; // Store favorite vehicle IDs

  AppProvider() {
    _initData();
  }

  void _initData() async {
    isLoading = true;
    notifyListeners();

    try {
      // Get current authenticated user
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        // Load user profile from Firestore
        await _loadUserProfile(user.uid);
      }

      // Load vehicles (for now keeping mock data, but could be from Firestore)
      await _loadVehicles();
    } catch (e) {
      print('Error initializing data: $e');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _loadUserProfile(String uid) async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .get();
      if (doc.exists) {
        final data = doc.data()!;
        currentUser = UserProfile(
          id: uid,
          name: data['name'] ?? 'Unknown',
          email: data['email'] ?? '',
          phone: data['contact'] ?? '',
          profileImageUrl: data['profileImageUrl'] ?? '',
        );
      }
    } catch (e) {
      print('Error loading user profile: $e');
    }
  }

  Future<void> _loadVehicles() async {
    try {
      // Load vehicles from Firestore
      final snapshot = await FirebaseFirestore.instance
          .collection('vehicles')
          .get();
      allVehicles = snapshot.docs.map((doc) {
        final data = doc.data();
        return Vehicle(
          id: doc.id,
          sellerId: data['sellerId'] ?? '',
          brand: data['brand'] ?? '',
          model: data['model'] ?? '',
          year: data['year'] ?? 2020,
          price: (data['price'] ?? 0).toDouble(),
          category: data['category'] ?? '',
          fuelType: data['fuelType'] ?? '',
          transmission: data['transmission'] ?? '',
          mileage: (data['mileage'] ?? 0).toInt(),
          description: data['description'] ?? '',
          images: List<String>.from(data['images'] ?? []),
        );
      }).toList();
    } catch (e) {
      print('Error loading vehicles from Firestore: $e');
      // Fallback to mock data if Firestore fails
      _loadMockVehicles();
    }
  }

  void _loadMockVehicles() {
    allVehicles = [
      Vehicle(
        id: 'v1',
        sellerId: currentUser?.id ?? 'u1',
        brand: 'Tesla',
        model: 'Model 3',
        year: 2022,
        price: 42000,
        category: 'Electric',
        fuelType: 'Electric',
        transmission: 'Automatic',
        mileage: 15000,
        description: 'Excellent condition, autopilot included.',
        images: [],
      ),
      Vehicle(
        id: 'v2',
        sellerId: currentUser?.id ?? 'u1',
        brand: 'BMW',
        model: 'X5',
        year: 2021,
        price: 58500,
        category: 'SUV',
        fuelType: 'Petrol',
        transmission: 'Automatic',
        mileage: 32000,
        description: 'Well maintained family SUV.',
        images: [],
      ),
    ];
  }

  // ✅ Public method to set current user
  void setCurrentUser(UserProfile user) {
    currentUser = user;
    // Reload vehicles to update seller IDs if needed
    _loadVehicles();
    notifyListeners();
  }

  // Method to refresh user data from Firebase
  Future<void> refreshUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await _loadUserProfile(user.uid);
      await _loadVehicles();
      notifyListeners();
    }
  }

  // Method to handle logout
  Future<void> logout() async {
    await FirebaseAuth.instance.signOut();
    currentUser = null;
    allVehicles.clear(); // Clear vehicles or reload mock data
    notifyListeners();
  }

  List<Vehicle> getFeaturedVehicles() {
    return allVehicles.take(3).toList();
  }

  List<Vehicle> getVehiclesByCategory(String category) {
    return allVehicles.where((v) => v.category == category).toList();
  }

  List<Vehicle> searchVehicles(String query) {
    if (query.isEmpty) return allVehicles;
    final lowerQuery = query.toLowerCase();
    return allVehicles.where((v) {
      return v.brand.toLowerCase().contains(lowerQuery) ||
          v.model.toLowerCase().contains(lowerQuery);
    }).toList();
  }

  List<Vehicle> getVehiclesByBudget(
    double maxBudget, {
    String? category,
    String? fuelType,
    String? transmission,
  }) {
    return allVehicles.where((v) {
      if (v.price > maxBudget) return false;
      if (category != null && category.isNotEmpty && v.category != category) {
        return false;
      }
      if (fuelType != null && fuelType.isNotEmpty && v.fuelType != fuelType) {
        return false;
      }
      if (transmission != null &&
          transmission.isNotEmpty &&
          v.transmission != transmission) {
        return false;
      }
      return true;
    }).toList();
  }

  Future<void> addVehicle(Vehicle vehicle) async {
    allVehicles.insert(0, vehicle);
    notifyListeners();
  }

  // Vehicle CRUD Operations with Firestore
  Future<bool> addVehicleToFirestore(Vehicle vehicle) async {
    try {
      if (currentUser == null) return false;

      final vehicleData = {
        'sellerId': currentUser!.id,
        'brand': vehicle.brand,
        'model': vehicle.model,
        'year': vehicle.year,
        'price': vehicle.price,
        'category': vehicle.category,
        'fuelType': vehicle.fuelType,
        'transmission': vehicle.transmission,
        'mileage': vehicle.mileage,
        'description': vehicle.description,
        'images': vehicle.images,
        'createdAt': FieldValue.serverTimestamp(),
      };

      final docRef = await FirebaseFirestore.instance
          .collection('vehicles')
          .add(vehicleData);
      final newVehicle = vehicle.copyWith(id: docRef.id);
      allVehicles.insert(0, newVehicle);
      notifyListeners();
      return true;
    } catch (e) {
      print('Error adding vehicle: $e');
      return false;
    }
  }

  Future<bool> updateVehicle(String vehicleId, Vehicle updatedVehicle) async {
    try {
      final vehicleData = {
        'brand': updatedVehicle.brand,
        'model': updatedVehicle.model,
        'year': updatedVehicle.year,
        'price': updatedVehicle.price,
        'category': updatedVehicle.category,
        'fuelType': updatedVehicle.fuelType,
        'transmission': updatedVehicle.transmission,
        'mileage': updatedVehicle.mileage,
        'description': updatedVehicle.description,
        'images': updatedVehicle.images,
        'updatedAt': FieldValue.serverTimestamp(),
      };

      await FirebaseFirestore.instance
          .collection('vehicles')
          .doc(vehicleId)
          .update(vehicleData);

      final index = allVehicles.indexWhere((v) => v.id == vehicleId);
      if (index != -1) {
        allVehicles[index] = updatedVehicle;
        notifyListeners();
      }
      return true;
    } catch (e) {
      print('Error updating vehicle: $e');
      return false;
    }
  }

  Future<bool> deleteVehicle(String vehicleId) async {
    try {
      await FirebaseFirestore.instance
          .collection('vehicles')
          .doc(vehicleId)
          .delete();
      allVehicles.removeWhere((v) => v.id == vehicleId);
      notifyListeners();
      return true;
    } catch (e) {
      print('Error deleting vehicle: $e');
      return false;
    }
  }

  // Favorites Management
  void toggleFavorite(String vehicleId) {
    if (favoriteVehicleIds.contains(vehicleId)) {
      favoriteVehicleIds.remove(vehicleId);
    } else {
      favoriteVehicleIds.add(vehicleId);
    }
    notifyListeners();
  }

  bool isFavorite(String vehicleId) {
    return favoriteVehicleIds.contains(vehicleId);
  }

  List<Vehicle> getFavoriteVehicles() {
    return allVehicles.where((v) => favoriteVehicleIds.contains(v.id)).toList();
  }
}
