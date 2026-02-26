import 'dart:io'; // Nécessaire pour File (Mobile)
import 'package:flutter/foundation.dart'; // Nécessaire pour kIsWeb
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:recipe_app/controllers/proposal_controller.dart';

class CreateProposalScreen extends StatefulWidget {
  const CreateProposalScreen({super.key});

  @override
  State<CreateProposalScreen> createState() => _CreateProposalScreenState();
}

class _CreateProposalScreenState extends State<CreateProposalScreen> {
  final ProposalController controller = Get.find<ProposalController>();

  final _titleController = TextEditingController();
  final _timeController = TextEditingController();
  
  final _ingNameController = TextEditingController();
  final _ingQtyController = TextEditingController();
  final _ingMeasureController = TextEditingController();
  
  final _stepNameController = TextEditingController();
  final _stepDescController = TextEditingController();
  final _stepDurationController = TextEditingController();

  final _tagController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Proposer une recette"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Informations générales", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: "Titre de la recette", border: OutlineInputBorder()),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _timeController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: "Temps de préparation (min)", border: OutlineInputBorder()),
            ),
            
            const SizedBox(height: 20),

            // --- PREVIEW IMAGE (Compatible Web & Mobile) ---
            const Text("Image de la recette", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            GestureDetector(
              onTap: controller.pickImage,
              child: Obx(() {
                if (controller.selectedImage.value != null) {
                  return Container(
                    height: 200,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: Colors.grey[200],
                    ),
                    // Affichage conditionnel Web vs Mobile
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: kIsWeb 
                        ? Image.network(
                            controller.selectedImage.value!.path, // Blob URL sur le Web
                            fit: BoxFit.cover,
                          )
                        : Image.file(
                            File(controller.selectedImage.value!.path), // File Path sur Mobile
                            fit: BoxFit.cover,
                          ),
                    ),
                  );
                }
                return Container(
                  height: 150,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.grey),
                  ),
                  child: const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.camera_alt, size: 40, color: Colors.grey),
                      Text("Appuyer pour choisir une image"),
                    ],
                  ),
                );
              }),
            ),

            const SizedBox(height: 20),
            const Divider(),

            const Text("Ingrédients", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(child: TextField(controller: _ingNameController, decoration: const InputDecoration(hintText: "Nom"))),
                const SizedBox(width: 5),
                SizedBox(width: 60, child: TextField(controller: _ingQtyController, keyboardType: TextInputType.number, decoration: const InputDecoration(hintText: "Qté"))),
                const SizedBox(width: 5),
                SizedBox(width: 60, child: TextField(controller: _ingMeasureController, decoration: const InputDecoration(hintText: "Unit"))),
                IconButton(
                  icon: const Icon(Icons.add_circle, color: Colors.green),
                  onPressed: () {
                    controller.addIngredient(_ingNameController.text, _ingQtyController.text, _ingMeasureController.text);
                    _ingNameController.clear(); _ingQtyController.clear(); _ingMeasureController.clear();
                  },
                )
              ],
            ),
            Obx(() => Column(
              children: controller.formIngredients.asMap().entries.map((entry) {
                int idx = entry.key;
                var ing = entry.value;
                return ListTile(
                  dense: true,
                  title: Text("${ing['name']} (${ing['quantity']} ${ing['measure']})"),
                  trailing: IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: () => controller.removeIngredient(idx)),
                );
              }).toList(),
            )),

            const SizedBox(height: 20),
            const Divider(),

            const Text("Étapes", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            TextField(controller: _stepNameController, decoration: const InputDecoration(labelText: "Titre étape")),
            const SizedBox(height: 5),
            TextField(controller: _stepDescController, decoration: const InputDecoration(labelText: "Description"), maxLines: 2),
            const SizedBox(height: 5),
            Row(
              children: [
                Expanded(child: TextField(controller: _stepDurationController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: "Durée (min)"))),
                IconButton(
                  icon: const Icon(Icons.add_circle, color: Colors.green),
                  onPressed: () {
                    controller.addStep(_stepNameController.text, _stepDescController.text, _stepDurationController.text);
                    _stepNameController.clear(); _stepDescController.clear(); _stepDurationController.clear();
                  },
                )
              ],
            ),
            Obx(() => Column(
              children: controller.formSteps.asMap().entries.map((entry) {
                int idx = entry.key;
                var step = entry.value;
                return ListTile(
                  dense: true,
                  title: Text("${step['name']} (${step['duration']} min)"),
                  subtitle: Text(step['description']),
                  trailing: IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: () => controller.removeStep(idx)),
                );
              }).toList(),
            )),

            const SizedBox(height: 20),
            const Divider(),

            const Text("Tags", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Row(
              children: [
                Expanded(child: TextField(controller: _tagController, decoration: const InputDecoration(hintText: "Nouveau tag"))),
                IconButton(
                  icon: const Icon(Icons.add_circle, color: Colors.green),
                  onPressed: () {
                    controller.addTag(_tagController.text);
                    _tagController.clear();
                  },
                )
              ],
            ),
            Obx(() => Wrap(
              spacing: 8,
              children: controller.formTags.map((tag) => Chip(
                label: Text(tag),
                onDeleted: () => controller.removeTag(tag),
              )).toList(),
            )),

            const SizedBox(height: 40),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: Obx(() => ElevatedButton(
                onPressed: controller.isSubmitting.value 
                  ? null 
                  : () async {
                      bool success = await controller.submitProposal(_titleController.text, _timeController.text);
                      if (success) {
                         Get.back();
                      }
                    },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Colors.white,
                ),
                child: controller.isSubmitting.value 
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text("Envoyer la proposition"),
              )),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}