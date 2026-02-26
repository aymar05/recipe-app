import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:recipe_app/models/recipe_request.dart';
import 'package:recipe_app/services/api/config/constants.dart';
import 'package:recipe_app/services/api_service.dart';

class RecipeProposalDetailScreen extends StatefulWidget {
  final int requestId; // On ne passe que l'ID maintenant

  const RecipeProposalDetailScreen({super.key, required this.requestId});

  @override
  State<RecipeProposalDetailScreen> createState() => _RecipeProposalDetailScreenState();
}

class _RecipeProposalDetailScreenState extends State<RecipeProposalDetailScreen> {
  final APIService _apiService = Get.find<APIService>();
  
  RecipeRequest? request;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() async {
    try {
      final fetchedRequest = await _apiService.getRecipeRequestById(widget.requestId);
      
      if (!mounted) return;

      if (fetchedRequest == null) {
        setState(() => isLoading = false);
        Get.snackbar("Erreur", "Proposition introuvable");
        return;
      }

      setState(() {
        request = fetchedRequest;
        isLoading = false;
      });
    } catch (e) {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (request == null) {
      return Scaffold(
        appBar: AppBar(title: const Text("Détail")),
        body: const Center(child: Text("Erreur de chargement")),
      );
    }

    final req = request!;

    // Gestion Image
    String? displayImage;
    if (req.imageUrl != null) {
      displayImage = req.imageUrl!.startsWith('http') 
          ? req.imageUrl 
          : "${Constants.apiBaseUrl}/${req.imageUrl!}";
    }

    // Gestion Statut
    Color statusColor;
    String statusText;
    IconData statusIcon;

    switch (req.status) {
      case 'approved':
        statusColor = Colors.green;
        statusText = "Approuvée";
        statusIcon = Icons.check_circle;
        break;
      case 'rejected':
        statusColor = Colors.red;
        statusText = "Rejetée";
        statusIcon = Icons.cancel;
        break;
      default:
        statusColor = Colors.orange;
        statusText = "En attente de validation";
        statusIcon = Icons.hourglass_top;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Détail de la proposition"),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Image
            if (displayImage != null)
              SizedBox(
                height: 250,
                width: double.infinity,
                child: Image.network(
                  displayImage,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    color: Colors.grey[300], 
                    child: const Icon(Icons.broken_image, size: 50)
                  ),
                ),
              ),

            // 2. Bandeau Statut
            Container(
              padding: const EdgeInsets.all(12),
              width: double.infinity,
              color: statusColor.withOpacity(0.1),
              child: Row(
                children: [
                  Icon(statusIcon, color: statusColor),
                  const SizedBox(width: 10),
                  Text(
                    statusText.toUpperCase(),
                    style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 3. Titre et Temps
                  Text(
                    req.title ?? "Sans titre",
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.timer, color: Colors.grey),
                      const SizedBox(width: 5),
                      Text("${req.preparationTime ?? 0} min", style: const TextStyle(fontSize: 16)),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // 4. Tags
                  if (req.tags != null && req.tags!.isNotEmpty)
                    Wrap(
                      spacing: 8,
                      children: req.tags!.map((t) => Chip(
                        label: Text(t.name ?? ''),
                        backgroundColor: Colors.grey[200],
                      )).toList(),
                    ),
                  const SizedBox(height: 20),

                  const Divider(),

                  // 5. Ingrédients
                  const Text("Ingrédients", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  if (req.ingredients != null)
                    ...req.ingredients!.map((ing) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        children: [
                          const Icon(Icons.circle, size: 8, color: Colors.grey),
                          const SizedBox(width: 8),
                          Text("${ing.name} (${ing.quantity} ${ing.measure})", style: const TextStyle(fontSize: 16)),
                        ],
                      ),
                    )),

                  const SizedBox(height: 20),
                  const Divider(),

                  // 6. Étapes
                  const Text("Instructions", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  if (req.steps != null)
                    ...req.steps!.asMap().entries.map((entry) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(color: Theme.of(context).colorScheme.primary.withOpacity(0.1), shape: BoxShape.circle),
                            child: Text('${entry.key + 1}', style: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.primary)),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(entry.value.name ?? '', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                if (entry.value.description != null)
                                  Text(entry.value.description!, style: const TextStyle(color: Colors.black87)),
                                Text("${entry.value.duration ?? 0} min", style: const TextStyle(color: Colors.grey, fontSize: 12)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    )),
                    
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}