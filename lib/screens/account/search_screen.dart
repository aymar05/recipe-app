import 'package:recipe_app/screens/account/search_by_ingredient_screen.dart';
import 'package:recipe_app/screens/account/search_by_recipe_screen.dart';
import 'package:flutter/material.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final int _currentIndex = 0;
  final PageController _pageController = PageController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            height: MediaQuery.of(context).size.height,
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/search.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Container(
            height: MediaQuery.of(context).size.height,
            color: Colors.black.withOpacity(0.5),
          ),
          PageView(
            controller: _pageController,
            children: const [
              SearchByRecipeScreen(),
              SearchByIngredientScreen(),
            ],
          ),
        ],
      ),
    );
  }
}
