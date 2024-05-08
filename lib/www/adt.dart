import 'package:macros/macros.dart';

macro class ADT implements ClassDeclarationsMacro {
  const ADT();

  @override
  Future<void> buildDeclarationsForClass(
      ClassDeclaration clazz,
      MemberDeclarationBuilder builder,
      ) async {
    String uc(String name) => name[1].toUpperCase() + name.substring(2);

    final constrs = await builder.constructorsOf(clazz);

    for (final cnstr in constrs) {
      final name = cnstr.identifier.name;
      if (!name.startsWith('_')) continue;
      builder.declareInLibrary(DeclarationCode.fromParts([
        'class ${uc(name)} extends ${clazz.identifier.name} {',
        'const ${uc(name)}(',
        for (final p in cnstr.positionalParameters) 'this.${p.name},',
        ');',
        for (final p in cnstr.positionalParameters) ...[
          'final ',
          p.type.code,
          ' ${p.name};',
        ],
        '}',
      ]));
    }
  }
}