import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:recipe_app/controllers/home_controller.dart';
import 'package:recipe_app/models/recipe.dart';
import 'package:recipe_app/screens/account/recipe_screen.dart';
import 'package:recipe_app/services/api/config/constants.dart'; // Import de ta constante

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Initialisation du contrôleur
    final HomeController controller = Get.put(HomeController());
    
    // Contrôleur de scroll pour la pagination
    final ScrollController scrollController = ScrollController();

    scrollController.addListener(() {
      if (scrollController.position.pixels == scrollController.position.maxScrollExtent) {
        controller.loadNextPage();
      }
    });

    return Scaffold(
      appBar: AppBar(
        leading: GestureDetector(
          onTap: () {
             Scaffold.maybeOf(context)?.openDrawer();
          },
          child: const Icon(Icons.menu),
        ),
        title: const Text("Recipe Book"),
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              // Get.toNamed('/profile');
            },
          ),
        ],
        centerTitle: true,
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.recipeList.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.search_off, size: 64, color: Colors.grey),
                const SizedBox(height: 16),
                const Text("Aucune recette trouvée."),
                TextButton(
                  onPressed: controller.refreshRecipes,
                  child: const Text("Réessayer"),
                )
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: controller.refreshRecipes,
          child: Column(
            children: [
              Expanded(
                child: GridView.builder(
                  controller: scrollController,
                  padding: const EdgeInsets.all(10),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.75,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                  ),
                  itemCount: controller.recipeList.length,
                  itemBuilder: (context, index) {
                    final recipe = controller.recipeList[index];
                    return _buildRecipeCard(context, recipe);
                  },
                ),
              ),
              if (controller.isMoreLoading.value)
                const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: CircularProgressIndicator(),
                ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildRecipeCard(BuildContext context, Recipe recipe) {
    String imageUrlToUse = "https://via.placeholder.com/150";

    String? rawPath = (recipe.imageUrl != null && recipe.imageUrl!.isNotEmpty)
        ? recipe.imageUrl
        : recipe.image;

    if (rawPath != null && rawPath.isNotEmpty) {
      if (rawPath.startsWith('http')) {
        imageUrlToUse = rawPath;
      } else {
        // Utilisation de Constants.apiBaseUrl
        if (rawPath.startsWith('/')) {
           imageUrlToUse = "${Constants.apiBaseUrl}$rawPath";
        } else {
           imageUrlToUse = "${Constants.apiBaseUrl}/$rawPath";
        }
      }
    }

    return GestureDetector(
      onTap: () {
        if (recipe.id != null) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => RecipeScreen(recipeId: recipe.id!),
            ),
          );
        }
      },
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
                  image: DecorationImage(
                    image: NetworkImage(imageUrlToUse),
                    fit: BoxFit.cover,
                    onError: (exception, stackTrace) {},
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    recipe.title ?? "Recette sans titre",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.timer, size: 14, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text(
                        "${recipe.time ?? 0} min",
                        style: const TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}