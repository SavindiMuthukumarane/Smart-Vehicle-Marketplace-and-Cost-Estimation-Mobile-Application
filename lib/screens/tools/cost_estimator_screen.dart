import 'package:flutter/material.dart';

class CostEstimatorScreen extends StatefulWidget {
  const CostEstimatorScreen({super.key});

  @override
  State<CostEstimatorScreen> createState() => _CostEstimatorScreenState();
}

class _CostEstimatorScreenState extends State<CostEstimatorScreen> {
  String _category = 'SUV';
  String _mileageRange = '10k - 50k km';

  final List<String> _categories = ['SUV', 'Sedan', 'Electric', 'Hatchback'];
  final List<String> _mileageRanges = [
    '0 - 10k km',
    '10k - 50k km',
    '50k - 100k km',
    '100k+ km',
  ];

  double _calculateEstimatedCost() {
    double baseCost = 0;
    switch (_category) {
      case 'SUV':
        baseCost = 500;
        break;
      case 'Sedan':
        baseCost = 350;
        break;
      case 'Electric':
        baseCost = 200;
        break;
      case 'Hatchback':
        baseCost = 250;
        break;
    }

    double multiplier = 1.0;
    switch (_mileageRange) {
      case '0 - 10k km':
        multiplier = 1.0;
        break;
      case '10k - 50k km':
        multiplier = 1.3;
        break;
      case '50k - 100k km':
        multiplier = 1.8;
        break;
      case '100k+ km':
        multiplier = 2.5;
        break;
    }

    return baseCost * multiplier;
  }

  @override
  Widget build(BuildContext context) {
    final estimatedCost = _calculateEstimatedCost();

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      appBar: AppBar(
        title: const Text(
          'Cost Estimator',
          style: TextStyle(
            color: Color(0xFF1E2A3A),
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color(0xFFF7F8FA),
        elevation: 0,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Select Vehicle Category',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E2A3A),
              ),
            ),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
              ),
              child: DropdownButton<String>(
                value: _category,
                isExpanded: true,
                underline: const SizedBox(),
                items: _categories
                    .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                    .toList(),
                onChanged: (val) {
                  setState(() {
                    _category = val!;
                  });
                },
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Select Mileage Range',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E2A3A),
              ),
            ),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
              ),
              child: DropdownButton<String>(
                value: _mileageRange,
                isExpanded: true,
                underline: const SizedBox(),
                items: _mileageRanges
                    .map((m) => DropdownMenuItem(value: m, child: Text(m)))
                    .toList(),
                onChanged: (val) {
                  setState(() {
                    _mileageRange = val!;
                  });
                },
              ),
            ),
            const SizedBox(height: 40),
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFF2F6FD6),
                borderRadius: BorderRadius.circular(20),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 15,
                    offset: Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                children: [
                  const Text(
                    'Estimated Annual Maintenance',
                    style: TextStyle(color: Colors.white70, fontSize: 16),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Rs ${estimatedCost.toStringAsFixed(0)}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 14),
                  const Text(
                    'This is a rough estimate based on typical service costs for this category and mileage. Actual costs may vary.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white70, fontSize: 13),
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
