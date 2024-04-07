import 'package:hive/hive.dart';
part 'PersonModel.g.dart';

@HiveType(typeId: 1)
class PersonModel {
  @HiveField(0)
  String name;

  @HiveField(1)
  int age;

  PersonModel({required this.name, required this.age});
}
