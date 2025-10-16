import 'package:flutter/material.dart';
import 'package:recipe_app/screens/account/favourite_screen.dart';
import 'package:recipe_app/screens/account/home_screen.dart';
import 'package:recipe_app/screens/account/search_screen.dart';
import 'package:recipe_app/screens/profile_page.dart';
import 'package:recipe_app/services/api_auth_service.dart'; // NOUVEL IMPORT pour la déconnexion via API

class RootScreen extends StatefulWidget {
  const RootScreen({super.key});

  @override
  State<RootScreen> createState() => _RootScreenState();
}

class _RootScreenState extends State<RootScreen> {
  int _currentIndex = 0;
  List<Widget> pages = const [
    HomeScreen(),
    SearchScreen(),
    FavouriteScreen(),
    ProfilePage(),
  ];

  // Nouvelle fonction de déconnexion utilisant le service API
  void _logout() async {
    // 1. Appelle la méthode de déconnexion du service
    await ApiAuthService().logout();

    // 2. Ferme le Drawer
    if (mounted) {
      Navigator.pop(context); 
      // 3. Navigue vers l'écran de connexion (en remplaçant toutes les routes précédentes)
      Navigator.of(context).pushReplacementNamed('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Drawer(
        child: ListView(
          children: [
            DrawerHeader(
              // Utilisation de Theme.of(context) pour accéder au thème
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary, 
              ),
              child: const Text(
                'Menu',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
            GestureDetector(
              onTap: _logout, // Appel à la nouvelle fonction de déconnexion
              child: const ListTile(
                leading: Icon(Icons.logout),
                title: Text('Déconnexion'),
              ),
            ),
          ],
        ),
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        currentIndex: _currentIndex,
        unselectedItemColor: Colors.black,
        selectedItemColor: Theme.of(context).colorScheme.primary,
        showUnselectedLabels: true,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Accueil',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Recherche',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: 'Favoris',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profil',
          ),
        ],
      ),
    );
  }
}
