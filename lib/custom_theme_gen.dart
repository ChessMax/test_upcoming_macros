augment library 'file:///C:/Projects/test_upcoming_macros/bin/custom_theme_main.dart';

import 'file:///C:/Projects/test_upcoming_macros/bin/custom_theme_main.dart' as prefix0;
import 'package:test_upcoming_macros/build_context.dart' as prefix1;
import 'dart:core' as prefix2;
import 'package:test_upcoming_macros/custom_theme.dart' as prefix3;

augment class ButtonTheme {
  static prefix0.ButtonTheme? of(prefix1.BuildContext context) {
    return prefix1.Theme.of(context).extension<prefix0.ButtonTheme>();
  }

  ButtonTheme({this.size,});

  ButtonTheme lerp(ButtonTheme? other, prefix2.double t) {
    if (other is! ButtonTheme) return this;
    return prefix0.ButtonTheme(
      size: prefix3.lerpDouble(size, other?.size, t),
    );
  }

  prefix0.ButtonTheme copyWith({prefix2.double? size}) =>
      prefix0.ButtonTheme(size: size ?? this.size);
}
