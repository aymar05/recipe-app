import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
      leading: GestureDetector(
          onTap: () {
            Scaffold.of(context).openDrawer();
          },
          child: const Icon(Icons.menu)),
      title: const Text("Recipe Book"),
      actions: [
        IconButton(
          icon: const Icon(Icons.person),
          onPressed: () {},
        ),
      ],
      centerTitle: true,
    ));
  }
}
