import 'dart:math';
import 'package:flutter/material.dart';
import '../database/db_helper.dart';
import '../models/game_model.dart';

class GameProvider extends ChangeNotifier {
  int targetNumber = 0;
  int attempts = 0;
  int maxAttempts = 5;

  String message = "Start Guessing!";
  bool isGameOver = false;
  bool isWin = false;

  bool isDarkMode = false;

  String difficulty = "Easy";

  List<GameModel> history = [];

  GameProvider() {
    startNewGame();
    loadHistory();
  }

  // 🎯 Start New Game
  void startNewGame() {
    targetNumber = Random().nextInt(100) + 1;
    attempts = 0;
    isGameOver = false;
    isWin = false;
    message = "Guess a number between 1 - 100";
    notifyListeners();
  }

  // 🎮 Difficulty System
  void setDifficulty(String level) {
    difficulty = level;

    if (level == "Easy") maxAttempts = 10;
    if (level == "Medium") maxAttempts = 7;
    if (level == "Hard") maxAttempts = 5;

    startNewGame();
  }

  // 🌙 Theme Toggle
  void toggleTheme() {
    isDarkMode = !isDarkMode;
    notifyListeners();
  }

  // 🎯 MAIN GAME LOGIC (FIXED + CLEAN)
  Future<void> makeGuess(int guess) async {
    if (isGameOver) return;

    attempts++;

    // 🎯 Core Logic (FIXED)
    if (guess == targetNumber) {
      message = "Correct 🎉 You Won!";
      isWin = true;
      isGameOver = true;
    } else if (guess > targetNumber) {
      message = "Too High 🔴 Try Smaller Number";
    } else {
      message = "Too Low 🔵 Try Bigger Number";
    }

    // ❌ Lose Condition
    if (attempts >= maxAttempts && !isWin) {
      isGameOver = true;
      message = "Game Over 😢 The number was $targetNumber";
    }

    // 💾 Save to SQLite (ONLY meaningful result stored)
    await DBHelper.instance.insertGame(
      GameModel(
        guess: guess,
        result: message,
        difficulty: difficulty,
        attempts: attempts,
        time: DateTime.now().toString(),
      ),
    );

    // 📜 Refresh History
    await loadHistory();

    notifyListeners();
  }

  // 📜 Load History (FIXED)
  Future<void> loadHistory() async {
    history = await DBHelper.instance.getAllGames();
    notifyListeners();
  }

  // 🗑 Clear All History
  Future<void> clearHistory() async {
    await DBHelper.instance.deleteAll();
    history.clear();
    notifyListeners();
  }
}