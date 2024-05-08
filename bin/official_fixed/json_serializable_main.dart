import 'dart:math';

import 'package:test_upcoming_macros/official_fixed/json_serializable.dart';

void main() {
  var rand = Random();
  var rogerJson = {
    'age': rand.nextInt(100),
    'name': 'Roger',
    'username': 'roger1337'
  };

  final user = User.fromJson(rogerJson);

  print(user.age);
  print(user.toJson());
}

@JsonSerializable()
class User {
  final int age;
  final String name;
  final String username;

  User({required this.age, required this.name, required this.username});
}
