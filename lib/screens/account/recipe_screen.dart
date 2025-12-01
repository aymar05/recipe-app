import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:recipe_app/models/recipe.dart';
import 'package:recipe_app/models/comment.dart'; // Import nécessaire pour CommentUser
import 'package:recipe_app/screens/account/widgets/recipe_tab.dart';
import 'package:recipe_app/services/api_service.dart';
import 'package:recipe_app/services/api/config/constants.dart';
import 'package:recipe_app/services/api_auth_service.dart'; // Import pour récupérer l'user connecté

class RecipeScreen extends StatefulWidget {
  final int recipeId;

  const RecipeScreen({super.key, required this.recipeId});

  @override
  State<RecipeScreen> createState() => _RecipeScreenState();
}

class _RecipeScreenState extends State<RecipeScreen> {
  final APIService _apiService = Get.find<APIService>();
  final TextEditingController _commentController = TextEditingController();
  
  Recipe? recipe;
  bool isLoading = true;
  bool isFavorite = false;
  bool isSendingComment = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  void _loadData() async {
    try {
      // Chargement parallèle Recette + Favoris
      final results = await Future.wait([
        _apiService.getRecipeById(widget.recipeId),
        _apiService.getFavorites()
      ]);

      final fetchedRecipe = results[0] as Recipe?;
      final favoritesList = results[1] as List<Recipe>;
      
      if (!mounted) return;
      
      if (fetchedRecipe == null) {
        setState(() => isLoading = false);
        return;
      }
      
      // Vérifie si l'ID de la recette actuelle est dans la liste des favoris
      bool foundInFavorites = favoritesList.any((fav) => fav.id == widget.recipeId);

      setState(() {
        recipe = fetchedRecipe;
        isFavorite = foundInFavorites;
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => isLoading = false);
    }
  }

  Future<void> _toggleFavorite() async {
    // Sauvegarde de l'état actuel pour rollback si erreur
    bool previousState = isFavorite;
    
    // 1. Changement visuel immédiat (Optimistic UI)
    setState(() {
      isFavorite = !isFavorite;
    });

    bool success;
    
    // 2. Appel API selon l'état DESIRE (si on vient de passer à true, on veut ajouter)
    if (isFavorite) {
      success = await _apiService.addToFavorites(widget.recipeId);
    } else {
      success = await _apiService.removeFavorite(widget.recipeId);
    }

    // 3. Gestion du résultat
    if (success) {
      Get.snackbar(
        isFavorite ? "Ajouté aux favoris" : "Retiré des favoris",
        isFavorite ? "Recette enregistrée" : "Recette retirée",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.black87,
        colorText: Colors.white,
        duration: const Duration(seconds: 1),
      );
    } else {
      // Echec : on revient à l'état précédent
      setState(() {
        isFavorite = previousState;
      });
      Get.snackbar(
        "Erreur", 
        "Impossible de modifier les favoris", 
        backgroundColor: Colors.red, 
        colorText: Colors.white
      );
    }
  }

  Future<void> _sendComment() async {
    if (_commentController.text.trim().isEmpty) return;

    setState(() => isSendingComment = true);
    
    // Appel API
    Comment? newComment = await _apiService.postComment(widget.recipeId, _commentController.text);

    setState(() => isSendingComment = false);

    if (newComment != null) {
      _commentController.clear();
      
      // --- CORRECTION ICI : Injection de l'utilisateur connecté ---
      final currentUser = ApiAuthService.to.user;
      if (currentUser != null) {
        // On modifie l'objet localement pour l'affichage immédiat
        newComment = newComment.copyWith(
          user: CommentUser(
            id: currentUser.id,
            name: currentUser.name // On utilise le nom stocké dans le service Auth
          )
        );
      }

      setState(() {
        recipe?.comments ??= [];
        recipe?.comments!.insert(0, newComment!);
      });
      
      Get.snackbar("Succès", "Commentaire ajouté !", snackPosition: SnackPosition.BOTTOM);
    } else {
      Get.snackbar("Erreur", "Échec de l'envoi", backgroundColor: Colors.red, colorText: Colors.white);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final r = recipe!;
    
    // Construction URL Image
    String? displayImage;
    String? rawPath = (r.imageUrl ?? '').isNotEmpty ? r.imageUrl : r.image;
    
    if (rawPath != null && rawPath.isNotEmpty) {
       if (rawPath.startsWith('http')) {
         displayImage = rawPath;
       } else {
         if (rawPath.startsWith('/')) {
            displayImage = "${Constants.apiBaseUrl}$rawPath";
         } else {
            displayImage = "${Constants.apiBaseUrl}/$rawPath";
         }
       }
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(r.title ?? 'Détail de la recette'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        actions: [
          IconButton(
            icon: Icon(
              isFavorite ? Icons.favorite : Icons.favorite_border,
              color: isFavorite ? Colors.red : Colors.white,
            ),
            onPressed: _toggleFavorite,
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (displayImage != null)
              SizedBox(
                width: double.infinity,
                height: MediaQuery.of(context).size.width * 0.75,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.network(
                    displayImage,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(color: Colors.grey[300]),
                  ),
                ),
              ),

            const SizedBox(height: 20),

            Text(
              r.title ?? "Sans titre",
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                const Icon(Icons.timer, color: Colors.grey, size: 20),
                const SizedBox(width: 5),
                Text("${r.time ?? 0} min", style: const TextStyle(fontSize: 16)),
              ],
            ),

            const SizedBox(height: 20),

            if (r.ingredients != null && r.ingredients!.isNotEmpty)
              RecipeTabWidget(ingredients: r.ingredients!),

            const SizedBox(height: 20),

            if (r.steps != null && r.steps!.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Instructions", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  ...r.steps!.asMap().entries.map((entry) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Text('${entry.key + 1}', style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.primary
                            )),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              entry.value.description ?? entry.value.name ?? "",
                              style: const TextStyle(fontSize: 16, height: 1.4),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ],
              ),

            const SizedBox(height: 20),
            const Divider(),
            const SizedBox(height: 10),

            const Text("Commentaires", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 10),
            
            if (r.comments != null && r.comments!.isNotEmpty)
              Column(
                children: r.comments!.map((comment) {
                  // Récupération dynamique ou fallback
                  String userName = comment.user?.name ?? "Utilisateur inconnu";
                  
                  return Card(
                    margin: const EdgeInsets.only(bottom: 10),
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: SizedBox(
                        width: double.infinity,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(userName, 
                                style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87, fontSize: 13)),
                            const SizedBox(height: 4),
                            Text(comment.text ?? "", style: const TextStyle(fontSize: 15)),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              )
            else
              const Padding(
                padding: EdgeInsets.only(bottom: 10),
                child: Text("Soyez le premier à commenter !", style: TextStyle(fontStyle: FontStyle.italic, color: Colors.grey)),
              ),

            const SizedBox(height: 10),

            const Text("Ajouter un commentaire", style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: TextField(
                    controller: _commentController,
                    decoration: const InputDecoration(
                      hintText: "Écrivez votre avis...",
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                    ),
                    minLines: 1,
                    maxLines: 3,
                  ),
                ),
                const SizedBox(width: 10),
                IconButton(
                  onPressed: isSendingComment ? null : _sendComment,
                  style: IconButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Colors.white,
                  ),
                  icon: isSendingComment 
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Icon(Icons.send),
                )
              ],
            ),
            
            SizedBox(height: MediaQuery.of(context).viewInsets.bottom + 20),
          ],
        ),
      ),
    );
  }
}