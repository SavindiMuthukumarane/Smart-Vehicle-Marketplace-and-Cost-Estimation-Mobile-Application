import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import '../../models/vehicle.dart';
import '../../providers/app_provider.dart';

class VehicleDetailsScreen extends StatelessWidget {
  final Vehicle vehicle;

  const VehicleDetailsScreen({super.key, required this.vehicle});

  Future<void> _showSellerContact(BuildContext context) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final sellerDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(vehicle.sellerId)
          .get();

      Navigator.of(context).pop(); // remove loading

      if (!sellerDoc.exists) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Seller information not found.')),
        );
        return;
      }

      final sellerData = sellerDoc.data() ?? {};
      final sellerName = sellerData['name'] ?? 'Seller';
      final sellerEmail = sellerData['email'] ?? 'Not available';
      final sellerPhone = sellerData['contact'] ?? 'Not available';

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Contact $sellerName'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Email: $sellerEmail'),
              const SizedBox(height: 8),
              Text('Phone: $sellerPhone'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Clipboard.setData(ClipboardData(text: sellerEmail));
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Email copied to clipboard.')),
                );
              },
              child: const Text('Copy Email'),
            ),
            TextButton(
              onPressed: () {
                Clipboard.setData(ClipboardData(text: sellerPhone));
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Phone copied to clipboard.')),
                );
              },
              child: const Text('Copy Phone'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          ],
        ),
      );
    } catch (e) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load seller contact: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            expandedHeight: 300,
            pinned: true,
            iconTheme: const IconThemeData(color: Colors.white),
            actions: [
              Consumer<AppProvider>(
                builder: (context, appProvider, child) {
                  return IconButton(
                    onPressed: () {
                      appProvider.toggleFavorite(vehicle.id);
                    },
                    icon: Icon(
                      appProvider.isFavorite(vehicle.id)
                          ? Icons.favorite
                          : Icons.favorite_border,
                      color: appProvider.isFavorite(vehicle.id)
                          ? Colors.red
                          : Colors.white,
                      size: 28,
                    ),
                  );
                },
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(color: Color(0xFFEAF1FF)),
                child: const Center(
                  child: Icon(
                    Icons.directions_car,
                    size: 150,
                    color: Color(0xFF2F6FD6),
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Container(
              decoration: const BoxDecoration(
                color: Color(0xFFF7F8FA),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${vehicle.brand} ${vehicle.model}',
                          style: const TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1E2A3A),
                          ),
                        ),
                        Text(
                          'Rs ${vehicle.price.toStringAsFixed(0)}',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2F6FD6),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Specifications',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E2A3A),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _SpecItem(
                          icon: Icons.calendar_today,
                          label: 'Year',
                          value: '${vehicle.year}',
                        ),
                        _SpecItem(
                          icon: Icons.speed,
                          label: 'Mileage',
                          value: '${vehicle.mileage} km',
                        ),
                        _SpecItem(
                          icon: Icons.local_gas_station,
                          label: 'Fuel',
                          value: vehicle.fuelType,
                        ),
                        _SpecItem(
                          icon: Icons.settings,
                          label: 'Gear',
                          value: vehicle.transmission,
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Description',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E2A3A),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      vehicle.description,
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.black54,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 30),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 10,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          const CircleAvatar(
                            radius: 25,
                            backgroundColor: Color(0xFFEAF1FF),
                            child: Icon(Icons.person, color: Color(0xFF2F6FD6)),
                          ),
                          const SizedBox(width: 14),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Seller Info',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  'Contact to view details',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            onPressed: () => _showSellerContact(context),
                            icon: const Icon(
                              Icons.phone,
                              color: Color(0xFF2F6FD6),
                            ),
                            style: IconButton.styleFrom(
                              backgroundColor: const Color(0xFFEAF1FF),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 100), // padding for bottom bar
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2F6FD6),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            onPressed: () => _showSellerContact(context),
            child: const Text(
              'Contact Seller',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SpecItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _SpecItem({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            boxShadow: const [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 10,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Icon(icon, color: const Color(0xFF2F6FD6), size: 24),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFF1E2A3A),
            fontSize: 13,
          ),
        ),
        const SizedBox(height: 2),
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
      ],
    );
  }
}
