import 'package:flutter/material.dart';

class GridItem extends StatelessWidget {
  final String title;
  final String image;
  final VoidCallback onTap;

  const GridItem({
    required this.title,
    required this.image,
    required this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.blue.shade100,
          border: Border.all(color: Colors.blue, width: 2),
          borderRadius: BorderRadius.circular(8),
        ),
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Image.asset(
              image,
              height: 60,
              fit: BoxFit.contain,
            ),
          ],
        ),
      ),
    );
  }
}
