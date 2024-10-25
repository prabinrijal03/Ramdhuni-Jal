// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';

class PriceRecordScreen extends StatefulWidget {
  const PriceRecordScreen({super.key});

  @override
  PriceRecordScreenState createState() => PriceRecordScreenState();
}

class PriceRecordScreenState extends State<PriceRecordScreen> {
  List<dynamic> salesRecords = [];
  List<dynamic> filteredRecords = [];
  bool isLoading = true;
  double totalPaid = 0.0;
  double totalDue = 0.0;
  final TextEditingController _searchController = TextEditingController();

  Future<void> fetchSalesRecords() async {
    try {
      final url = Uri.parse('https://api.prabinrijal03.com.np/api/jars/sales');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        List<dynamic> salesData = json.decode(response.body);

        salesData.sort((a, b) => DateTime.parse(b['saleDate'])
            .compareTo(DateTime.parse(a['saleDate'])));

        double totalPaidAmount = 0.0;
        double totalDueAmount = 0.0;

        for (var sale in salesData) {
          if (sale['isPaid'] == true) {
            totalPaidAmount += sale['numJars'] * sale['pricePerJar'];
          }
          totalDueAmount += sale['dueAmount'];
        }

        setState(() {
          salesRecords = salesData;
          filteredRecords = salesData;
          totalPaid = totalPaidAmount;
          totalDue = totalDueAmount;
          isLoading = false;
        });
      } else {
        showErrorSnackbar('Failed to load sales records');
      }
    } catch (e) {
      showErrorSnackbar('Error: $e');
    }
  }

  void _filterSalesRecords() {
    String query = _searchController.text.toLowerCase();
    setState(() {
      filteredRecords = salesRecords.where((sale) {
        bool isPaid = sale['isPaid'];
        bool isPaidSearchMatch = query == 'paid' && isPaid;
        bool isDueSearchMatch = query == 'due' && !isPaid;

        return sale['buyerName'].toLowerCase().contains(query) ||
            sale['jarType'].toLowerCase().contains(query) ||
            isPaidSearchMatch ||
            isDueSearchMatch;
      }).toList();
    });
  }

  Future<void> markAsPaid(String saleId) async {
    try {
      final url =
          Uri.parse('https://api.prabinrijal03.com.np/api/jars/sales/$saleId');
      final response = await http.patch(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({'isPaid': true}),
      );

      if (!mounted) return;

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Sale marked as paid!')),
        );

        setState(() {
          var sale = salesRecords.firstWhere((sale) => sale['_id'] == saleId);

          int paidAmount = sale['numJars'] * sale['pricePerJar'];

          totalPaid += paidAmount;
          totalDue -= sale['dueAmount'];

          sale['isPaid'] = true;
          sale['paidAmount'] = paidAmount;
          sale['dueAmount'] = 0.0;
        });
      } else {
        showErrorSnackbar('Failed to mark sale as paid!');
      }
    } catch (e) {
      showErrorSnackbar('Error: $e');
    }
  }

  Future<void> deleteSale(String saleId) async {
    bool? confirm = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Delete'),
          content: const Text('Are you sure you want to delete this sale?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              child: const Text(
                'Delete',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      try {
        final url = Uri.parse(
            'https://api.prabinrijal03.com.np/api/jars/sales/$saleId');
        final response = await http.delete(url);

        if (response.statusCode == 200) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Sale deleted successfully!')),
          );

          setState(() {
            salesRecords.removeWhere((sale) => sale['_id'] == saleId);
          });
        } else {
          showErrorSnackbar('Failed to delete sale! ${response.body}');
        }
      } catch (e) {
        showErrorSnackbar('Error: $e');
      }
    }
  }

  Future<void> deleteAllSales() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete All Sales'),
          content:
              const Text('Are you sure you want to delete all sales records?'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      try {
        for (var sale in salesRecords) {
          final url = Uri.parse(
              'https://api.prabinrijal03.com.np/api/jars/sales/${sale['_id']}');
          await http.delete(url);
        }

        setState(() {
          salesRecords.clear();
          totalPaid = 0.0;
          totalDue = 0.0;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('All sales deleted successfully!')),
        );
      } catch (e) {
        showErrorSnackbar('Error deleting sales: $e');
      }
    }
  }

  void showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  void initState() {
    super.initState();
    fetchSalesRecords();
    _searchController.addListener(_filterSalesRecords);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Widget buildSaleCard(Map<String, dynamic> sale, int number) {
    DateTime saleDate = DateTime.parse(sale['saleDate']).toLocal();

    DateTime nepalTime =
        saleDate.toUtc().add(const Duration(hours: 5, minutes: 45));

    return ExpansionTile(
      title: Row(
        children: [
          Expanded(
            child: Text.rich(TextSpan(text: '$number.  ', children: [
              TextSpan(
                text: '${sale['buyerName']}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: Colors.blue,
                ),
              )
            ])),
          ),
          Text(
            sale['isPaid'] ? 'Paid' : 'Due',
            style: TextStyle(
              color: sale['isPaid'] ? Colors.green : Colors.red,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            '(${sale['jarType']})',
            style: const TextStyle(color: Colors.black54),
          ),
        ],
      ),
      subtitle: Text(
        'Date: ${DateFormat('yyyy-MM-dd').format(nepalTime)} | Total: Rs ${sale['numJars'] * sale['pricePerJar']}',
      ),
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Jars: ${sale['numJars']} | Price per Jar: Rs ${sale['pricePerJar']}',
                style: const TextStyle(),
              ),
              Text(
                'Time: ${DateFormat('hh:mm a').format(nepalTime)}',
                style: const TextStyle(color: Colors.black87),
              ),
              Text(
                'Location: ${sale['location']}',
                style: const TextStyle(color: Colors.black),
              ),
              Text(
                'Phone Number: ${sale['phoneNumber']}',
                style: const TextStyle(color: Colors.black),
              ),
              const Divider(),
              Text('Paid: Rs ${sale['paidAmount']}'),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Due: Rs ${sale['dueAmount']}',
                    style: const TextStyle(
                      color: Colors.red,
                    ),
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.check, color: Colors.green),
                        onPressed: !sale['isPaid']
                            ? () async {
                                bool? confirm = await showDialog<bool>(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      title: const Text('Confirm'),
                                      content: const Text(
                                          'Are you sure you want to mark this sale as paid?'),
                                      actions: [
                                        TextButton(
                                          onPressed: () {
                                            Navigator.of(context).pop(false);
                                          },
                                          child: const Text('Cancel'),
                                        ),
                                        TextButton(
                                          onPressed: () {
                                            Navigator.of(context).pop(true);
                                          },
                                          child: const Text('Yes'),
                                        ),
                                      ],
                                    );
                                  },
                                );

                                if (confirm == true) {
                                  await markAsPaid(sale['_id']);
                                }
                              }
                            : null,
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => deleteSale(sale['_id']),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Price Records',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_forever),
            onPressed: deleteAllSales,
            tooltip: 'Delete All Sales',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: fetchSalesRecords,
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        labelText: 'Search',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        prefixIcon: const Icon(Icons.search),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Expanded(
                      child: ListView.builder(
                        itemCount: filteredRecords.length,
                        itemBuilder: (context, index) {
                          var sale = filteredRecords[index];
                          return buildSaleCard(
                              sale, index + 1); // Pass the index (1-based)
                        },
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                          border: Border.all(color: Colors.black)),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Text.rich(
                            TextSpan(
                                text: 'Total Paid: ',
                                style: const TextStyle(
                                  fontSize: 14,
                                ),
                                children: [
                                  TextSpan(
                                      text:
                                          'Rs ${totalPaid.toStringAsFixed(0)}',
                                      style: const TextStyle(
                                        color: Colors.red,
                                      ))
                                ]),
                          ),
                          const Text(
                            '|',
                            style: TextStyle(
                              fontSize: 30,
                            ),
                          ),
                          Text.rich(
                            TextSpan(
                              text: 'Total Due:',
                              style: const TextStyle(
                                fontSize: 14,
                              ),
                              children: [
                                TextSpan(
                                    text: ' Rs ${totalDue.toStringAsFixed(0)}',
                                    style: const TextStyle(
                                      color: Colors.red,
                                    ))
                              ],
                            ),
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
}
