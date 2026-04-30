class GameModel {
  final int? id;
  final int guess;
  final String result; // High / Low / Correct
  final String difficulty;
  final int attempts;
  final String time;

  GameModel({
    this.id,
    required this.guess,
    required this.result,
    required this.difficulty,
    required this.attempts,
    required this.time,
  });

  // 🔁 Convert to Map (for SQLite)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'guess': guess,
      'result': result,
      'difficulty': difficulty,
      'attempts': attempts,
      'time': time,
    };
  }

  // 🔁 Convert from Map
  factory GameModel.fromMap(Map<String, dynamic> map) {
    return GameModel(
      id: map['id'],
      guess: map['guess'],
      result: map['result'],
      difficulty: map['difficulty'],
      attempts: map['attempts'],
      time: map['time'],
    );
  }
}