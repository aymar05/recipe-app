import 'package:get/get.dart';
import 'package:recipe_app/services/api_service.dart';
import 'package:recipe_app/models/recipe.dart';

class HomeController extends GetxController {
  final APIService _apiService = Get.find<APIService>();

  // États
  var isLoading = true.obs;      // Chargement initial
  var isMoreLoading = false.obs; // Chargement de la page suivante
  var recipeList = <Recipe>[].obs;

  // Pagination
  int _currentPage = 1;
  bool _hasMore = true; // Pour savoir s'il reste des pages

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

      // CORRECTION ICI : On utilise le paramètre nommé 'page'
      var newRecipes = await _apiService.getRecipes(page: _currentPage);

      if (isRefresh) {
        recipeList.assignAll(newRecipes);
      } else {
        recipeList.addAll(newRecipes);
      }

      // Si on reçoit moins de 10 items (la limite par défaut de Laravel),
      // c'est qu'on est sur la dernière page.
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