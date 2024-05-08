import 'package:test_upcoming_macros/models.dart';

void main() {
  Person p = Person('Ivan');
  print(p.toJson());

  print(fromJson({'name': 'Peter'}).name);
}
