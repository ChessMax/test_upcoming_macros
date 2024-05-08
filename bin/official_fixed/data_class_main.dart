import 'package:test_upcoming_macros/official_fixed/data_class.dart';

void main() {
  var joe = User(age: 25, name: 'Joe', username: 'joe1234');
  print(joe);

  var phoenix = joe.copyWith(name: 'Phoenix', age: 23);
  print(phoenix);

  var joe2 = joe.copyWith();
  print('Is equal: ${joe == joe2}');
  print('Is identical: ${identical(joe, joe2)}');
}

@DataClass()
class User {
  final int age;
  final String name;
  final String username;
}

@DataClass()
class Manager extends User {
  final List<User> reports;
}
