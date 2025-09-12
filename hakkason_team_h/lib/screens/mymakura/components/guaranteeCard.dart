import 'package:flutter/material.dart';

class GuaranteeCard extends StatelessWidget {
  final String text;

  const GuaranteeCard({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 300,
      child: Card(
        color: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Center(
            child: Text(
              text,
            ),
          ),
        ),
      ),
    );
  }
}
