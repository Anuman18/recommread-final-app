import 'package:flutter/material.dart';
import '../navigation/main_shell.dart';

class ProfileStub extends StatelessWidget {
  const ProfileStub({super.key});

  @override
  Widget build(BuildContext context) => const ComingSoonStub(
        title: 'Profile',
        emoji: '👤',
        subtitle: 'Your reading stats, goals\nand achievements.',
        gradientColors: [Color(0xFFBF360C), Color(0xFFE64A19)],
      );
}
