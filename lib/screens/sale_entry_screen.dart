import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ramdhuni_jal/provider/sale_provider.dart';

class SaleEntryScreen extends StatefulWidget {
  final String jarType;
  const SaleEntryScreen({super.key, required this.jarType});

  @override
  SaleEntryScreenState createState() => SaleEntryScreenState();
}

class SaleEntryScreenState extends State<SaleEntryScreen> {
  @override
  Widget build(BuildContext context) {
    final saleProvider = Provider.of<SaleProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.jarType,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Enter the details of Jar:',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: saleProvider.numJarsController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Number of Jars Sold',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: saleProvider.buyerNameController,
                decoration: InputDecoration(
                  labelText: 'Customer Name',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: saleProvider.priceController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Price per Jar',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: saleProvider.locationController,
                decoration: InputDecoration(
                  labelText: 'Location',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: saleProvider.phoneNumberController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Phone Number (optional)',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: saleProvider.paidAmountController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Paid Amount',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onChanged: (_) => saleProvider.calculateDueAmount(),
              ),
              const SizedBox(height: 10),
              Text(
                'Due Amount: Rs ${saleProvider.dueAmount.toString()}',
                style: const TextStyle(fontSize: 16, color: Colors.red),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Is Payment Done?',
                    style: TextStyle(fontSize: 16),
                  ),
                  Switch(
                    activeColor: Colors.blue,
                    value: saleProvider.isPaid,
                    onChanged: saleProvider.dueAmount == 0.0
                        ? (bool value) {
                            setState(() {
                              saleProvider.isPaid;
                            });
                          }
                        : null,
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Center(
                child: SizedBox(
                  width: MediaQuery.of(context).size.width,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                    ),
                    onPressed: saleProvider.isLoading
                        ? null
                        : () =>
                            saleProvider.submitSale(widget.jarType, context),
                    child: saleProvider.isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                            'Submit',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
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
}
