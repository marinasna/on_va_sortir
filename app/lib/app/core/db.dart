import 'dart:io' show Platform;
import 'package:pocketbase/pocketbase.dart';
import 'package:flutter/foundation.dart';

String _getPbUrl() {
  if (kIsWeb) return 'http://127.0.0.1:8090';
  try {
    if (Platform.isAndroid) return 'http://10.0.2.2:8090';
  } catch (e) {
    // web throws error on Platform
  }
  return 'http://127.0.0.1:8090';
}

final pb = PocketBase(_getPbUrl());
