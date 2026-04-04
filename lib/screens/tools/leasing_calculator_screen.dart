import 'package:flutter/material.dart';
import 'dart:math';

class LeasingCalculatorScreen extends StatefulWidget {
  const LeasingCalculatorScreen({super.key});

  @override
  State<LeasingCalculatorScreen> createState() =>
      _LeasingCalculatorScreenState();
}

class _LeasingCalculatorScreenState extends State<LeasingCalculatorScreen> {
  final _formKey = GlobalKey<FormState>();

  double _vehiclePrice = 0;
  double _downPayment = 0;
  double _interestRate = 5.0; // Annual interest rate percentage
  int _loanTermYears = 5;

  double _monthlyPayment = 0;
  double _totalInterest = 0;

  void _calculate() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      double principal = _vehiclePrice - _downPayment;
      if (principal <= 0) {
        setState(() {
          _monthlyPayment = 0;
          _totalInterest = 0;
        });
        return;
      }

      // M = P [ i(1 + i)^n ] / [ (1 + i)^n - 1]
      // P = Principal
      // i = monthly interest rate (annual / 12 / 100)
      // n = total months

      double monthlyInterestRate = _interestRate / 100 / 12;
      int totalMonths = _loanTermYears * 12;

      if (monthlyInterestRate == 0) {
        // Zero interest loan
        _monthlyPayment = principal / totalMonths;
        _totalInterest = 0;
      } else {
        double mathPower = pow(1 + monthlyInterestRate, totalMonths).toDouble();
        _monthlyPayment =
            principal * (monthlyInterestRate * mathPower) / (mathPower - 1);
        _totalInterest = (_monthlyPayment * totalMonths) - principal;
      }

      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      appBar: AppBar(
        title: const Text(
          'Leasing Calculator',
          style: TextStyle(
            color: Color(0xFF1E2A3A),
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color(0xFFF7F8FA),
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTextField(
                label: 'Vehicle Price (Rs)',
                onSaved: (val) => _vehiclePrice = double.tryParse(val!) ?? 0,
                validator: (val) {
                  if (val!.isEmpty) return 'Enter price';
                  if (double.tryParse(val) == null) return 'Invalid number';
                  return null;
                },
              ),
              const SizedBox(height: 14),
              _buildTextField(
                label: 'Down Payment (Rs)',
                onSaved: (val) => _downPayment = double.tryParse(val!) ?? 0,
                validator: (val) {
                  if (val!.isEmpty) return 'Enter down payment';
                  if (double.tryParse(val) == null) return 'Invalid number';
                  return null;
                },
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: _buildTextField(
                      label: 'Interest Rate (%)',
                      initialValue: '5.0',
                      onSaved: (val) =>
                          _interestRate = double.tryParse(val!) ?? 0,
                      validator: (val) {
                        if (val!.isEmpty) return 'Enter interest rate';
                        if (double.tryParse(val) == null) return 'Invalid';
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: _buildTextField(
                      label: 'Term (Years)',
                      initialValue: '5',
                      onSaved: (val) =>
                          _loanTermYears = int.tryParse(val!) ?? 5,
                      validator: (val) {
                        if (val!.isEmpty) return 'Enter term';
                        if (int.tryParse(val) == null) return 'Invalid';
                        return null;
                      },
                    ),
                  ),
                ],
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
                  onPressed: _calculate,
                  child: const Text(
                    'Calculate Payment',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 30),
              if (_monthlyPayment > 0)
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 10,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      const Text(
                        'Estimated Monthly Payment',
                        style: TextStyle(color: Colors.grey, fontSize: 16),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Rs ${_monthlyPayment.toStringAsFixed(2)}',
                        style: const TextStyle(
                          color: Color(0xFF2F6FD6),
                          fontSize: 40,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Divider(height: 30),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Principal Amount',
                            style: TextStyle(color: Colors.grey, fontSize: 14),
                          ),
                          Text(
                            'Rs ${(_vehiclePrice - _downPayment).toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Total Interest',
                            style: TextStyle(color: Colors.grey, fontSize: 14),
                          ),
                          Text(
                            'Rs ${_totalInterest.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    String? initialValue,
    required void Function(String?) onSaved,
    required String? Function(String?) validator,
  }) {
    return TextFormField(
      initialValue: initialValue,
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
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      onSaved: onSaved,
      validator: validator,
    );
  }
}

