import 'package:get/get.dart';
import 'package:recipe_app/services/api_service.dart';
import 'package:recipe_app/models/recipe.dart';

class HomeController extends GetxController {
  final APIService _apiService = Get.find<APIService>();

  // États
  var isLoading = true.obs;      // Chargement initial
  var isMoreLoading = false.obs; // Chargement de la page suivante
  var recipeList = <Recipe>[].obs;

  /// IDs des recettes en favoris — chargé en parallèle
  var favoriteIds = <int>{}.obs;

  // Pagination
  int _currentPage = 1;
  bool _hasMore = true;

  @override
  void onInit() {
    super.onInit();
    refreshRecipes();
  }

  // Rafraîchir tout (revenir page 1)
  Future<void> refreshRecipes() async {
    _currentPage = 1;
    _hasMore = true;
    await fetchRecipes(isRefresh: true);
  }

  // Charger la page suivante
  Future<void> loadNextPage() async {
    if (_hasMore && !isLoading.value && !isMoreLoading.value) {
      _currentPage++;
      await fetchRecipes(isRefresh: false);
    }
  }

  Future<void> fetchRecipes({bool isRefresh = false}) async {
    try {
      if (isRefresh) {
        isLoading(true);
      } else {
        isMoreLoading(true);
      }

      // Chargement recettes + favoris en parallèle
      final results = await Future.wait([
        _apiService.getRecipes(page: _currentPage),
        if (isRefresh) _apiService.getFavorites(),
      ]);

      final newRecipes = results[0] as List<Recipe>;

      if (isRefresh) {
        recipeList.assignAll(newRecipes);
        final favs = results[1] as List<Recipe>;
        favoriteIds.assignAll(
            favs.where((r) => r.id != null).map((r) => r.id!).toSet());
      } else {
        recipeList.addAll(newRecipes);
      }

      if (newRecipes.length < 10) {
        _hasMore = false;
      }
    } catch (e) {
      print("Erreur fetchRecipes: $e");
    } finally {
      isLoading(false);
      isMoreLoading(false);
    }
  }
}
