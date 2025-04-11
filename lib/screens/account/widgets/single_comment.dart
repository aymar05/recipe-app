import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

class SingleComment extends StatelessWidget {
  const SingleComment({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.green,
                ),
                borderRadius: BorderRadius.circular(50),
              ),
              child: const Center(
                child: Text(
                  "K",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 15),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Kraaakilo"),
                const SizedBox(height: 5),
                RatingBar.builder(
                  initialRating: 1.5,
                  minRating: 1,
                  ignoreGestures: true,
                  itemSize: 18,
                  direction: Axis.horizontal,
                  allowHalfRating: true,
                  itemCount: 5,
                  itemBuilder: (context, _) => const Icon(
                    Icons.star,
                    color: Colors.amber,
                  ),
                  glow: false,
                  onRatingUpdate: (rating) {},
                ),
              ],
            )
          ],
        ),
        const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 4),
            Text(
              "J'ai adoré cette recette, je la referai sans hésiter !",
              style: TextStyle(
                fontSize: 13,
              ),
            ),
            Text(
              "il y a 2 jours",
              style: TextStyle(
                fontSize: 10,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
