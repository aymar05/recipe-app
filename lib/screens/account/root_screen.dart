import 'package:flutter/material.dart';
import 'package:recipe_app/screens/account/home_screen.dart';
import 'package:recipe_app/screens/account/search_screen.dart';
import 'package:recipe_app/screens/account/profile_screen.dart';
import 'package:recipe_app/screens/account/favorites_screen.dart';
import 'package:recipe_app/screens/account/proposals/user_proposals_screen.dart'; // Import de l'écran des propositions

class RootScreen extends StatefulWidget {
  const RootScreen({super.key});

  @override
  State<RootScreen> createState() => _RootScreenState();
}

class _RootScreenState extends State<RootScreen> {
  int _currentIndex = 0;

  // Liste des pages (5 onglets maintenant)
  final List<Widget> pages = const [
    HomeScreen(),          // Index 0
    SearchScreen(),        // Index 1
    UserProposalsScreen(), // Index 2 (Central - Propositions)
    FavoritesScreen(),     // Index 3
    ProfileScreen(),       // Index 4
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(child: pages[_currentIndex]),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
        
        // Type fixed est obligatoire quand on a plus de 3 items pour voir les labels
        type: BottomNavigationBarType.fixed, 
        
        // On s'assure que la couleur active correspond au thème de l'app
        selectedItemColor: Theme.of(context).colorScheme.primary,
        unselectedItemColor: Colors.grey,
        
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home), 
            label: 'Accueil'
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search), 
            label: 'Recherche'
          ),
          // Nouvel onglet pour les propositions
          BottomNavigationBarItem(
            icon: Icon(Icons.add_circle_outline), 
            label: 'Proposer'
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite), 
            label: 'Favoris'
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person), 
            label: 'Profil'
          ),
        ],
      ),
    );
  }
}