import 'package:test_upcoming_macros/hello.dart';

@Hello()
class Foo {}

void main() {
  Foo().greet();
}
