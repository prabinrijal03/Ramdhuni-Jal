import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ramdhuni_jal/provider/sale_provider.dart';
import 'package:ramdhuni_jal/screens/splash_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => SaleProvider(),
        )
      ],
      child: const MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Ramdhuni Jal',
        home: SplashScreen(),
      ),
    );
  }
}
