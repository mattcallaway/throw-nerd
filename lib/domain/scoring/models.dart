enum Multiplier { single, double, triple }

class Dart {
  final int value; // 0-20, 25 (outer bull), 50 (bullseye) - Wait, usually we store base value 1-20, 25 and multiplier
  final int multiplier; // 1, 2, 3

  const Dart({required this.value, required this.multiplier});

  int get total => value * multiplier;
  
  bool get isDouble => multiplier == 2;
  bool get isTriple => multiplier == 3;
  bool get isMiss => value == 0;
  bool get isBull => value == 25; // 25*1 or 25*2 (50)

  @override
  String toString() {
    if (value == 0) return 'MISS';
    if (value == 25) return multiplier == 2 ? 'DB' : 'B';
    String prefix = '';
    if (multiplier == 2) prefix = 'D';
    if (multiplier == 3) prefix = 'T';
    return '$prefix$value';
  }

  // Equatable logic
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Dart &&
          runtimeType == other.runtimeType &&
          value == other.value &&
          multiplier == other.multiplier;

  @override
  int get hashCode => value.hashCode ^ multiplier.hashCode;
}

class Turn {
  final String playerId;
  final List<Dart> darts;
  final int? legIndex;
  final int? setIndex;
  final int? roundIndex;
  
  const Turn({
    required this.playerId, 
    required this.darts,
    this.legIndex,
    this.setIndex,
    this.roundIndex,
  });

  int get totalScore => darts.fold(0, (sum, dart) => sum + dart.total);

  Turn copyWith({String? playerId, List<Dart>? darts, int? legIndex, int? setIndex, int? roundIndex}) {
    return Turn(
      playerId: playerId ?? this.playerId,
      darts: darts ?? this.darts,
      legIndex: legIndex ?? this.legIndex,
      setIndex: setIndex ?? this.setIndex,
      roundIndex: roundIndex ?? this.roundIndex,
    );
  }
}

enum GameType {
  x01,
  cricket,
  blank,
}

enum X01Mode {
  game301,
  game501,
}

class GameConfig {
  final GameType type;
  final X01Mode? x01Mode;
  final bool doubleIn;
  final bool doubleOut;
  final bool masterOut; // Double or Triple out
  final bool cutThroatCricket;
  final int legs;
  final int sets;

  const GameConfig({
    required this.type,
    this.x01Mode,
    this.doubleIn = false,
    this.doubleOut = true,
    this.masterOut = false,
    this.cutThroatCricket = false,
    this.legs = 1,
    this.sets = 1,
  });

  String get summary {
    if (type == GameType.x01) {
       String mode = x01Mode == X01Mode.game301 ? '301' : '501';
       List<String> opts = [];
       if (doubleIn) opts.add('DI');
       if (doubleOut) opts.add('DO');
       if (masterOut) opts.add('MO');
       return '$mode ${opts.join('/')}';
    } else if (type == GameType.cricket) {
       return 'Cricket${cutThroatCricket ? ' (Cut-Throat)' : ''}';
    }
    return 'Darts Match';
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type.name,
      'x01Mode': x01Mode?.name,
      'doubleIn': doubleIn,
      'doubleOut': doubleOut,
      'masterOut': masterOut,
      'cutThroatCricket': cutThroatCricket,
      'legs': legs,
      'sets': sets,
    };
  }

  factory GameConfig.fromJson(Map<String, dynamic> json) {
    return GameConfig(
      type: GameType.values.byName(json['type']),
      x01Mode: json['x01Mode'] != null ? X01Mode.values.byName(json['x01Mode']) : null,
      doubleIn: json['doubleIn'] ?? false,
      doubleOut: json['doubleOut'] ?? (json['type'] == 'x01'), // Default true for x01?
      masterOut: json['masterOut'] ?? false,
      cutThroatCricket: json['cutThroatCricket'] ?? false,
      legs: json['legs'] ?? 1,
      sets: json['sets'] ?? 1,
    );
  }
}
