import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:recipe_app/controllers/proposal_controller.dart';
import 'package:recipe_app/models/recipe_request.dart';
import 'package:recipe_app/screens/account/proposals/create_proposal_screen.dart';
import 'package:recipe_app/screens/account/proposals/recipe_proposal_detail_screen.dart';
import 'package:recipe_app/services/api/config/constants.dart';

class UserProposalsScreen extends StatelessWidget {
  const UserProposalsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Injection du contrôleur
    final ProposalController controller = Get.put(ProposalController());

    return Scaffold(
      appBar: AppBar(
        title: const Text("Mes propositions"),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      // Bouton flottant pour créer une nouvelle proposition
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Get.to(() => const CreateProposalScreen());
        },
        backgroundColor: Theme.of(context).colorScheme.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: Obx(() {
        // État de chargement
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        // État liste vide
        if (controller.proposals.isEmpty) {
          return const Center(
            child: Text("Aucune proposition pour le moment."),
          );
        }

        // Liste des propositions
        return RefreshIndicator(
          onRefresh: () async => controller.fetchProposals(),
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: controller.proposals.length,
            itemBuilder: (context, index) {
              final req = controller.proposals[index];
              return _buildProposalCard(req);
            },
          ),
        );
      }),
    );
  }

  Widget _buildProposalCard(RecipeRequest req) {
    // 1. Gestion de la couleur et du texte du statut
    Color statusColor = Colors.grey;
    String statusText = req.status ?? "Inconnu";
    
    if (statusText == 'approved') {
      statusColor = Colors.green;
      statusText = "Approuvée";
    } else if (statusText == 'rejected') {
      statusColor = Colors.red;
      statusText = "Rejetée";
    } else {
      statusColor = Colors.orange;
      statusText = "En attente";
    }

    // 2. Gestion de l'URL de l'image
    String? imageUrl;
    if (req.imageUrl != null && req.imageUrl!.isNotEmpty) {
      if (req.imageUrl!.startsWith('http')) {
        imageUrl = req.imageUrl;
      } else {
        // Construction de l'URL complète avec la constante
        if (req.imageUrl!.startsWith('/')) {
           imageUrl = "${Constants.apiBaseUrl}${req.imageUrl!.substring(1)}";
        } else {
           imageUrl = "${Constants.apiBaseUrl}/${req.imageUrl!}";
        }
      }
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          // Navigation vers le détail avec l'ID pour recharger les données
          if (req.id != null) {
            Get.to(() => RecipeProposalDetailScreen(requestId: req.id!));
          }
        },
        child: Column(
          children: [
            // Image avec Badge de statut
            Stack(
              children: [
                Container(
                  height: 150,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                    color: Colors.grey[200],
                    image: imageUrl != null 
                      ? DecorationImage(image: NetworkImage(imageUrl), fit: BoxFit.cover)
                      : null,
                  ),
                  child: imageUrl == null 
                      ? const Icon(Icons.image, size: 50, color: Colors.grey) 
                      : null,
                ),
                Positioned(
                  top: 10,
                  right: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: statusColor,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      statusText.toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white, 
                        fontSize: 12, 
                        fontWeight: FontWeight.bold
                      ),
                    ),
                  ),
                ),
              ],
            ),
            // Informations textuelles
            ListTile(
              title: Text(
                req.title ?? "Sans titre", 
                style: const TextStyle(fontWeight: FontWeight.bold)
              ),
              subtitle: Text("Temps de prép: ${req.preparationTime ?? 0} min"),
              trailing: const Icon(Icons.chevron_right),
            ),
          ],
        ),
      ),
    );
  }
}