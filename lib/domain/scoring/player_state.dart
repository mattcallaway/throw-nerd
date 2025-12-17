
abstract class PlayerGameScore {
  int get numericScore; // For X01: remaining points. For Cricket: accumulated points.
}

class X01PlayerScore extends PlayerGameScore {
  final int remaining;
  
  X01PlayerScore(this.remaining);
  
  @override
  int get numericScore => remaining;
}

class CricketPlayerScore extends PlayerGameScore {
  final int score;
  final Map<int, int> marks; // Target -> count (0-3+)
  // We track closure status separately or derive it.
  
  CricketPlayerScore({required this.score, required this.marks});
  
  @override
  int get numericScore => score;
}
