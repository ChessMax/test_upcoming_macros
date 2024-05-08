import 'dart:async';
import 'util.dart';
import 'package:macros/macros.dart';

macro class Route implements ClassDeclarationsMacro, MethodDefinitionMacro {
  final String path;
  final String? returnType;

  const Route({required this.path, this.returnType});

  @override
  Future<void> buildDeclarationsForClass(
      ClassDeclaration clazz,
      MemberDeclarationBuilder builder,) async {
    final (requiredFields, optionalFields) = await _getFields(builder, clazz);

    validateParameters(path, requiredFields, optionalFields);

    final className = clazz.identifier.name;
    final classNameWithoutPostfix =
    className.substring(0, className.indexOf('Screen'));

    final createConstructor = requiredFields.isNotEmpty || optionalFields.isNotEmpty ?
      (await builder.constructorsOf(clazz)).isEmpty :
      false;
    final constructorParams = <Object>[];

    final args = <Object>[];
    final defaultArgs = <Object>[];
    final buildRouteParams = <Object>[];
    final buildRouteExtensionParams = <Object>[];

    for (final f in requiredFields) {
      final name = f.identifier.name;
      args.add('required ');
      args.add(f.type.code);
      args.add(' ');
      args.add(name);
      args.add(',\n');

      buildRouteParams.add('  \'$name\' : $name,\n');
      buildRouteExtensionParams.add('$name : $name, ');

      if (createConstructor) {
        var requiredKeyword = f.type.isNullable ? '' : 'required ';
        constructorParams.addAll(['\n$requiredKeyword', 'this.$name', ',']);
      }
    }

    for (final f in optionalFields) {
      final name = f.identifier.name;
      defaultArgs.add(f.type.code);
      defaultArgs.add(' ');
      defaultArgs.add(name);
      defaultArgs.add(',\n');

      buildRouteParams.add('  \'$name\' : $name,\n');
      buildRouteExtensionParams.add('$name : $name, ');

      if (createConstructor) {
        var requiredKeyword = f.type.isNullable ? '' : 'required ';
        constructorParams.addAll(['\n$requiredKeyword', 'this.$name', ',']);
      }
    }

    final navigatorId = await builder.getCurrentId('Navigator');
    final buildRouteId = await builder.getCurrentId('buildRoute');

    final extensionName = '${classNameWithoutPostfix}Extension';

    var returnType = this.returnType ?? 'void';
    // TODO: how to get void identifier?
    final rtCode = returnType != 'void' ?
      (await builder.getCoreId(returnType)).toCode() :
      RawTypeAnnotationCode.fromString('void');
    final nullableRtCode = returnType != 'void' ? rtCode.asNullable : rtCode;
    final futureRtCode = await builder.getFutureCode([nullableRtCode]);

    // build push method
    final extensionParts = DeclarationCode.fromParts([
      'extension $extensionName on ', navigatorId, ' {\n',
      '  ', futureRtCode,' push$classNameWithoutPostfix(',
      if (args.isNotEmpty || defaultArgs.isNotEmpty)
        '{\n',
      ...args,
      ...defaultArgs,
      if (args.isNotEmpty || defaultArgs.isNotEmpty)
        '}', ') {\n',
      'return ', clazz.identifier, '.push$classNameWithoutPostfix(',
      '  this, ', ...buildRouteExtensionParams,
      '\n);',
      '  }\n',
      '}'
    ]);

    // print(extensionParts.debugString());
    builder.declareInLibrary(extensionParts);

    final route = await builder.getCurrentId('Route');
    final buildContextId = await builder.getCurrentId('BuildContext');
    final statelessWidgetId = await builder.getCurrentId('StatelessWidget');

    final stringId = await builder.getStringId();
    final objectId = await builder.getObjectId();

    // build pop and buildRoute methods
    final classParts = [
      'augment class $className {\n',
      RawCode.fromString(''' void greet() {} '''),
      'static const path = \'$path\';\n',
      if (createConstructor) ...[className, '({', ...constructorParams, '});\n'],
      '@', route, '(path: \'$path\', returnType: \'${this.returnType}\')\n',
      'external static ',
      statelessWidgetId, '?',
      ' build${classNameWithoutPostfix}Route(', stringId, ' route, [', objectId.toNullableCode(), ' args]);\n',
      '\n',
      ...(returnType != 'void'
          ? ['  void pop(', buildContextId, ' context, [', nullableRtCode, ' result]']
          : ['  void pop(', buildContextId, ' context, ',]),
      ') {\n',
      ...(returnType != 'void'
          ? ['    context.navigator.pop<', rtCode, '>(result);\n']
          : ['    context.navigator.pop<void>();\n']),
      '  }\n\n',
      'static ', futureRtCode, ' push$classNameWithoutPostfix(',
      navigatorId, ' navigator, ',
      if (args.isNotEmpty || defaultArgs.isNotEmpty)
        '{\n',
      ...args,
      ...defaultArgs,
      if (args.isNotEmpty || defaultArgs.isNotEmpty)
        '}',') async {\n',
      '  final route = ', buildRouteId, '(\'$path\'',
      if (buildRouteParams.isNotEmpty) ', {\n',
      ...buildRouteParams,
      if (buildRouteParams.isNotEmpty) '});\n' else ');\n',
      '\n  return navigator.push<', rtCode, '>(route);\n',
      '}',
      '}',
    ];

    // print(DeclarationCode.fromParts(classParts).debugString());
    builder.declareInLibrary(DeclarationCode.fromParts(classParts));
  }

  @override
  Future<void> buildDefinitionForMethod(MethodDeclaration method,
      FunctionDefinitionBuilder builder) async {
    final clazz = await builder.declarationOf(method.definingType) as ClassDeclaration;
    final (requiredFields, optionalFields) = await _getFields(builder, clazz);
    final fields = requiredFields + optionalFields;

    final className = method.definingType.name;
    final parseLines = <Object>[];
    final createWidgetArgs = <Object>[];

    final intType = await builder.getIntType();
    final boolType = await builder.getBoolType();
    final doubleType = await builder.getDoubleType();
    final stringType = await builder.getStringType();

    final requiredParamsIndices = getRouteIndices(path);
    int getRequiredParamIndex(String name) {
      final index = requiredParamsIndices[name];
      if (index != null) return index;
      generateError('Required route param `$name` not found');
    }

    for (final f in fields) {
      var t = f.type;
      if (t is OmittedTypeAnnotation) {
        t = await builder.inferType(t);
      }

      final type = await builder.resolve(t.code.asNonNullable);

      List<Object> parseStart;
      List<Object> parseEnd;

      if (await type.isExactly(intType) ||
          await type.isExactly(boolType) ||
          await type.isExactly(doubleType)) {
        parseStart = [f.type.code, '.parse('];
        parseEnd = [')'];
      } else if (await type.isExactly(stringType)) {
        parseStart = [];
        parseEnd = [];
      } else {
        generateError('Unsupported path type: ${(t as NamedTypeAnnotation).identifier.name} of ${f.identifier.name} field');
      }

      parseLines.add('\nfinal ${f.identifier.name} = ');
      if (!f.type.isNullable) {
        final index = getRequiredParamIndex(f.identifier.name);
        parseLines.addAll(parseStart);
        parseLines.add('uri.pathSegments[$index]');
        parseLines.addAll(parseEnd);
      } else {
        parseLines.add('uri.queryParameters[\'${f.identifier.name}\'] != null ? ');
        parseLines.addAll(parseStart);
        parseLines.add('uri.queryParameters[\'${f.identifier.name}\']!');
        parseLines.addAll(parseEnd);
        parseLines.add(' : null');
      }
      parseLines.add(';\n');
      createWidgetArgs.add('${f.identifier.name}: ${f.identifier.name}, ');
    }

    final uriId = await builder.getUriId();
    final isRouteMatch = await builder.getCurrentId('isRouteMatch');

    final methodParts = FunctionBodyCode.fromParts(['{\n',
      'if (!', isRouteMatch, '(\'$path\', route)) return null;\n',
      if (parseLines.isNotEmpty)
        '\n  final uri = ', uriId, '.parse(route);',
      ...parseLines,
      '\n return $className(',
      ...createWidgetArgs,
      ');',
      '\n}',
    ]);

    // print('${method.identifier.name}: ${methodParts.debugString()}');
    builder.augment(methodParts);
  }

  Future<(List<FieldDeclaration>, List<FieldDeclaration>)> _getFields(
      DeclarationPhaseIntrospector builder, TypeDeclaration clazz,
  ) async {
    final requiredFields = <FieldDeclaration>[];
    final optionalFields = <FieldDeclaration>[];
    final fields = await builder.fieldsOf(clazz);

    for (final field in fields) {
      if (field.hasFinal && !field.hasStatic && !field.hasInitializer) {
        if (!field.type.code.isNullable) {
          requiredFields.add(field);
        } else {
          optionalFields.add(field);
        }
      }
    }

    return (requiredFields, optionalFields);
  }
}

