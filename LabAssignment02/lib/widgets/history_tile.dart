import 'package:flutter/material.dart';
import '../models/game_model.dart';

class HistoryTile extends StatelessWidget {
  final GameModel game;

  const HistoryTile({super.key, required this.game});

  Color getColor(String result) {
    if (result.contains("Correct")) return Colors.green;
    if (result.contains("High")) return Colors.red;
    return Colors.blue;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 5,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: getColor(game.result),
          child: Text(
            game.guess.toString(),
            style: const TextStyle(color: Colors.white),
          ),
        ),
        title: Text(
          game.result,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          "Difficulty: ${game.difficulty}\nAttempts: ${game.attempts}\n${game.time}",
        ),
        isThreeLine: true,
      ),
    );
  }
}