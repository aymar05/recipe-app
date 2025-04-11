import 'package:recipe_app/models/recipe_model.dart';
import 'package:flutter/material.dart';

class RecipeTabWidget extends StatefulWidget {
  final List<ExtendedIngredients> ingredients;
  const RecipeTabWidget({super.key,required this.ingredients});

  @override
  State<RecipeTabWidget> createState() => _RecipeTabWidgetState();
}

class _RecipeTabWidgetState extends State<RecipeTabWidget> {
  final tabs = ["Ingrédients", "Ustensiles"];
  final PageController _pageController = PageController();
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _pageController.addListener(() {
      setState(() {
        _currentIndex = _pageController.page!.toInt();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          height: 40,
          margin: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 15,
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: 6,
          ),
          decoration: BoxDecoration(
            color: const Color(0xFFD9D9D9),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Center(
            child: SizedBox(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: tabs
                    .map(
                      (e) => _buildTabElement(
                        tabs.indexOf(e),
                        context,
                      ),
                    )
                    .toList(),
              ),
            ),
          ),
        ),
        SizedBox(
          height: 300,
          child: PageView(
            controller: _pageController,
            children: [
              SingleChildScrollView(
                child: SizedBox(
                  width: MediaQuery.of(context).size.width,
                  child: Column(
                    children: widget.ingredients.map((e) => ListTile(
                      leading:  Image.network(
                        "https://spoonacular.com/cdn/ingredients_100x100/${e.image}",
                              width: 60,
                            ),
                      title: Text(e.original!),
                    ),).toList(),
                  ),
                ),
              ),
              SingleChildScrollView(
                child: SizedBox(
                  width: MediaQuery.of(context).size.width,
                  child: Text("Ustensiles" * 899),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTabElement(int index, BuildContext context) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _currentIndex = index;
          _pageController.animateToPage(
            index,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeIn,
          );
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(
          vertical: 5,
          horizontal: 20,
        ),
        decoration: BoxDecoration(
          color: index == _currentIndex ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            index == _currentIndex
                ? BoxShadow(
                    color: const Color(0xFF121212).withOpacity(0.28),
                    offset: const Offset(-1, 2),
                    blurRadius: 10,
                    spreadRadius: -3,
                  )
                : const BoxShadow(
                    color: Colors.transparent,
                  ),
          ],
        ),
        child: Text(
          tabs[index],
          style: TextStyle(
            fontWeight:
                _currentIndex == index ? FontWeight.normal : FontWeight.w200,
            color: _currentIndex == index
                ? Theme.of(context).colorScheme.primary
                : const Color(0xFF857F7F),
          ),
        ),
      ),
    );
  }
}