typedef RouteFactory = StatelessWidget Function(String route, [Object? arguments]);

class MaterialApp {
  final Navigator navigator;

  MaterialApp({required RouteFactory onGenerateRoute}) :
        navigator = Navigator(onGenerateRoute: onGenerateRoute);

  BuildContext get context => navigator.context;
}

class BuildContext {
  late final Navigator navigator;

  BuildContext(this.navigator);
}

class Button extends StatelessWidget {
  final void Function()? onPressed;

  Button({required this.onPressed}) {
    // Simulate user click
    Future<void>.delayed(const Duration(milliseconds: 50)).then((_) {
      onPressed?.call();
    });
  }

  @override
  StatelessWidget build(BuildContext context) {
    return this;
  }
}

class Widget {
  Widget();
}

abstract class StatelessWidget extends Widget {
  StatelessWidget();

  Widget build(BuildContext context);
}

class Navigator {
  late final BuildContext context = BuildContext(this);
  final RouteFactory onGenerateRoute;

  Navigator({required this.onGenerateRoute});

  final List<(StatelessWidget, Completer<dynamic>)> _stack = [];

  Future<T?> push<T>(String route, [Object? args]) async {
    print('Navigator.push $route');

    final page = onGenerateRoute(route, args);
    page.build(context);
    final completer = Completer<T>();
    _stack.add((page, completer));

    return completer.future;
  }

