import augment 'models_json.dart';

Person fromJson(dynamic json) {
  print('models fromJson');
  return Person(json['name']);
}

class Person {
  final String name;

  Person(this.name);
}
