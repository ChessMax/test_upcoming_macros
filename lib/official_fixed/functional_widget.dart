import 'package:macros/macros.dart';

class Key {
  const Key();
}

class BuildContext {
  BuildContext();
}

class Widget {
  final Key? key;
  const Widget({this.key});
}

abstract class StatelessWidget extends Widget {
  const StatelessWidget({super.key});

  Widget build(BuildContext context);
}

class SizedBox extends Widget {
  final double width;

  SizedBox({this.width = 0, super.key});
}

/// A macro that annotates a function, which becomes the build method for a
/// generated stateless widget.
///
/// The function must have at least one positional parameter, which is of type
/// BuildContext (and this must be the first parameter).
///
/// Any additional function parameters are turned into fields on the stateless
/// widget.
macro class FunctionalWidget implements FunctionTypesMacro {
  final Identifier? widgetIdentifier;

  const FunctionalWidget(
      {
      // Defaults to removing the leading `_` from the function name and calling
      // `toUpperCase` on the next character.
      this.widgetIdentifier});

  @override
  Future<void> buildTypesForFunction(
      FunctionDeclaration function, TypeBuilder builder) async {
    // if (!function.identifier.name.startsWith('_')) {
    //   throw ArgumentError(
    //       'FunctionalWidget should only be used on private declarations');
    // }
    if (function.positionalParameters.isEmpty ||
        // TODO: A proper type check here.
        (function.positionalParameters.first.type as NamedTypeAnnotation)
                .identifier
                .name !=
            'BuildContext') {
      throw ArgumentError(
          'FunctionalWidget functions must have a BuildContext argument as the '
          'first positional argument');
    }

    var widgetName = widgetIdentifier?.name ??
        function.identifier.name
            .replaceRange(0, 1, function.identifier.name[0].toUpperCase());
    var positionalFieldParams = function.positionalParameters.skip(1);
    // ignore: deprecated_member_use
    var statelessWidget = await builder.resolveIdentifier(
        Uri.parse('package:test_upcoming_macros/official_fixed/functional_widget.dart'), 'StatelessWidget');
    // ignore: deprecated_member_use
    var buildContext = await builder.resolveIdentifier(
        Uri.parse('package:test_upcoming_macros/official_fixed/functional_widget.dart'), 'BuildContext');
    // ignore: deprecated_member_use
    var widget = await builder.resolveIdentifier(
        Uri.parse('package:test_upcoming_macros/official_fixed/functional_widget.dart'), 'Widget');
    // ignore: deprecated_member_use
    final override = await builder.resolveIdentifier(
        Uri.parse('dart:core'), 'override');

    builder.declareType(
        widgetName,
        DeclarationCode.fromParts([
          'class $widgetName extends ', statelessWidget, ' {',
          // Fields
          for (var param
              in positionalFieldParams.followedBy(function.namedParameters))
            DeclarationCode.fromParts([
              'final ',
              param.type.code,
              ' ',
              param.identifier.name,
              ';',
            ]),
          // Constructor
          'const $widgetName(',
          for (var param in positionalFieldParams)
            'this.${param.identifier.name}, ',
          '{',
          for (var param in function.namedParameters)
            '${param.isRequired ? 'required ' : ''}this.${param.identifier.name}, ',
          'super.key,',
          '});',
          // Build method
          '@',
          override,
          ' ',
          widget,
          ' build(',
          buildContext,
          ' context) => ',
          function.identifier,
          '(context, ',
          for (var param in positionalFieldParams) '${param.identifier.name}, ',
          for (var param in function.namedParameters)
            '${param.identifier.name}: ${param.identifier.name}, ',
          ');',
          '}',
        ]));
  }
}
