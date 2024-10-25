import 'package:flutter/material.dart';
import 'package:ramdhuni_jal/screens/sale_entry_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        title: const Center(
          child: Text(
            'रामधुनी जल उद्योग',
            style: TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.bold,
              color: Colors.yellow,
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 100.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                InkWell(
                  onTap: () {
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => const SaleEntryScreen(
                              jarType: 'Normal water',
                            )));
                  },
                  child: Container(
                      height: 170,
                      width: 150,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: Colors.white,
                          boxShadow: const [
                            BoxShadow(
                              blurRadius: 3,
                              color: Colors.black,
                            )
                          ]),
                      child: Image.asset(
                        'assets/images/waterJar.webp',
                      )),
                ),
                const SizedBox(
                  width: 30,
                ),
                InkWell(
                  onTap: () {
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => const SaleEntryScreen(
                              jarType: 'Chilled water',
                            )));
                  },
                  child: Container(
                      height: 170,
                      width: 150,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: Colors.white,
                          boxShadow: const [
                            BoxShadow(
                              blurRadius: 3,
                              color: Colors.black,
                            )
                          ]),
                      child: Image.asset(
                        'assets/images/chilledJar.jpg',
                      )),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
