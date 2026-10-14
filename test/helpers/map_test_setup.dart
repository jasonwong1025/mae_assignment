import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

/// flutter_map saves tiles in the app cache folder, which needs the
/// path_provider plugin. Tests have no plugins, so give it a temp folder.
void mockMapTileCache() {
  final folder = Directory.systemTemp.createTempSync('map_tiles');
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(
        const MethodChannel('plugins.flutter.io/path_provider'),
        (call) async => folder.path,
      );
}
