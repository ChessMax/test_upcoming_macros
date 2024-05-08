import 'package:test_upcoming_macros/build_context.dart';
import 'package:test_upcoming_macros/custom_theme.dart';

@CustomTheme()
class ButtonTheme extends ThemeExtension<ButtonTheme> {
  final double? size;
}

void main() {
  final context = BuildContext(
    theme: Theme(extensions: [
      ButtonTheme(
        size: 10,
      ),
    ]),
  );

  final buttonTheme = ButtonTheme.of(context);
  print(buttonTheme?.size); // 10.0

  final buttonTheme2 = buttonTheme?.copyWith(size: 20);
  print(buttonTheme2?.size); // 20.0

  final lerpedTheme = buttonTheme?.lerp(buttonTheme2, .5);
  print(lerpedTheme?.size); // 15.0
}
