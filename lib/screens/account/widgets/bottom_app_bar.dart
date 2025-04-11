import 'package:recipe_app/config/theme.dart';
import 'package:flutter/material.dart';

Widget customBottomAppBar(int index) {
  return BottomNavigationBar(
    type: BottomNavigationBarType.fixed,
    unselectedItemColor: Colors.black,
    selectedItemColor: themeData.colorScheme.primary,
    currentIndex: index,
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
  );
}
