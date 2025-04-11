import 'package:recipe_app/models/recipe_model.dart';
import 'package:recipe_app/screens/account/widgets/recipe_tab.dart';
import 'package:recipe_app/screens/account/widgets/single_comment.dart';
import 'package:recipe_app/services/api_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:get/get.dart';

class RecipeScreen extends StatefulWidget {
  final int recipeId;

  const RecipeScreen({super.key, required this.recipeId});

  @override
  State<RecipeScreen> createState() => _RecipeScreenState();
}

class _RecipeScreenState extends State<RecipeScreen> {
  final APIService _apiService = Get.put(APIService());
  late RecipeModel recipeModel;
  bool isLoading = true;

  void _loadData() async {
    var recipe = await _apiService.getRecipeById(widget.recipeId);
      setState(() {
        recipeModel = recipe;
        isLoading = false;
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
      body: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        width: MediaQuery.of(context).size.width,
        child: isLoading ? const Center(child: CircularProgressIndicator()) : SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.symmetric(
                  vertical: 40,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Icon(
                      Icons.arrow_back,
                      color: Colors.black,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        recipeModel.title!,
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 20),
                      RichText(
                        text: TextSpan(
                          text: "Recette de ",
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.green[200],
                          ),
                          children: [
                            TextSpan(
                              text: "Collins Dramawa",
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.green[500],
                              ),
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                  const Icon(Icons.favorite),
                ],
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.width,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.network(
                    recipeModel.image!,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(height: 20),
               RecipeTabWidget(
                ingredients: recipeModel.extendedIngredients!,
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: MediaQuery.of(context).size.width,
                height: 45,
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green[500],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  child: const Text("Préparation"),
                ),
              ),
              const SizedBox(height: 20),
              Container(
                width: MediaQuery.of(context).size.width,
                padding: const EdgeInsets.symmetric(
                  vertical: 20,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFD9D9D9),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  children: [
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Column(
                          children: [
                            Text("Informations additionnelles"),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Column(
                          children: [
                            const Text("Préparation"),
                            Text("${recipeModel.readyInMinutes!} min"),
                          ],
                        ),
                        Column(
                          children: [
                            const Text("Points Nutritifs"),
                            Text(recipeModel.healthScore!.toString() ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: MediaQuery.of(context).size.width,
                height: 45,
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green[500],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  child: const Text("Commencer la recette"),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: MediaQuery.of(context).size.width,
                child: Column(
                  children: recipeModel.analyzedInstructions!.isEmpty ? [] : recipeModel.analyzedInstructions![0].steps!.map((e) => Column(
                    children: [
                      const SizedBox(height: 20),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 20,
                            height: 20,
                            decoration: BoxDecoration(
                              color: Colors.grey,
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Etape ${e.number}".toUpperCase(),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  e.step!,
                                  softWrap: true,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  )).toList() ,
                ),
              ),
              const SizedBox(height: 20),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF121212).withOpacity(0.28),
                      offset: const Offset(-1, 2),
                      blurRadius: 10,
                      spreadRadius: -3,
                    ),
                  ],
                ),
                width: MediaQuery.of(context).size.width,
                padding: const EdgeInsets.symmetric(
                  vertical: 20,
                  horizontal: 20,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Text("C'est terminé! Qu'en pensez-vous ?"),
                    const SizedBox(height: 15),
                    RatingBar.builder(
                      initialRating: 1.5,
                      minRating: 1,
                      itemSize: 18,
                      direction: Axis.horizontal,
                      allowHalfRating: true,
                      itemCount: 5,
                      itemBuilder: (context, _) => const Icon(
                        Icons.star,
                        color: Colors.amber,
                      ),
                      glow: false,
                      onRatingUpdate: (rating) {
                        print(rating);
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              const Text("Commentaires (3)"),
              const SizedBox(height: 20),
              const SingleComment(),
              const SizedBox(height: 20),
              const SizedBox(height: 20),
              const SingleComment(),
              const SizedBox(height: 20),
              const SizedBox(height: 20),
              const SingleComment(),
              const SizedBox(height: 20),
              const SizedBox(height: 20),
              const SingleComment(),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
