augment library 'models.dart';

augment Person fromJson(dynamic json) {
  print('models_json fromJson');
  return Person(json['name']);
} 

augment class Person {
  dynamic toJson() {
    return {
      'name': name,
    };
  }
}