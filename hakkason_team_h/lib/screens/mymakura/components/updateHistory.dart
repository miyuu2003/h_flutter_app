import 'package:flutter/material.dart';

class UpdateHistory extends StatelessWidget {
  final String title;
  final List<String> entries;

  const UpdateHistory({
    super.key,
    required this.title,
    this.entries = const ['7/25 枕の高さ調整', '7/30 枕の高さ調整'],
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 300,
      height: 400,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Center(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          // エントリを区切り線付きで表示
          for (int i = 0; i < entries.length; i++) ...[
            Text(entries[i]),
            if (i != entries.length - 1)
              const Divider(thickness: 1, indent: 20, endIndent: 20),
          ],
        ],
      ),
    );
  }
}
