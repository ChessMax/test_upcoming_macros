import 'package:test_upcoming_macros/assets.dart';

@Assets('assets')
class A {}

void main() {
  print(A.locale_en);
  print(A.locale_ru);
}
