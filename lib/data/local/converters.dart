import 'dart:convert';
import 'package:drift/drift.dart';
import '../../domain/scoring/models.dart';

class DartsConverter extends TypeConverter<List<Dart>, String> {
  const DartsConverter();

  @override
  List<Dart> fromSql(String fromDb) {
    if (fromDb.isEmpty) return [];
    final List<dynamic> list = jsonDecode(fromDb);
    return list.map((item) {
      final map = item as Map<String, dynamic>;
      return Dart(
        value: map['v'] as int,
        multiplier: map['m'] as int,
      );
    }).toList();
  }

  @override
  String toSql(List<Dart> value) {
    final list = value.map((d) => {
      'v': d.value,
      'm': d.multiplier,
    }).toList();
    return jsonEncode(list);
  }
}

class GameTypeConverter extends TypeConverter<GameType, String> {
  const GameTypeConverter();
  
  @override
  GameType fromSql(String fromDb) => GameType.values.byName(fromDb);
  
  @override
  String toSql(GameType value) => value.name;
}
