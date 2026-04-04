import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/app_provider.dart';
import '../../models/vehicle.dart';
import '../vehicle/vehicle_details_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedCategory = 'All';
  String _selectedFuelType = 'All';
  String _selectedTransmission = 'All';
  RangeValues _priceRange = const RangeValues(0, 200000);
  RangeValues _yearRange = const RangeValues(2010, 2026);

  final List<String> _categories = [
    'All',
    'SUV',
    'Sedan',
    'Electric',
    'Hatchback',
  ];
  final List<String> _fuelTypes = [
    'All',
    'Petrol',
    'Diesel',
    'Electric',
    'Hybrid',
  ];
  final List<String> _transmissions = ['All', 'Automatic', 'Manual'];

  List<Vehicle> _filteredVehicles = [];
  bool _showFilters = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    if (args != null && args.containsKey('category')) {
      _selectedCategory = args['category'];
      _filterVehicles();
    } else {
      _loadAllVehicles();
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _loadAllVehicles() {
    final provider = Provider.of<AppProvider>(context, listen: false);
    setState(() => _filteredVehicles = provider.allVehicles);
  }

  void _filterVehicles() {
    final provider = Provider.of<AppProvider>(context, listen: false);
    List<Vehicle> vehicles = provider.allVehicles;

    final query = _searchController.text.toLowerCase();
    if (query.isNotEmpty) {
      vehicles = vehicles
          .where(
            (v) =>
                v.brand.toLowerCase().contains(query) ||
                v.model.toLowerCase().contains(query) ||
                v.description.toLowerCase().contains(query),
          )
          .toList();
    }

    if (_selectedCategory != 'All') {
      vehicles = vehicles
          .where((v) => v.category == _selectedCategory)
          .toList();
    }
    if (_selectedFuelType != 'All') {
      vehicles = vehicles
          .where((v) => v.fuelType == _selectedFuelType)
          .toList();
    }
    if (_selectedTransmission != 'All') {
      vehicles = vehicles
          .where((v) => v.transmission == _selectedTransmission)
          .toList();
    }

    vehicles = vehicles
        .where(
          (v) => v.price >= _priceRange.start && v.price <= _priceRange.end,
        )
        .toList();

    vehicles = vehicles
        .where((v) => v.year >= _yearRange.start && v.year <= _yearRange.end)
        .toList();

    setState(() => _filteredVehicles = vehicles);
  }

  void _resetFilters() {
    setState(() {
      _selectedCategory = 'All';
      _selectedFuelType = 'All';
      _selectedTransmission = 'All';
      _priceRange = const RangeValues(0, 200000);
      _yearRange = const RangeValues(2010, 2026);
      _searchController.clear();
    });
    _loadAllVehicles();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF7F8FA),
        elevation: 0,
        title: const Text(
          'Search Vehicles',
          style: TextStyle(
            color: Color(0xFF1E2A3A),
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(
              _showFilters ? Icons.filter_list_off : Icons.filter_list,
            ),
            onPressed: () => setState(() => _showFilters = !_showFilters),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search brand, model...',
                filled: true,
                fillColor: Colors.white,
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isEmpty
                    ? null
                    : IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          _filterVehicles();
                        },
                      ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (val) => _filterVehicles(),
            ),
          ),

          // Filters Panel
          if (_showFilters)
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: _selectedCategory,
                            decoration: const InputDecoration(
                              labelText: 'Category',
                            ),
                            items: _categories
                                .map(
                                  (e) => DropdownMenuItem(
                                    value: e,
                                    child: Text(e),
                                  ),
                                )
                                .toList(),
                            onChanged: (val) {
                              if (val != null) {
                                setState(() => _selectedCategory = val);
                                _filterVehicles();
                              }
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: _selectedFuelType,
                            decoration: const InputDecoration(
                              labelText: 'Fuel Type',
                            ),
                            items: _fuelTypes
                                .map(
                                  (e) => DropdownMenuItem(
                                    value: e,
                                    child: Text(e),
                                  ),
                                )
                                .toList(),
                            onChanged: (val) {
                              if (val != null) {
                                setState(() => _selectedFuelType = val);
                                _filterVehicles();
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: _selectedTransmission,
                      decoration: const InputDecoration(
                        labelText: 'Transmission',
                      ),
                      items: _transmissions
                          .map(
                            (e) => DropdownMenuItem(value: e, child: Text(e)),
                          )
                          .toList(),
                      onChanged: (val) {
                        if (val != null) {
                          setState(() => _selectedTransmission = val);
                          _filterVehicles();
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Price Range'),
                        RangeSlider(
                          values: _priceRange,
                          min: 0,
                          max: 200000,
                          divisions: 100,
                          labels: RangeLabels(
                            '${_priceRange.start.toInt()}',
                            '${_priceRange.end.toInt()}',
                          ),
                          onChanged: (val) {
                            setState(() => _priceRange = val);
                            _filterVehicles();
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Year Range'),
                        RangeSlider(
                          values: _yearRange,
                          min: 2010,
                          max: 2026,
                          divisions: 16,
                          labels: RangeLabels(
                            '${_yearRange.start.toInt()}',
                            '${_yearRange.end.toInt()}',
                          ),
                          onChanged: (val) {
                            setState(() => _yearRange = val);
                            _filterVehicles();
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: _resetFilters,
                      child: const Text('Reset Filters'),
                    ),
                  ],
                ),
              ),
            ),

          // Results List
          if (!_showFilters)
            Expanded(
              child: _filteredVehicles.isEmpty
                  ? const Center(child: Text('No vehicles found'))
                  : ListView.builder(
                      itemCount: _filteredVehicles.length,
                      itemBuilder: (context, index) {
                        final vehicle = _filteredVehicles[index];
                        return ListTile(
                          leading: const Icon(
                            Icons.directions_car,
                            color: Color(0xFF2F6FD6),
                          ),
                          title: Text('${vehicle.brand} ${vehicle.model}'),
                          subtitle: Text(
                            '${vehicle.year} • ${vehicle.fuelType} • ${vehicle.transmission}',
                          ),
                          trailing: Text(
                            'Rs ${vehicle.price.toStringAsFixed(0)}',
                          ),
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  VehicleDetailsScreen(vehicle: vehicle),
                            ),
                          ),
                        );
                      },
                    ),
            ),
        ],
      ),
    );
  }
}
