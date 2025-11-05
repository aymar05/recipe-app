import 'package:flutter/material.dart';
import 'package:get/get.dart'; 
import 'package:recipe_app/screens/account/favourite_screen.dart';
import 'package:recipe_app/screens/account/home_screen.dart';
import 'package:recipe_app/screens/account/search_screen.dart';
import 'package:recipe_app/screens/profile_page.dart';
import 'package:recipe_app/services/api_auth_service.dart'; 
import 'package:recipe_app/services/auth_service.dart';

class RootScreen extends StatefulWidget {
  const RootScreen({super.key});

  @override
  State<RootScreen> createState() => _RootScreenState();
}

class _RootScreenState extends State<RootScreen> {
  int _currentIndex = 0;
  final List<Widget> pages = const [
    HomeScreen(),
    SearchScreen(),
    FavouriteScreen(),
    ProfilePage(),
  ];

  void _logout() async {
    final authService = AuthService();
    await authService.logout(); 
    await ApiAuthService.to.clearToken();

    Get.offAllNamed('/login');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar( 
        title: const Text('Recipe Book'),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero, 
          children: [
            DrawerHeader(
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
            ListTile( 
              leading: const Icon(Icons.logout),
              title: const Text('Déconnexion'),
              onTap: _logout, 
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