import 'package:recipe_app/data/result_type.dart';
import 'package:recipe_app/models/recipe_search_result.dart';
import 'package:recipe_app/screens/account/recipe_screen.dart';
import 'package:recipe_app/services/api_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SearchResultScreen extends StatefulWidget {
  final String query;
  final ResultType type;

  const SearchResultScreen(
      {super.key, required this.query, required this.type});

  @override
  State<SearchResultScreen> createState() => _SearchResultScreenState();
}

class _SearchResultScreenState extends State<SearchResultScreen> {
  final List<RecipeSearchResultModel> _recipes = [];
  final APIService _apiService = Get.put(APIService());
  bool _isLoading = true;

  void _loadData() async {
    List<RecipeSearchResultModel> recipes = await _apiService.searchByRecipeName(widget.query);
    setState(() {
      _recipes.addAll(recipes);
      _isLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(
              height: 40,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  icon: const Icon(Icons.arrow_back),
                ),
                Text(
                  "Recettes",
                  style: Theme.of(context).textTheme.headlineSmall!.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                ),
                Image.asset(
                  "assets/images/splash.png",
                  width: 35,
                ),
              ],
            ),
            const SizedBox(height: 20),
            Text(
              "Résultats de recherche : ${_recipes.length} élément${_recipes.length > 1 ? "s" : ""}",
              style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: !_isLoading ? GridView.builder(
                itemCount: _recipes.length,
                physics: const BouncingScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 2.3,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                ),
                itemBuilder: (context, index) => GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => RecipeScreen(
                          recipeId: _recipes[index].id!
                        ),
                      ),
                    );
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF121212).withOpacity(0.28),
                          offset: const Offset(-1, 2),
                          blurRadius: 10,
                          spreadRadius: -3,
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 65,
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              image: NetworkImage(_recipes[index].image!),
                              fit: BoxFit.cover,
                            ),
                            borderRadius: BorderRadius.circular(10),
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Flexible(
                          child: Text(
                            _recipes[index].title!,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ): const SizedBox(
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
