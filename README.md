Small collection of Dart macros - a new upcoming feature. Source code for my [article](https://chessmax.ru/posts/upcoming-dart-macros.html) or [here](https://habr.com/ru/articles/815527/).

**DISCLAIMER**: All code in this package is experimental and should be treated as such. The examples are unstable and may or may not work at any given time, depending on the implementation status.

# SDK setup

Download Dart SDK 3.5.0-69.0.dev from [here](https://dart.dev/get-dart/archive).
Open project in Idea or VSCode. Apply pub get command and run examples.

To run the same examples from command line you need to specify `--enable-experiment=macros` feature flag.
Example `dart --enable-experiment=macros bin/hello_main.dart`.

## Additional info

- official_fixed folder contains some of the [official examples](https://github.com/dart-lang/language/tree/main/working/macros/example)
"fixed" to be able to run them;
- www folder contains examples found in the internet;
- *_gen.dart files contain generated code for some applied macros.
