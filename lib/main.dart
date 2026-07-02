import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/services/api_client.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await apiClient.init();
  runApp(
    const ProviderScope(
      child: RecommReadApp(),
    ),
  );
}
