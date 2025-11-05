import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // Fonction de connexion simulée (sans Firebase)
  void _handleLogin() {
    if (_formKey.currentState!.validate()) {
      // Simulation d'une tentative de connexion réussie.
      // Dans une application réelle, vous appelleriez ici un service
      // d'authentification local ou un API.
      
      // Simuler un petit délai pour l'expérience utilisateur
      Future.delayed(const Duration(milliseconds: 500), () {
        // Afficher un succès et naviguer
        Get.snackbar(
          "Succès", 
          "Connexion réussie (simulée)",
          backgroundColor: Colors.green,
          colorText: Colors.white
        );
        // Note: Assurez-vous que la route '/home' est définie dans Get.
        Get.toNamed('/home'); 
      });
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Arrière-plan (ImageAsset n'est pas inclus dans ce snippet,
          // mais le code de l'arrière-plan est conservé.)
          Container(
            height: MediaQuery.of(context).size.height,
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/register_bg.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          // Calque sombre
          Container(
            height: MediaQuery.of(context).size.height,
            color: Colors.black.withOpacity(0.5),
          ),
          // Contenu du formulaire
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            width: MediaQuery.of(context).size.width,
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    const SizedBox(height: 70),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              "Bienvenu sur",
                              style: TextStyle(
                                fontSize: 20,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Text(
                              "Recipe Book",
                              style: TextStyle(
                                fontSize: 32,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          width: 55,
                          height: 55,
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(55),
                          ),
                          // Image Asset (conservée mais non résolue sans le fichier)
                          child: Image.asset(
                            "assets/images/splash.png",
                            width: 52,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Column(
                      children: [
                        const SizedBox(height: 90),
                        // Champ Email
                        SizedBox(
                          height: 45,
                          child: TextFormField(
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            style: const TextStyle(color: Colors.white), // Ajouté pour la visibilité
                            validator: (value) {
                              if (value!.isEmpty) {
                                return "Veuillez entrer votre email."; // Message de validation mis à jour
                              }
                              return null;
                            },
                            decoration: const InputDecoration(
                              isDense: true,
                              hintText: "Email",
                              hintStyle: TextStyle(
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 28),
                        // Champ Mot de passe
                        SizedBox(
                          height: 45,
                          child: TextFormField(
                            controller: _passwordController,
                            obscureText: true, // Ajouté pour la sécurité
                            style: const TextStyle(color: Colors.white), // Ajouté pour la visibilité
                            validator: (value) {
                              if (value!.isEmpty) {
                                return "Veuillez entrer votre mot de passe."; // Message de validation mis à jour
                              }
                              return null;
                            },
                            decoration: const InputDecoration(
                              isDense: true,
                              hintText: "Mot de passe",
                              hintStyle: TextStyle(
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 28),
                        const Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text(
                              "Mot de passe oublié ?",
                              style: TextStyle(
                                color: Colors.white,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 28),
                        // Bouton de Connexion (Mise à jour pour appeler _handleLogin)
                        SizedBox(
                          height: 45,
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _handleLogin, // Appel de la fonction sans Firebase
                            style: ButtonStyle(
                              backgroundColor: WidgetStateProperty.all(
                                const Color.fromARGB(255, 231, 236, 233),
                              ),
                              shape: WidgetStateProperty.all(
                                RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            ),
                            child: const Text(
                              "Connexion",
                                style: TextStyle(color: Colors.black),
                              ),
                          ),
                        ),
                        const SizedBox(height: 28),
                        // Lien vers l'inscription
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              "Vous n'avez pas de compte ?",
                              style: TextStyle(color: Colors.white),
                            ),
                            const SizedBox(
                              width: 8,
                            ),
                            GestureDetector(
                              onTap: () {
                                Get.toNamed('/register'); 
                              },
                              child: const Text(
                                "S'inscrire",
                                style: TextStyle(
                                  color: Colors.white, 
                                  fontWeight: FontWeight.bold, // Rendu plus visible
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ),
                          ],
                        )
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
