import 'dart:async';

import 'package:drift/drift.dart';
import 'package:google_fonts/google_fonts.dart';

Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  GoogleFonts.config.allowRuntimeFetching = false;
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  await testMain();
}