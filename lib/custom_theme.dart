import 'package:macros/macros.dart';

macro class CustomTheme implements ClassDeclarationsMacro {
  const CustomTheme();

  @override
  Future<void> buildDeclarationsForClass(
      ClassDeclaration clazz, MemberDeclarationBuilder context) async {
    await Future.wait([
      const AutoConstructor().buildDeclarationsForClass(clazz, context),
      const CopyWith().buildDeclarationsForClass(clazz, context),
      const ThemeExtensionOf().buildDeclarationsForClass(clazz, context),
      const Lerp().buildDeclarationsForClass(clazz, context),
    ]);
  }
}

macro class ThemeExtensionOf implements ClassDeclarationsMacro {
  const ThemeExtensionOf();

  @override
  Future<void> buildDeclarationsForClass(ClassDeclaration clazz,
      MemberDeclarationBuilder builder) async {
    // ignore: deprecated_member_use
    final flutterThemeIdentifier = await builder.resolveIdentifier(
        Uri.parse('package:test_upcoming_macros/build_context.dart'),
        'Theme');
    // ignore: deprecated_member_use
    final buildContextIdentifier = await builder.resolveIdentifier(
        Uri.parse('package:test_upcoming_macros/build_context.dart'),
        'BuildContext');

    builder.declareInType(DeclarationCode.fromParts([
      'static ',
      clazz.identifier,
      '? of(',
      buildContextIdentifier,
      ' context) {',
      'return ',
      flutterThemeIdentifier,
      '.of(context).extension<',
      clazz.identifier,
      '>();',
      '}'
    ]));
  }
}

double? lerpDouble(num? a, num? b, double t) {
  if (a == b || (a?.isNaN ?? false) && (b?.isNaN ?? false)) {
    return a?.toDouble();
  }
  a ??= 0.0;
  b ??= 0.0;
  return a * (1.0 - t) + b * t;
}

macro class Lerp implements ClassDeclarationsMacro {
  const Lerp();

  @override
  Future<void> buildDeclarationsForClass(ClassDeclaration clazz,
      MemberDeclarationBuilder builder) async {
    final doubleIdentifier = await
    // ignore: deprecated_member_use
      builder.resolveIdentifier(Uri.parse('dart:core'), 'double');
    final lerpDoubleIdentifier = await
    // ignore: deprecated_member_use
      builder.resolveIdentifier(Uri.parse('package:test_upcoming_macros/custom_theme.dart'), 'lerpDouble');

    var params = <Object>[];
    var fields = await builder.fieldsOf(clazz);
    if (fields.isNotEmpty) {
      for (var field in fields) {
        params.addAll([
          '${field.identifier.name}: ',
          lerpDoubleIdentifier,
          '(',
          field.identifier.name,
          ', other?.',
          field.identifier.name,
          ', t),',
        ]);
      }
    }

    final parts = [
      // '@override\n',
      clazz.identifier.name,
      ' lerp(',
      clazz.identifier.name,
      '? other, ',
      doubleIdentifier,
    ' t) {\n',
      'if (other is! ',
      clazz.identifier.name,
      ') return this;\n',
      'return ',
      clazz.identifier,
      '(\n',
        for (final p in params)
          p,
      ');\n',
      '\n}'
    ];
    builder.declareInType(DeclarationCode.fromParts(parts));
  }
}


