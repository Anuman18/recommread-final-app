import 'package:flutter/material.dart';
import '../navigation/main_shell.dart';

class AiCoachStub extends StatelessWidget {
  const AiCoachStub({super.key});

  @override
  Widget build(BuildContext context) => const ComingSoonStub(
        title: 'AI Coach',
        emoji: '🤖',
        subtitle: 'Your personal AI reading coach.\nGet smart insights and guidance.',
        gradientColors: [Color(0xFF4527A0), Color(0xFF6A1B9A)],
      );
}
