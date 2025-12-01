import 'package:recipe_app/data/result_type.dart';
import 'package:recipe_app/models/recipe.dart';
import 'package:recipe_app/screens/account/recipe_screen.dart';
import 'package:recipe_app/services/api_service.dart';
import 'package:recipe_app/services/api/config/constants.dart';
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
  final List<Recipe> _recipes = [];
  final APIService _apiService = Get.find<APIService>();
  
  bool _isLoading = false;
  bool _hasSearched = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _checkAndLoadData();
  }

  void _checkAndLoadData() {
    // 1. Vérification stricte : Si vide ou null, on ne fait rien
    if (widget.query.trim().isEmpty) {
      setState(() {
        _isLoading = false;
        _errorMessage = "Veuillez entrer un terme de recherche.";
      });
      return;
    }

    // Sinon, on lance la recherche dédiée
    _loadData();
  }

  void _loadData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // UTILISATION DE LA NOUVELLE MÉTHODE DÉDIÉE
      List<Recipe> recipes = await _apiService.searchRecipes(widget.query);
      
      if (mounted) {
        setState(() {
          _recipes.addAll(recipes);
          _isLoading = false;
          _hasSearched = true;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = "Une erreur est survenue lors de la recherche.";
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 40),
            
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.arrow_back),
                ),
                Text(
                  "Recherche",
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
            
            // Titre des résultats
            if (_hasSearched)
            Text(
              "Résultats pour \"${widget.query}\" : ${_recipes.length}",
              style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            
            const SizedBox(height: 20),

            // Contenu principal
            Expanded(
              child: _buildBody(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody() {
    // Cas 1: Erreur ou Champ vide
    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.search_off, size: 64, color: Colors.orange),
            const SizedBox(height: 16),
            Text(
              _errorMessage!,
              style: const TextStyle(fontSize: 16, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    // Cas 2: Chargement
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    // Cas 3: Aucun résultat trouvé après recherche
    if (_hasSearched && _recipes.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.sentiment_dissatisfied, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text("Aucune recette trouvée.", style: TextStyle(fontSize: 16, color: Colors.grey)),
          ],
        ),
      );
    }

    // Cas 4: Affichage des résultats
    return GridView.builder(
      itemCount: _recipes.length,
      physics: const BouncingScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.8,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemBuilder: (context, index) {
        final recipe = _recipes[index];
        
        // Gestion Image
        String imageUrlToUse = "https://via.placeholder.com/150";
        String? rawPath = (recipe.imageUrl ?? '').isNotEmpty ? recipe.imageUrl : recipe.image;
        if (rawPath != null && rawPath.isNotEmpty) {
          if (rawPath.startsWith('http')) {
            imageUrlToUse = rawPath;
          } else {
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
              MaterialPageRoute(
                builder: (context) => RecipeScreen(
                  recipeId: recipe.id!
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
                  color: const Color(0xFF121212).withOpacity(0.1),
                  offset: const Offset(0, 4),
                  blurRadius: 10,
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
                      color: Colors.grey[200],
                      image: DecorationImage(
                        image: NetworkImage(imageUrlToUse),
                        fit: BoxFit.cover,
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
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.timer, size: 12, color: Colors.grey),
                          const SizedBox(width: 4),
                          Text("${recipe.time ?? 0} min", style: const TextStyle(fontSize: 12)),
                        ],
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}