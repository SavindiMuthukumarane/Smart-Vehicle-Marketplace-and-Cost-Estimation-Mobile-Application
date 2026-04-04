import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/vehicle.dart';
import '../../providers/app_provider.dart';

class AddListingScreen extends StatefulWidget {
  const AddListingScreen({super.key});

  @override
  State<AddListingScreen> createState() => _AddListingScreenState();
}

class _AddListingScreenState extends State<AddListingScreen> {
  final _formKey = GlobalKey<FormState>();

  String _brand = '';
  String _model = '';
  int _year = DateTime.now().year;
  double _price = 0;
  String _category = 'SUV';
  String _fuelType = 'Petrol';
  String _transmission = 'Automatic';
  int _mileage = 0;
  String _description = '';

  final List<String> _categories = ['SUV', 'Sedan', 'Electric', 'Hatchback'];
  final List<String> _fuelTypes = ['Petrol', 'Diesel', 'Electric', 'Hybrid'];
  final List<String> _transmissions = ['Automatic', 'Manual'];

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      final provider = Provider.of<AppProvider>(context, listen: false);

      // Check if user is logged in
      if (provider.currentUser == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please log in to list a vehicle.')),
        );
        return;
      }

      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      final newVehicle = Vehicle(
        id: '', // Will be set by Firestore
        sellerId: provider.currentUser!.id,
        brand: _brand,
        model: _model,
        year: _year,
        price: _price,
        category: _category,
        fuelType: _fuelType,
        transmission: _transmission,
        mileage: _mileage,
        description: _description,
        images: [],
      );

      final success = await provider.addVehicleToFirestore(newVehicle);

      // Close loading dialog
      if (mounted) {
        Navigator.of(context).pop();
      }

      if (success) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Vehicle listed successfully!')),
          );

          _formKey.currentState!.reset();
          setState(() {
            _category = 'SUV';
            _fuelType = 'Petrol';
            _transmission = 'Automatic';
          });
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to list vehicle. Please try again.'),
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF7F8FA),
        elevation: 0,
        scrolledUnderElevation: 0,
        title: const Text(
          'Sell Your Car',
          style: TextStyle(
            color: Color(0xFF1E2A3A),
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle('Basic Information'),
              const SizedBox(height: 14),
              _buildTextField(
                label: 'Brand',
                onSaved: (val) => _brand = val!,
                validator: (val) => val!.isEmpty ? 'Enter brand' : null,
              ),
              const SizedBox(height: 14),
              _buildTextField(
                label: 'Model',
                onSaved: (val) => _model = val!,
                validator: (val) => val!.isEmpty ? 'Enter model' : null,
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: _buildTextField(
                      label: 'Year',
                      keyboardType: TextInputType.number,
                      onSaved: (val) =>
                          _year = int.tryParse(val!) ?? DateTime.now().year,
                      validator: (val) {
                        if (val!.isEmpty) return 'Enter year';
                        final year = int.tryParse(val);
                        if (year == null) return 'Invalid year';
                        if (year < 1900 || year > DateTime.now().year + 1) {
                          return 'Enter valid year';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: _buildTextField(
                      label: 'Price (Rs)',
                      keyboardType: TextInputType.number,
                      onSaved: (val) => _price = double.tryParse(val!) ?? 0,
                      validator: (val) {
                        if (val!.isEmpty) return 'Enter price';
                        final price = double.tryParse(val);
                        if (price == null || price <= 0) return 'Invalid price';
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              _buildSectionTitle('Specifications'),
              const SizedBox(height: 14),
              _buildDropdown(
                label: 'Category',
                value: _category,
                items: _categories,
                onChanged: (val) => setState(() => _category = val!),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: _buildDropdown(
                      label: 'Fuel Type',
                      value: _fuelType,
                      items: _fuelTypes,
                      onChanged: (val) => setState(() => _fuelType = val!),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: _buildDropdown(
                      label: 'Transmission',
                      value: _transmission,
                      items: _transmissions,
                      onChanged: (val) => setState(() => _transmission = val!),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              _buildTextField(
                label: 'Mileage (km)',
                keyboardType: TextInputType.number,
                onSaved: (val) => _mileage = int.tryParse(val!) ?? 0,
                validator: (val) {
                  if (val!.isEmpty) return 'Enter mileage';
                  final mileage = int.tryParse(val);
                  if (mileage == null || mileage < 0) return 'Invalid mileage';
                  return null;
                },
              ),
              const SizedBox(height: 24),
              _buildSectionTitle('Description'),
              const SizedBox(height: 14),
              _buildTextField(
                label: 'Describe your vehicle',
                maxLines: 4,
                onSaved: (val) => _description = val!,
                validator: (val) => val!.isEmpty ? 'Enter description' : null,
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2F6FD6),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  onPressed: _submitForm,
                  child: const Text(
                    'List Vehicle',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Color(0xFF1E2A3A),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    int maxLines = 1,
    TextInputType? keyboardType,
    required void Function(String?) onSaved,
    required String? Function(String?) validator,
  }) {
    return TextFormField(
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
      ),
      maxLines: maxLines,
      keyboardType: keyboardType,
      onSaved: onSaved,
      validator: validator,
      initialValue: '',
    );
  }

  Widget _buildDropdown({
    required String label,
    required String value,
    required List<String> items,
    required void Function(String?) onChanged,
  }) {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
      ),
      initialValue: value,
      items: items.map((item) {
        return DropdownMenuItem(value: item, child: Text(item));
      }).toList(),
      onChanged: onChanged,
      validator: (val) => val == null ? 'Please select $label' : null,
    );
  }
}