  void pop<T>([T? result]) {
    print('Navigator.pop $result');
    final (_, completer) = _stack.removeLast();
    completer.complete(result);
  }
}

bool isRouteMatch(String template, String route) {
  final templateUri = Uri.parse(template);
  final routeUri = Uri.parse(route);

  final templatePathSegments = templateUri.pathSegments;
  final routePathSegments = routeUri.pathSegments;

  for (var i = 0; i < templatePathSegments.length; ++i) {
    final templateSegment = templatePathSegments[i];
    final routeSegment =
    i < routePathSegments.length ? routePathSegments[i] : null;
    if (routeSegment == null || routeSegment == '') {
      return false;
    }
    if (!templateSegment.startsWith(":") && templateSegment != routeSegment) {
      return false;
    }
  }

  return true;
}

void validateParameters(String template,
    List<FieldDeclaration> requiredFields,
    List<FieldDeclaration> optionalFields,
) {
  final templateUri = Uri.parse(template);

  final templatePathSegments = templateUri.pathSegments;
  final List<String> requiredParams = [];
  final List<String> optionalParams = [];

  for (var i = 0; i < templatePathSegments.length; ++i) {
    final templateSegment = templatePathSegments[i];
    if (templateSegment.startsWith(":")) {
      final name = templateSegment.substring(1);
      if (!requiredFields.any((p) => p.identifier.name == name)) {
        generateError('Required path parameter `$name` not found');
      }

      requiredParams.add(name);
    }
  }

  final templateQueryParameters = templateUri.queryParameters;

  for (final entry in templateQueryParameters.entries) {
    final value = entry.value;

    if (value.startsWith(":")) {
      final name = value.substring(1);
      if (!optionalFields.any((p) => p.identifier.name == name)) {
        generateError('Optional path parameter `$name` not found');
      }
      optionalParams.add(name);
    }
  }

  for (final f in requiredFields) {
    final name = f.identifier.name;
    if (!requiredParams.contains(name) && !optionalParams.contains(name)) {
      generateError('Unexpected constructor parameter found `$name`');
    }
  }

  for (final f in optionalFields) {
    final name = f.identifier.name;
    if (!requiredParams.contains(name) && !optionalParams.contains(name)) {
      generateError('Unexpected constructor parameter found `$name`');
    }
  }
}

