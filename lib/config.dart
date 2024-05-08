import 'dart:convert';
import 'dart:io';

import 'package:macros/macros.dart';

macro class Config implements ClassDeclarationsMacro {
  final String path;

  const Config(this.path);

  Future<Map<String, dynamic>> _readJson() async {
    final file = File('./$path');

    if (!(await file.exists())) {
      throw ArgumentError('File at `$path` not found.');
    }

    try {
      final text = await file.readAsString();
      final json = jsonDecode(text);

      if (json is! Map<String, dynamic>) {
        throw StateError('Only object json is supported.');
      }
      return json;
    } catch (e) {
      throw ArgumentError('Only valid json resources are supported');
    }
  }

  @override
  Future<void> buildDeclarationsForClass(ClassDeclaration clazz,
      MemberDeclarationBuilder builder,) async {
    final json = await _readJson();

    final constructorArgs = <Object>[];
    final fromJsonArgs = <(Object, Object)>[];

    for (final entry in json.entries) {
      final key = entry.key;
      final value = entry.value;

      final type = switch (value) {
        String() => 'String',
        int() => 'int',
        bool() => 'bool',
        double() => 'double',
        _ => 'dynamic',
      };

      builder.declareInType(DeclarationCode.fromString(
          '''
          final $type $key;
          '''
      ));

      constructorArgs.add('this.$key, ');
      fromJsonArgs.add((type, key));
    }

    builder.declareInType(DeclarationCode.fromParts([
      clazz.identifier.name,
      '(',
      ...constructorArgs,
      ');'
    ]));

    builder.declareInType(DeclarationCode.fromParts([
      'factory ',
      clazz.identifier.name,
      '.fromJson(Map<String, dynamic> json) {',
      'return ${clazz.identifier.name}(',
        for (final (t, k) in fromJsonArgs)
          'json[\'$k\'] as $t, ',
      ');'

      '}',
    ]));

    // ignore: deprecated_member_use
    var fileId = await builder.resolveIdentifier(Uri.parse('dart:io'), 'File');

    // ignore: deprecated_member_use
    var jsonDecodeId = await builder.resolveIdentifier(Uri.parse('dart:convert'), 'jsonDecode');

    builder.declareInType(DeclarationCode.fromParts([
      '''
      static late ${clazz.identifier.name} instance;
      
      static Future<void> initialize() async { ''',
      fileId, ''' file = ''', fileId, '''('./$path');
        final text = await file.readAsString();
        final json = ''', jsonDecodeId, '''(text);
        instance = ${clazz.identifier.name}.fromJson(json);
      }  
      '''
    ]));
  }
}
