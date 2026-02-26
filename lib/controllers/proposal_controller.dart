import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:recipe_app/models/recipe_request.dart';
import 'package:recipe_app/services/api_service.dart';
import 'package:flutter/material.dart'; 

class ProposalController extends GetxController {
  final APIService _apiService = Get.find<APIService>();

  // --- LISTE ---
  var proposals = <RecipeRequest>[].obs;
  var isLoading = true.obs;

  // --- FORMULAIRE ---
  var isSubmitting = false.obs;
  Rx<XFile?> selectedImage = Rx<XFile?>(null);
  
  var formIngredients = <Map<String, dynamic>>[].obs;
  var formSteps = <Map<String, dynamic>>[].obs;
  var formTags = <String>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchProposals();
  }

  // Récupérer les propositions de l'utilisateur connecté
  void fetchProposals() async {
    try {
      isLoading(true);
      // L'API filtre déjà par user_id grâce à $request->user()->id
      var list = await _apiService.getUserProposals();
      proposals.assignAll(list);
    } finally {
      isLoading(false);
    }
  }

  // --- LOGIQUE DE SOUMISSION ---
  Future<bool> submitProposal(String title, String prepTime) async {
    // 1. Validations basiques
    if (selectedImage.value == null) {
      Get.snackbar("Attention", "Veuillez choisir une image", 
        backgroundColor: Get.theme.colorScheme.error, colorText: Get.theme.colorScheme.onError);
      return false;
    }
    if (title.isEmpty || prepTime.isEmpty) {
       Get.snackbar("Attention", "Titre et temps requis", 
        backgroundColor: Get.theme.colorScheme.error, colorText: Get.theme.colorScheme.onError);
       return false;
    }
    if (formIngredients.isEmpty || formSteps.isEmpty) {
      Get.snackbar("Attention", "Ajoutez au moins un ingrédient et une étape",
        backgroundColor: Get.theme.colorScheme.error, colorText: Get.theme.colorScheme.onError);
      return false;
    }

    isSubmitting(true);

    // 2. Appel API
    bool success = await _apiService.createRecipeProposal(
      title: title,
      preparationTime: int.tryParse(prepTime) ?? 0,
      imageFile: selectedImage.value!,
      ingredients: formIngredients,
      steps: formSteps,
      tags: formTags,
    );

    isSubmitting(false);

    // 3. Gestion du succès
    if (success) {
      // A. Message de succès
      Get.snackbar(
        "Succès", 
        "Votre recette a été envoyée pour validation !",
        backgroundColor: Colors.green,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
        duration: const Duration(seconds: 3),
      );

      // B. Réinitialiser le formulaire pour la prochaine fois
      _resetForm();

      // C. Rafraîchir la liste pour voir la nouvelle proposition (car backend trié par latest)
      fetchProposals();

      // D. Retourner à la page précédente (La liste des propositions)
      Get.back(); 
      
      return true;
    } else {
      Get.snackbar(
        "Erreur", 
        "Une erreur est survenue lors de l'envoi.",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return false;
    }
  }

  // --- OUTILS FORMULAIRE ---
  Future<void> pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      selectedImage.value = image;
    }
  }

  void addIngredient(String name, String qty, String measure) {
    if (name.isNotEmpty && qty.isNotEmpty && measure.isNotEmpty) {
      formIngredients.add({
        'name': name,
        'quantity': int.tryParse(qty) ?? 0,
        'measure': measure,
      });
    }
  }

  void removeIngredient(int index) => formIngredients.removeAt(index);

  void addStep(String name, String desc, String duration) {
    if (name.isNotEmpty && desc.isNotEmpty && duration.isNotEmpty) {
      formSteps.add({
        'name': name,
        'description': desc,
        'duration': int.tryParse(duration) ?? 0,
      });
    }
  }

  void removeStep(int index) => formSteps.removeAt(index);

  void addTag(String tag) {
    if (tag.isNotEmpty && !formTags.contains(tag)) formTags.add(tag);
  }

  void removeTag(String tag) => formTags.remove(tag);

  void _resetForm() {
    selectedImage.value = null;
    formIngredients.clear();
    formSteps.clear();
    formTags.clear();
  }
}