import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/vehicle.dart';
import '../../providers/app_provider.dart';

class EditVehicleScreen extends StatefulWidget {
  final Vehicle vehicle;

  const EditVehicleScreen({super.key, required this.vehicle});

  @override
  State<EditVehicleScreen> createState() => _EditVehicleScreenState();
}

class _EditVehicleScreenState extends State<EditVehicleScreen> {
  final _formKey = GlobalKey<FormState>();

  late String _brand;
  late String _model;
  late int _year;
  late double _price;
  late String _category;
  late String _fuelType;
  late String _transmission;
  late int _mileage;
  late String _description;

  final List<String> _categories = ['SUV', 'Sedan', 'Electric', 'Hatchback'];
  final List<String> _fuelTypes = ['Petrol', 'Diesel', 'Electric', 'Hybrid'];
  final List<String> _transmissions = ['Automatic', 'Manual'];

  @override
  void initState() {
    super.initState();
    // Initialize form fields with existing vehicle data
    _brand = widget.vehicle.brand;
    _model = widget.vehicle.model;
    _year = widget.vehicle.year;
    _price = widget.vehicle.price;
    _category = widget.vehicle.category;
    _fuelType = widget.vehicle.fuelType;
    _transmission = widget.vehicle.transmission;
    _mileage = widget.vehicle.mileage;
    _description = widget.vehicle.description;
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      final provider = Provider.of<AppProvider>(context, listen: false);
      final updatedVehicle = Vehicle(
        id: widget.vehicle.id,
        sellerId: widget.vehicle.sellerId,
        brand: _brand,
        model: _model,
        year: _year,
        price: _price,
        category: _category,
        fuelType: _fuelType,
        transmission: _transmission,
        mileage: _mileage,
        description: _description,
        images: widget.vehicle.images, // Keep existing images for now
      );

      final success = await provider.updateVehicle(
        widget.vehicle.id,
        updatedVehicle,
      );

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Vehicle updated successfully!')),
        );
        Navigator.of(context).pop(); // Go back to profile
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to update vehicle. Please try again.'),
          ),
        );
      }
    }
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
    required FormFieldSetter<String> onSaved,
    required FormFieldValidator<String> validator,
    TextInputType keyboardType = TextInputType.text,
    int? maxLines = 1,
  }) {
    return TextFormField(
      initialValue: _getInitialValue(label),
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: Colors.white,
      ),
      keyboardType: keyboardType,
      maxLines: maxLines,
      validator: validator,
      onSaved: onSaved,
    );
  }

  String _getInitialValue(String label) {
    switch (label) {
      case 'Brand':
        return _brand;
      case 'Model':
        return _model;
      case 'Year':
        return _year.toString();
      case 'Price':
        return _price.toString();
      case 'Mileage':
        return _mileage.toString();
      case 'Description':
        return _description;
      default:
        return '';
    }
  }

  Widget _buildDropdown({
    required String label,
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return DropdownButtonFormField<String>(
      initialValue: value,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: Colors.white,
      ),
      items: items.map((item) {
        return DropdownMenuItem(value: item, child: Text(item));
      }).toList(),
      onChanged: onChanged,
      validator: (val) => val == null ? 'Please select $label' : null,
    );
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
          'Edit Vehicle',
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
              _buildTextField(
                label: 'Year',
                onSaved: (val) => _year = int.tryParse(val!) ?? _year,
                validator: (val) {
                  final year = int.tryParse(val!);
                  if (year == null) return 'Enter valid year';
                  if (year < 1900 || year > DateTime.now().year + 1) {
                    return 'Enter valid year';
                  }
                  return null;
                },
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 14),
              _buildTextField(
                label: 'Price',
                onSaved: (val) => _price = double.tryParse(val!) ?? _price,
                validator: (val) {
                  final price = double.tryParse(val!);
                  if (price == null || price <= 0) return 'Enter valid price';
                  return null;
                },
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 20),
              _buildSectionTitle('Specifications'),
              const SizedBox(height: 14),
              _buildDropdown(
                label: 'Category',
                value: _category,
                items: _categories,
                onChanged: (val) => setState(() => _category = val!),
              ),
              const SizedBox(height: 14),
              _buildDropdown(
                label: 'Fuel Type',
                value: _fuelType,
                items: _fuelTypes,
                onChanged: (val) => setState(() => _fuelType = val!),
              ),
              const SizedBox(height: 14),
              _buildDropdown(
                label: 'Transmission',
                value: _transmission,
                items: _transmissions,
                onChanged: (val) => setState(() => _transmission = val!),
              ),
              const SizedBox(height: 14),
              _buildTextField(
                label: 'Mileage',
                onSaved: (val) => _mileage = int.tryParse(val!) ?? _mileage,
                validator: (val) {
                  final mileage = int.tryParse(val!);
                  if (mileage == null || mileage < 0) {
                    return 'Enter valid mileage';
                  }
                  return null;
                },
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 20),
              _buildSectionTitle('Description'),
              const SizedBox(height: 14),
              _buildTextField(
                label: 'Description',
                onSaved: (val) => _description = val!,
                validator: (val) => val!.isEmpty ? 'Enter description' : null,
                maxLines: 3,
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _submitForm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2F6FD6),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Update Vehicle',
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
