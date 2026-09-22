import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';
import 'core/theme/system_ui.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemUi.enableEdgeToEdge();
  runApp(const ProviderScope(child: EnfoldApp()));
}
