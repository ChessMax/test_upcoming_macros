import 'package:test_upcoming_macros/official_fixed/observable.dart';

void main() {
  var jack = ObservableUser(age: 10, name: 'jack');
  jack.age = 12;
  jack.name = 'john';
}

class ObservableUser {
  @Observable()
  int _age;

  @Observable()
  String _name;

  ObservableUser({
    required int age,
    required String name,
  })  : _age = age,
        _name = name;
}
