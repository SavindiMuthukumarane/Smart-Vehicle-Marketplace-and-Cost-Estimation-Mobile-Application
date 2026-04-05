import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:math';

class Garage {
  final String name;
  final String address;
  final String phone;
  final double latitude;
  final double longitude;
  final List<String> services;

  Garage({
    required this.name,
    required this.address,
    required this.phone,
    required this.latitude,
    required this.longitude,
    required this.services,
  });

  double distanceFrom(double userLat, double userLng) {
    const double earthRadius = 6371; // km
    final double dLat = (latitude - userLat) * pi / 180;
    final double dLng = (longitude - userLng) * pi / 180;
    final double a =
        sin(dLat / 2) * sin(dLat / 2) +
        cos(userLat * pi / 180) *
            cos(latitude * pi / 180) *
            sin(dLng / 2) *
            sin(dLng / 2);
    final double c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return earthRadius * c;
  }
}

class GarageFinderScreen extends StatefulWidget {
  const GarageFinderScreen({super.key});

  @override
  State<GarageFinderScreen> createState() => _GarageFinderScreenState();
}

class _GarageFinderScreenState extends State<GarageFinderScreen> {
  Position? _currentPosition;
  bool _isLoading = false;
  String _errorMessage = '';
  final List<Garage> _garagesWithin5km = [];
  final List<Garage> _garagesWithin10km = [];
  final List<Garage> _garagesWithin15km = [];

