import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:recipe_app/models/recipe.dart';
import 'package:recipe_app/screens/account/recipe_screen.dart';
import 'package:recipe_app/services/api_service.dart';
import 'package:recipe_app/services/api/config/constants.dart'; // Import de ta constante

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  final APIService _apiService = Get.find<APIService>();
  List<Recipe> _favorites = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    setState(() => _isLoading = true);
    
    final recipes = await _apiService.getFavorites();
    
    if (mounted) {
      setState(() {
        _favorites = recipes;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Mes Favoris"),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _favorites.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.favorite_border, size: 64, color: Colors.grey),
                      const SizedBox(height: 16),
                      const Text("Aucun favori pour le moment."),
                      const SizedBox(height: 10),
                      TextButton(
                        onPressed: _loadFavorites,
                        child: const Text("Actualiser"),
                      )
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadFavorites,
                  child: GridView.builder(
                    padding: const EdgeInsets.all(10),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.75,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                    ),
                    itemCount: _favorites.length,
                    itemBuilder: (context, index) {
                      return _buildFavoriteCard(_favorites[index]);
                    },
                  ),
                ),
    );
  }

  Widget _buildFavoriteCard(Recipe recipe) {
    String imageUrlToUse = "https://via.placeholder.com/150";
    String? rawPath = (recipe.imageUrl ?? '').isNotEmpty ? recipe.imageUrl : recipe.image;
    
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
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => RecipeScreen(recipeId: recipe.id!)),
        ).then((_) {
          _loadFavorites(); 
        });
      },
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
                  image: DecorationImage(
                    image: NetworkImage(imageUrlToUse),
                    fit: BoxFit.cover,
                  ),
                ),
                child: const Align(
                  alignment: Alignment.topRight,
                  child: Padding(
                    padding: EdgeInsets.all(8.0),
                    child: CircleAvatar(
                      radius: 14,
                      backgroundColor: Colors.white,
                      child: Icon(Icons.favorite, color: Colors.red, size: 18),
                    ),
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
                    recipe.title ?? "Sans titre",
                    style: const TextStyle(fontWeight: FontWeight.bold),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.timer, size: 12, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text("${recipe.time ?? 0} min", style: const TextStyle(color: Colors.grey, fontSize: 12)),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}