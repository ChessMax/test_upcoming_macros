import 'package:macros/macros.dart';

macro class Hello implements ClassDeclarationsMacro {
  const Hello();

  @override
  void buildDeclarationsForClass(
    ClassDeclaration clazz,
    MemberDeclarationBuilder builder,
  ) {
    builder.declareInType(
      DeclarationCode.fromString('''
      void greet() {
        print('Hello, World!');
      }
      '''),
    );
  }
}
