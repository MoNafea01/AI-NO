import 'package:flutter/material.dart';

class DocsScreen extends StatelessWidget {
  // Renamed from Projects as per sidebar label
  const DocsScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return const Center(
        child: Text('Docs Screen Content', style: TextStyle(fontSize: 30)));
  }
}
