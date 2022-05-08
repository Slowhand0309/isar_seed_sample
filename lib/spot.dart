import 'package:isar/isar.dart';

part 'spot.g.dart';

@Collection()
class Spot {
  int? id;

  @Index()
  late String name;

  late double longitude;

  late double latitude;

  late DateTime createdAt;

  late DateTime updatedAt;
}
