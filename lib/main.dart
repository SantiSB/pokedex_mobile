import 'package:flutter/material.dart';
import 'package:pokedex/src/screens/home_screen.dart';
import 'package:pokedex/src/screens/favorites_screen.dart';
import 'package:pokedex/src/providers/favorites_provider.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // MultiProvider permite usar múltiples proveedores en la aplicación
    return MultiProvider(
      providers: [
        // Proveedor para FavoritesProvider, gestiona el estado de los favoritos
        ChangeNotifierProvider(create: (context) => FavoritesProvider()),
      ],
      child: MaterialApp(
        title: 'Pokedex',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: const HomeScreen(),
        routes: {
          '/favorites': (context) => const FavoritesScreen(),
        },
      ),
    );
  }
}
