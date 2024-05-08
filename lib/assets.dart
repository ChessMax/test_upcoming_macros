import 'dart:convert';
import 'dart:io';

import 'package:macros/macros.dart';

macro class Assets implements ClassDeclarationsMacro {
  const Assets(this.dir);

  final String dir;

  @override
  Future<void> buildDeclarationsForClass(
      ClassDeclaration clazz,
      MemberDeclarationBuilder builder,
  ) async {
    await for (final file in Directory('./$dir/').list()) {
      if (file is! File) continue;

      final path = file.path;
      final (name, ext) = parse(path.split('/').last);

      builder.declareInType(DeclarationCode.fromString(
        'static const $name = \'$path\';',
      ));

      if (ext == 'json') {
        _validateJson(file);
      }
      // TODO: support other types
    }
  }

  Future<void> _validateJson(File file) async {
    try {
      final text = await file.readAsString();
      jsonDecode(text);
    } catch (e) {
      throw StateError('Only valid json resources are supported');
    }
  }

  static (String name, String ext) parse(String fullName) {
    final i = fullName.lastIndexOf('.');
    final name = i == -1 ? fullName : fullName.substring(0, i);
    final ext = i == -1 ? '' : fullName.substring(i + 1);
    return (name, ext);
  }
}