macro class AutoConstructor implements ClassDeclarationsMacro {
  const AutoConstructor();

  @override
  Future<void> buildDeclarationsForClass(
      ClassDeclaration clazz, MemberDeclarationBuilder builder) async {
    var constructors = await builder.constructorsOf(clazz);
    if (constructors.any((c) => c.identifier.name == '')) {
      throw ArgumentError(
          'Cannot generate an unnamed constructor because one already exists');
    }

    var params = <Object>[];
    // Add all the fields of `declaration` as named parameters.
    var fields = await builder.fieldsOf(clazz);
    if (fields.isNotEmpty) {
      for (var field in fields) {
        var requiredKeyword = field.type.isNullable ? '' : 'required ';
        params.addAll(['\n$requiredKeyword', 'this.${field.identifier.name}', ',']);
      }
    }

    // The object type from dart:core.
    // var objectType = await builder.resolve(NamedTypeAnnotationCode(
    //     name:
    //     // ignore: deprecated_member_use
    //     await builder.resolveIdentifier(Uri.parse('dart:core'), 'Object')));

    // Add all super constructor parameters as named parameters.
    // var superclass = clazz.superclass == null
    //     ? null
    //     : await builder.typeDeclarationOf(clazz.superclass!.identifier);
    // var superType = superclass == null
    //     ? null
    //     : await builder
    //     .resolve(NamedTypeAnnotationCode(name: superclass.identifier));
    // MethodDeclaration? superconstructor;
    // if (superType != null && (await superType.isExactly(objectType)) == false) {
    //   superconstructor = (await builder.constructorsOf(superclass!))
    //       .firstWhereOrNull((c) => c.identifier.name == '');
    //   if (superconstructor == null) {
    //     throw ArgumentError(
    //         'Super class $superclass of $clazz does not have an unnamed '
    //             'constructor');
    //   }
    //   // We convert positional parameters in the super constructor to named
    //   // parameters in this constructor.
    //   for (var param in superconstructor.positionalParameters) {
    //     var requiredKeyword = param.isRequired ? 'required' : '';
    //     params.addAll([
    //       '\n$requiredKeyword',
    //       param.type.code,
    //       ' ${param.identifier.name},',
    //     ]);
    //   }
    //   for (var param in superconstructor.namedParameters) {
    //     var requiredKeyword = param.isRequired ? 'required ' : '';
    //     params.addAll([
    //       '\n$requiredKeyword',
    //       param.type.code,
    //       ' ${param.identifier.name},',
    //     ]);
    //   }
    // }

    bool hasParams = params.isNotEmpty;
    List<Object> parts = [
      // Don't use the identifier here because it should just be the raw name.
      clazz.identifier.name,
      '(',
      if (hasParams) '{',
      ...params,
      if (hasParams) '}',
      ')',
    ];
    // if (superconstructor != null) {
    //   parts.addAll([' : super(']);
    //   for (var param in superconstructor.positionalParameters) {
    //     parts.add('\n${param.identifier.name},');
    //   }
    //   if (superconstructor.namedParameters.isNotEmpty) {
    //     for (var param in superconstructor.namedParameters) {
    //       parts.add('\n${param.identifier.name}: ${param.identifier.name},');
    //     }
    //   }
    //   parts.add(')');
    // }
    parts.add(';');

    builder.declareInType(DeclarationCode.fromParts(parts));
  }
}

macro class CopyWith implements ClassDeclarationsMacro {
  const CopyWith();

  @override
  Future<void> buildDeclarationsForClass(
      ClassDeclaration clazz, MemberDeclarationBuilder builder) async {
    var methods = await builder.methodsOf(clazz);
    if (methods.any((c) => c.identifier.name == 'copyWith')) {
      throw ArgumentError(
          'Cannot generate a copyWith method because one already exists');
    }
    var allFields = await clazz.allFields(builder).toList();
    var namedParams = [
      for (var field in allFields)
        ParameterCode(
            name: field.identifier.name,
            type: field.type.code.asNullable,
            keywords: const [],
            defaultValue: null),
    ];
    var args = [
      for (var field in allFields)
        RawCode.fromParts([
          '${field.identifier.name}: ${field.identifier.name} ?? ',
          field.identifier,
        ]),
    ];
    var hasParams = namedParams.isNotEmpty;
    builder.declareInType(DeclarationCode.fromParts([
      clazz.identifier,
      ' copyWith(',
      if (hasParams) '{',
      ...namedParams.joinAsCode(', '),
      if (hasParams) '}',
      ')',
      // TODO: We assume this constructor exists, but should check
      '=> ', clazz.identifier, '(',
      ...args.joinAsCode(', '),
      ');',
    ]));
  }
}

extension _AllFields on ClassDeclaration {
  // Returns all fields from all super classes.
  Stream<FieldDeclaration> allFields(
      DeclarationPhaseIntrospector introspector) async* {
    for (var field in await introspector.fieldsOf(this)) {
      yield field;
    }
    var next = superclass != null
        ? await introspector.typeDeclarationOf(superclass!.identifier)
        : null;
    // TODO: Compare against actual Object identifer once we provide a way to get it.
    while (next is ClassDeclaration && next.identifier.name != 'Object') {
      for (var field in await introspector.fieldsOf(next)) {
        yield field;
      }
      next = next.superclass != null
          ? await introspector.typeDeclarationOf(next.superclass!.identifier)
          : null;
    }
  }
}

extension _<T> on Iterable<T> {
  T? firstWhereOrNull(bool Function(T element) test) {
    for (var item in this) {
      if (test(item)) return item;
    }
    return null;
  }
}