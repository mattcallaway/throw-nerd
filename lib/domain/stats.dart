class PlayerStats {
  final String playerId;
  final int matchesPlayed;
  final int matchesWon;
  final int legsWon;
  
  // Averages (Double/Triple extraction requires parsing turns which is heavy)
  // For V1, let's stick to Win/Loss data.
  
  final int x01MatchesPlayed;
  final int x01MatchesWon;
  final int cricketMatchesPlayed;
  final int cricketMatchesWon;

  const PlayerStats({
    required this.playerId,
    required this.matchesPlayed,
    required this.matchesWon,
    required this.legsWon,
    this.x01MatchesPlayed = 0,
    this.x01MatchesWon = 0,
    this.cricketMatchesPlayed = 0,
    this.cricketMatchesWon = 0,
  });
  
  double get winRate => matchesPlayed == 0 ? 0.0 : (matchesWon / matchesPlayed);
  double get x01WinRate => x01MatchesPlayed == 0 ? 0.0 : (x01MatchesWon / x01MatchesPlayed);
  double get cricketWinRate => cricketMatchesPlayed == 0 ? 0.0 : (cricketMatchesWon / cricketMatchesPlayed);
}

class GlobalStats {
  final int totalMatches;
  final int totalLegsPlayed; // Maybe?
  final String? mostActivePlayerId;
  final String? bestWinRatePlayerId;
  
  const GlobalStats({
    this.totalMatches = 0,
    this.totalLegsPlayed = 0,
    this.mostActivePlayerId,
    this.bestWinRatePlayerId,
  });
}
