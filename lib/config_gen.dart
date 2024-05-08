augment library 'file:///C:/Projects/test_upcoming_macros/bin/config_main.dart';

import 'dart:io' as prefix0;
import 'dart:convert' as prefix1;

augment class AppConfig {
  final String version;
  final int build;
  final bool debugOptions;
  final double price;

  AppConfig(this.version, this.build, this.debugOptions, this.price,);

  factory AppConfig.fromJson(Map<String, dynamic> json) {
    return AppConfig(
      json['version'] as String,
      json['build'] as int,
      json['debugOptions'] as bool,
      json['price'] as double,
    );
  }
  static late AppConfig instance;

  static Future<void> initialize() async {
    prefix0.File file = prefix0.File('./assets/config.json');
    final text = await file.readAsString();
    final json = prefix1.jsonDecode(text);
    instance = AppConfig.fromJson(json);
  }
}