// Emulation of Flutter classes
class BuildContext {
  final Theme theme;

  BuildContext({required this.theme});
}

class Theme {
  static Theme of(BuildContext context) {
    return context.theme;
  }

  final Map<Object, ThemeExtension<dynamic>> extensions;

  Theme({required List<ThemeExtension<dynamic>> extensions})
      : extensions = {
          for (final ext in extensions) ext.runtimeType: ext,
        };

  T? extension<T extends ThemeExtension<T>>() {
    return extensions[T] as T?;
  }
}

abstract class ThemeExtension<T> {
  ThemeExtension<T> lerp(covariant ThemeExtension<T>? other, double t);
}
