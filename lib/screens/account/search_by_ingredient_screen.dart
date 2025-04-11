import 'dart:convert';

import 'package:recipe_app/data/result_type.dart';
import 'package:recipe_app/models/ingredient.dart';
import 'package:recipe_app/screens/account/search_result_screen.dart';
import 'package:recipe_app/services/api_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SearchByIngredientScreen extends StatefulWidget {
  const SearchByIngredientScreen({super.key});

  @override
  State<SearchByIngredientScreen> createState() =>
      _SearchByIngredientScreenState();
}

class _SearchByIngredientScreenState extends State<SearchByIngredientScreen>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  List<IngredientModel> _ingredients = [];
  final List<IngredientModel> _cart = [];
  final APIService _apiService = Get.put(APIService());

  _loadData() async {
    String data = await DefaultAssetBundle.of(context)
        .loadString("assets/data/ingredients.json");
    final jsonResult = jsonDecode(data);
    setState(() {
      _ingredients = (jsonResult.cast<Map<String, dynamic>>() as List)
          .map((ingredient) => IngredientModel.fromJson(ingredient))
          .toList();
    });
  }

  @override
  void initState() {
    _loadData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      height: MediaQuery.of(context).size.height,
      width: MediaQuery.of(context).size.width,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(
              vertical: 40,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Icon(
                  Icons.arrow_back,
                  color: Colors.white,
                ),
                _cart.isNotEmpty
                    ? ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const SearchResultScreen(
                                query: "burger",
                                type: ResultType.recipe,
                              ),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green[500],
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text("Recettes"),
                            Icon(
                              Icons.arrow_forward_rounded,
                              size: 17,
                            )
                          ],
                        ),
                      )
                    : const SizedBox(),
              ],
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            "Rechercher par ingrédient",
            style: TextStyle(
              fontSize: 22,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            "Sélectionnez des ingrédients pour trouver des recettes",
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[300],
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: MediaQuery.of(context).size.width,
            height: 45,
            child: ElevatedButton(
              onPressed: () {
                showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(20),
                        topRight: Radius.circular(20),
                      ),
                    ),
                    builder: (builder) {
                      return Container(
                        height: MediaQuery.of(context).size.height * 0.9,
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Column(children: [
                          const SizedBox(
                            height: 15,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                width: 80,
                                height: 7,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  color: Colors.grey[300],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          TextFormField(
                            decoration: const InputDecoration(
                              fillColor: Colors.white,
                              filled: true,
                              hintText: "Entrez une recette à rechercher",
                              suffixIcon: Icon(
                                Icons.search,
                                color: Colors.grey,
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          Expanded(
                            child: ListView.builder(
                              physics: const BouncingScrollPhysics(),
                              itemCount: _ingredients.length,
                              itemBuilder: (context, index) => ListTile(
                                onTap: () => setState(() {
                                  if (!_cart.contains(_ingredients[index])) {
                                    _cart.add(_ingredients[index]);
                                    Navigator.pop(context);
                                    return;
                                  } else {
                                    Get.snackbar(
                                      animationDuration: const Duration(
                                        milliseconds: 100,
                                      ),
                                      "Ingredient déjà ajouté",
                                      "Vous avez déjà ajouté cet ingrédient",
                                      snackPosition: SnackPosition.TOP,
                                      backgroundColor: Colors.red,
                                      colorText: Colors.white,
                                      margin: const EdgeInsets.all(10),
                                    );
                                  }
                                }),
                                title: Text(_ingredients[index].label!),
                              ),
                            ),
                          ),
                        ]),
                      );
                    });
              },
              child: const Text("Ajouter un ingrédient au panier"),
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: GridView.builder(
              itemCount: _cart.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 2,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              itemBuilder: (context, index) => Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Colors.white,
                ),
                child: Row(
                  children: [
                    Container(
                      width: 65,
                      decoration: BoxDecoration(
                        image: const DecorationImage(
                          image: AssetImage("assets/images/meal.png"),
                          fit: BoxFit.cover,
                        ),
                        borderRadius: BorderRadius.circular(10),
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Flexible(
                      child: Text(
                        _cart[index].label!,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _cart.remove(_cart[index]);
                        });
                      },
                      child: const Icon(
                        Icons.close,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(width: 10),
                  ],
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
