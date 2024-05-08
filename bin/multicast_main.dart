import 'package:test_upcoming_macros/multicast.dart';

@Multicast()
abstract interface class Delegate {
  void onPress(int a);

  void onSave(String path, double content);

  // ... other methods
}

class FirstDelegate implements Delegate {
  @override
  void onPress(int a) => print('First onPress: $a');

  @override
  void onSave(String path, double content) =>
      print('First onSave: $path, $content');
}

class SecondDelegate implements Delegate {
  @override
  void onPress(int a) => print('Second onPress: $a');

  @override
  void onSave(String path, double content) =>
      print('Second onSave: $path, $content');
}

void main() {
  Delegate d = DelegateMulticast([
    FirstDelegate(),
    SecondDelegate(),
  ]);

  d.onPress(5);
  d.onSave('settings.txt', 5.0);
}
