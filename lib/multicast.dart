import 'dart:async';

import 'package:macros/macros.dart';

macro class Multicast implements ClassTypesMacro {
  const Multicast();

  @override
  Future<void> buildTypesForClass(ClassDeclaration clazz,
      ClassTypeBuilder builder,) async {
    final name = '${clazz.identifier.name}Multicast';

    // ignore: deprecated_member_use
    var multicast = await builder.resolveIdentifier(
        Uri.parse('package:test_upcoming_macros/multicast.dart'), 'MulticastMethod');

    final parts = [
      '@',
      multicast,
      '()',
      '\nclass $name implements ${clazz.identifier.name} {\n',
      'final List<',
      clazz.identifier,
      '> _delegates;\n',
      '$name(this._delegates);',
      '\n}',
    ];

    builder.declareType(name, DeclarationCode.fromParts(parts));
  }
}

macro class MulticastMethod implements ClassDeclarationsMacro {
  const MulticastMethod();

  @override
  Future<void> buildDeclarationsForClass(ClassDeclaration clazz,
      MemberDeclarationBuilder builder,) async {
    // TODO: should be a better way
    final delegateIdentifier = clazz.interfaces.first.identifier;
    final delegateType = await builder.typeDeclarationOf(delegateIdentifier);
    final methods = await builder.methodsOf(delegateType);

    for (final method in methods) {
      final args = <Object>[];
      final params = <Object>[];
      for (final p in method.positionalParameters) {
          params.add(p.code);
          params.add(', ');
          args.add(p.identifier.name);
          args.add(', ');
      }

      final namedParams = <Object>[];
      for (final p in method.namedParameters) {
        namedParams.add(p.code);
        namedParams.add(', ');
        args.add('${p.identifier.name}:${p.identifier.name}');
        args.add(', ');
      }

      final parts = [
        method.returnType.code,
        ' ',
        method.identifier.name,
        '(',
        ...params,
        if (namedParams.isNotEmpty)
          '{',
        if (namedParams.isNotEmpty)
          ...namedParams,
        if (namedParams.isNotEmpty)
          '}',
        ') {\n',
        ' for (final delegate in _delegates) {\n',
        '   delegate.${method.identifier.name}(\n',
        ...args,
        '\n);',
        ' }\n',
        '}',
      ];

      builder.declareInType(DeclarationCode.fromParts(parts));
    }
  }
}