import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';

class MyCoursesScreen extends StatelessWidget {
  const MyCoursesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Khóa học của tôi'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.shopping_bag, size: 80, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            Text('Tính năng đang được phát triển', style: TextStyle(fontSize: 18, color: Colors.grey.shade600)),
          ],
        ),
      ),
    );
  }
}
