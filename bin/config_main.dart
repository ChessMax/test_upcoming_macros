import 'package:test_upcoming_macros/config.dart';

@Config('assets/config.json')
class AppConfig {}

void main() async {
  await AppConfig.initialize();

  print(AppConfig.instance.version);
  print(AppConfig.instance.build);
  print(AppConfig.instance.debugOptions);
  print(AppConfig.instance.price);
}
