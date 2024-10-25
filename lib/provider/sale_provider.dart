import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class SaleProvider extends ChangeNotifier {
  final TextEditingController numJarsController = TextEditingController();
  final TextEditingController buyerNameController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController paidAmountController = TextEditingController();
  final TextEditingController locationController = TextEditingController();
  final TextEditingController phoneNumberController = TextEditingController();

  bool _isPaid = false;
  double _dueAmount = 0;
  bool _isLoading = false;
  final DateTime _selectedDate = DateTime.now();

  bool get isPaid => _isPaid;
  double get dueAmount => _dueAmount;
  bool get isLoading => _isLoading;

  void calculateDueAmount() {
    double totalAmount = (int.tryParse(numJarsController.text) ?? 0) *
        (double.tryParse(priceController.text) ?? 0);
    double paidAmount = double.tryParse(paidAmountController.text) ?? 0;

    _dueAmount = totalAmount - paidAmount;
    _isPaid = _dueAmount <= 0;
    notifyListeners();
  }

  Future<void> submitSale(String jarType, BuildContext context) async {
    if (numJarsController.text.isEmpty ||
        buyerNameController.text.isEmpty ||
        priceController.text.isEmpty ||
        locationController.text.isEmpty) {
      _showMessage(context, 'Please fill in all fields');
      return;
    }

    try {
      int.parse(numJarsController.text);
      double.parse(priceController.text);
      if (phoneNumberController.text.isNotEmpty) {
        int.parse(phoneNumberController.text);
      }
    } catch (e) {
      _showMessage(context, 'Please enter valid numbers');
      return;
    }

    _isLoading = true;
    notifyListeners();

    final url = Uri.parse('https://api.prabinrijal03.com.np/api/jars/sales');

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'jarType': jarType,
        'numJars': int.parse(numJarsController.text),
        'buyerName': buyerNameController.text,
        'pricePerJar': double.parse(priceController.text),
        'isPaid': _isPaid,
        'saleDate': _selectedDate.toUtc().toIso8601String(),
        'paidAmount': double.parse(paidAmountController.text),
        'dueAmount': _dueAmount,
        'location': locationController.text,
        'phoneNumber': phoneNumberController.text.isNotEmpty
            ? int.parse(phoneNumberController.text)
            : null,
      }),
    );

    _isLoading = false;
    notifyListeners();

    if (response.statusCode == 201) {
      _showMessage(context, 'Sale recorded successfully!');
      clearData();
      Navigator.pop(context);
    } else {
      _showMessage(context, 'Failed to record sale!');
    }
  }

  void _showMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  void clearData() {
    numJarsController.clear();
    buyerNameController.clear();
    priceController.clear();
    paidAmountController.clear();
    locationController.clear();
    phoneNumberController.clear();
    
    _dueAmount = 0;
    _isPaid = false;
    _isLoading = false;
    
    notifyListeners();
  }

  @override
  void dispose() {
    numJarsController.dispose();
    buyerNameController.dispose();
    priceController.dispose();
    paidAmountController.dispose();
    locationController.dispose();
    phoneNumberController.dispose();
    super.dispose();
  }
}