String buildRoute(String url, [Map<String, dynamic> params = const {}]) {
  final uri = Uri.parse(url);
  final pathSegments = <String>[];
  for (final pathSegment in uri.pathSegments) {
    if (pathSegment.startsWith(':')) {
      final pathParameter = params[pathSegment.substring(1)];
      if (pathParameter == null) {
        generateError('Expected path parameter $pathSegment not found.');
      }
      pathSegments.add(pathParameter.toString());
    } else {
      pathSegments.add(pathSegment);
    }
  }
  final queryParameters = <String, String>{};
  for (final queryParameter in uri.queryParameters.entries) {
    final key = queryParameter.key;
    final value = queryParameter.value;

    if (value.startsWith(':')) {
      final queryParameter = params[value.substring(1)];
      if (queryParameter != null) {
        queryParameters[key] = queryParameter.toString();
      }
    } else {
      queryParameters[key] = value;
    }
  }

  final result = Uri(
    pathSegments: pathSegments,
    queryParameters: queryParameters.isNotEmpty ? queryParameters : null,
  );
  return uri.path.startsWith('/') ? '/${result.toString()}' : result.toString();
}

Map<String, int> getRouteIndices(String url) {
  final result = <String, int>{};

  final uri = Uri.parse(url);
  for (var i = 0; i < uri.pathSegments.length; ++i) {
    final pathSegment = uri.pathSegments[i];
    if (pathSegment.startsWith(':')) {
      result[pathSegment.substring(1)] = i;
    }
  }
  return result;
}

Never generateError(String message) {
  print(message);
  throw ArgumentError(message);
}

final _dartCoreUri = Uri.parse('dart:core');
final _dartAsyncUri = Uri.parse('dart:async');
final _currentUri = Uri.parse('package:test_upcoming_macros/route.dart');

extension IdentifierExtension on Identifier {
  NamedTypeAnnotationCode toCode([List<TypeAnnotationCode> typeArguments = const []]) =>
    NamedTypeAnnotationCode(name: this, typeArguments: typeArguments);
  NullableTypeAnnotationCode toNullableCode([List<TypeAnnotationCode> typeArguments = const []]) =>
    NullableTypeAnnotationCode(toCode(typeArguments));
}

extension MacroTypePhaseIntrospectionExtension on TypePhaseIntrospector {
  Future<Identifier> resolveId(Uri uri, String name) async {
    // ignore: deprecated_member_use
    final id = await resolveIdentifier(uri, name);
    return id;
  }

  Future<Identifier> getCoreId(String name) => resolveId(_dartCoreUri, name);
  Future<Identifier> getAsyncId(String name) => resolveId(_dartAsyncUri, name);
  Future<Identifier> getCurrentId(String name) => resolveId(_currentUri, name);

  Future<Identifier> getIntId() => getCoreId('int');
  Future<Identifier> getBoolId() => getCoreId('bool');
  Future<Identifier> getDoubleId() => getCoreId('double');
  Future<Identifier> getUriId() => getCoreId('Uri');
  Future<Identifier> getObjectId() => getCoreId('Object');
  Future<Identifier> getStringId() => getCoreId('String');
  Future<Identifier> getFutureId() => getAsyncId('Future');
}

extension MacroDeclarationPhaseIntrospectionExtension on DeclarationPhaseIntrospector {
  Future<StaticType> getTypeById(Identifier id, [List<TypeAnnotationCode> typeArguments = const []]) =>
      resolve(id.toCode(typeArguments));

  Future<StaticType> getIntType() async => getTypeById(await getIntId());
  Future<StaticType> getBoolType() async => getTypeById(await getBoolId());
  Future<StaticType> getDoubleType() async => getTypeById(await getDoubleId());
  Future<StaticType> getStringType() async => getTypeById(await getStringId());

  Future<NamedTypeAnnotationCode> getFutureCode([List<TypeAnnotationCode> typeArguments = const []]) async =>
      (await getFutureId()).toCode(typeArguments);
}