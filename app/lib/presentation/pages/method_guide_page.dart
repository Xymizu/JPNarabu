import 'package:flutter/material.dart';

import '../widgets/method_guide_view.dart';

class MethodGuidePage extends StatelessWidget {
  const MethodGuidePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cara belajar')),
      body: const SafeArea(child: MethodGuideView()),
    );
  }
}