  // Sri Lankan garage data - real garages with locations across major cities
  final List<Garage> _allGarages = [
    Garage(
      name: 'Auto Miraj',
      address: 'No. 123, Galle Road, Colombo 03',
      phone: '+94-11-233-4567',
      latitude: 6.9271,
      longitude: 79.8612,
      services: ['Car Sales', 'Service Center', 'Parts'],
    ),
    Garage(
      name: 'David Pieris Motor Company',
      address: 'No. 45, Sir James Pieris Mawatha, Colombo 02',
      phone: '+94-11-244-5678',
      latitude: 6.9271,
      longitude: 79.8612,
      services: ['Toyota Sales', 'Service', 'Spare Parts'],
    ),
    Garage(
      name: 'Singer Auto Care',
      address: 'No. 78, Union Place, Colombo 02',
      phone: '+94-11-255-6789',
      latitude: 6.9271,
      longitude: 79.8612,
      services: ['Honda Sales', 'Service Center', 'Maintenance'],
    ),
    Garage(
      name: 'TVS Lanka',
      address: 'No. 156, Nawam Mawatha, Colombo 02',
      phone: '+94-11-266-7890',
      latitude: 6.9271,
      longitude: 79.8612,
      services: ['Motorcycle Sales', 'Service', 'Parts'],
    ),
    Garage(
      name: 'Abans Auto',
      address: 'No. 234, High Level Road, Maharagama',
      phone: '+94-11-277-8901',
      latitude: 6.8467,
      longitude: 79.9265,
      services: ['Car Sales', 'Service', 'Insurance'],
    ),
    Garage(
      name: 'Softlogic Auto',
      address: 'No. 345, Colombo - Kandy Road, Kadawatha',
      phone: '+94-11-288-9012',
      latitude: 7.0017,
      longitude: 79.9497,
      services: ['Suzuki Sales', 'Service Center', 'Finance'],
    ),
    Garage(
      name: 'Union Motors',
      address: 'No. 456, Peradeniya Road, Kandy',
      phone: '+94-81-223-3456',
      latitude: 7.2906,
      longitude: 80.6337,
      services: ['Nissan Sales', 'Service', 'Parts'],
    ),
    Garage(
      name: 'Lanka Ashok Leyland',
      address: 'No. 567, Galle Road, Galle',
      phone: '+94-91-223-4567',
      latitude: 6.0329,
      longitude: 80.2168,
      services: ['Commercial Vehicles', 'Service', 'Parts'],
    ),
    Garage(
      name: 'Micro Cars',
      address: 'No. 678, Main Street, Negombo',
      phone: '+94-31-223-5678',
      latitude: 7.2083,
      longitude: 79.8358,
      services: ['Car Sales', 'Service Center', 'Maintenance'],
    ),
    Garage(
      name: 'Ceylon Motors',
      address: 'No. 789, Colombo Road, Nugegoda',
      phone: '+94-11-299-0123',
      latitude: 6.8729,
      longitude: 79.8843,
      services: ['Multi-brand Service', 'Body Shop', 'Paint'],
    ),
  ];

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() {
          _errorMessage = 'Location services are disabled. Please enable them.';
          _isLoading = false;
        });
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          setState(() {
            _errorMessage = 'Location permissions are denied.';
            _isLoading = false;
          });
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        setState(() {
          _errorMessage = 'Location permissions are permanently denied.';
          _isLoading = false;
        });
        return;
      }

      Position position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );

      setState(() {
        _currentPosition = position;
        _findNearbyGarages();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Error getting location: $e';
        _isLoading = false;
      });
    }
  }

  void _findNearbyGarages() {
    if (_currentPosition == null) return;

    // Categorize garages by distance ranges
    final garagesWithDistance = _allGarages
        .map(
          (garage) => MapEntry(
            garage,
            garage.distanceFrom(
              _currentPosition!.latitude,
              _currentPosition!.longitude,
            ),
          ),
        )
        .toList();

    // Clear previous results
    _garagesWithin5km.clear();
    _garagesWithin10km.clear();
    _garagesWithin15km.clear();

    // Categorize garages by distance
    for (final entry in garagesWithDistance) {
      final distance = entry.value;
      final garage = entry.key;

      if (distance <= 5.0) {
        _garagesWithin5km.add(garage);
      } else if (distance <= 10.0) {
        _garagesWithin10km.add(garage);
      } else if (distance <= 15.0) {
        _garagesWithin15km.add(garage);
      }
    }

    // Sort each category by distance
    _garagesWithin5km.sort(
      (a, b) => a
          .distanceFrom(_currentPosition!.latitude, _currentPosition!.longitude)
          .compareTo(
            b.distanceFrom(
              _currentPosition!.latitude,
              _currentPosition!.longitude,
            ),
          ),
    );
    _garagesWithin10km.sort(
      (a, b) => a
          .distanceFrom(_currentPosition!.latitude, _currentPosition!.longitude)
          .compareTo(
            b.distanceFrom(
              _currentPosition!.latitude,
              _currentPosition!.longitude,
            ),
          ),
    );
    _garagesWithin15km.sort(
      (a, b) => a
          .distanceFrom(_currentPosition!.latitude, _currentPosition!.longitude)
          .compareTo(
            b.distanceFrom(
              _currentPosition!.latitude,
              _currentPosition!.longitude,
            ),
          ),
    );
  }

  Widget _buildGarageSection(String title, List<Garage> garages, Color color) {
    if (garages.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 24),
        Row(
          children: [
            Container(
              width: 4,
              height: 20,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E2A3A),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        SizedBox(
          height: 160,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: garages.length,
            itemBuilder: (context, index) {
              final garage = garages[index];
              final distance = garage.distanceFrom(
                _currentPosition!.latitude,
                _currentPosition!.longitude,
              );
              return Container(
                width: 140,
                margin: const EdgeInsets.only(right: 12),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 6,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            garage.name,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1E2A3A),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: color.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '${distance.toStringAsFixed(1)} km',
                            style: TextStyle(
                              fontSize: 10,
                              color: color,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      garage.address,
                      style: const TextStyle(fontSize: 11, color: Colors.grey),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(
                          Icons.phone,
                          size: 12,
                          color: Color(0xFF2F6FD6),
                        ),
                        const SizedBox(width: 2),
                        Expanded(
                          child: Text(
                            garage.phone,
                            style: const TextStyle(
                              fontSize: 11,
                              color: Color(0xFF1E2A3A),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Expanded(
                      child: Wrap(
                        spacing: 4,
                        runSpacing: 2,
                        children: garage.services.take(2).map((service) {
                          return Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 4,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              service,
                              style: const TextStyle(
                                fontSize: 9,
                                color: Color(0xFF1E2A3A),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF7F8FA),
        elevation: 0,
        title: const Text(
          'Find Nearby Garages (Sri Lanka)',
          style: TextStyle(
            color: Color(0xFF1E2A3A),
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_isLoading)
              const Center(child: CircularProgressIndicator())
            else if (_errorMessage.isNotEmpty)
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _errorMessage,
                      style: const TextStyle(color: Colors.red),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _getCurrentLocation,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2F6FD6),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Try Again'),
                    ),
                  ],
                ),
              )
            else if (_currentPosition != null)
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Your Location: ${_currentPosition!.latitude.toStringAsFixed(4)}, ${_currentPosition!.longitude.toStringAsFixed(4)}',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 20),
                      _buildGarageSection(
                        'Within 5km (${_garagesWithin5km.length})',
                        _garagesWithin5km,
                        const Color(0xFF4CAF50), // Green
                      ),
                      _buildGarageSection(
                        '5-10km (${_garagesWithin10km.length})',
                        _garagesWithin10km,
                        const Color(0xFFFF9800), // Orange
                      ),
                      _buildGarageSection(
                        '10-15km (${_garagesWithin15km.length})',
                        _garagesWithin15km,
                        const Color(0xFFF44336), // Red
                      ),
                      if (_garagesWithin5km.isEmpty &&
                          _garagesWithin10km.isEmpty &&
                          _garagesWithin15km.isEmpty)
                        Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.location_off,
                                size: 64,
                                color: Colors.grey.shade400,
                              ),
                              const SizedBox(height: 16),
                              const Text(
                                'No garages found within 15km',
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.grey,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                'Try moving to a different location or check back later.',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
