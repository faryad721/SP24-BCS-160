import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/game_provider.dart';
import '../widgets/custom_button.dart';
import '../widgets/guess_card.dart';
import 'result_screen.dart';
import 'history_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<GameProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("🎯 Smart Guess Pro"),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const HistoryScreen(),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.dark_mode),
            onPressed: provider.toggleTheme,
          ),
        ],
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [

            // 🎯 Difficulty Dropdown
            DropdownButton<String>(
              value: provider.difficulty,
              isExpanded: true,
              items: ["Easy", "Medium", "Hard"]
                  .map((e) => DropdownMenuItem(
                        value: e,
                        child: Text(e),
                      ))
                  .toList(),
              onChanged: (value) {
                provider.setDifficulty(value!);
              },
            ),

            const SizedBox(height: 20),

            // 📊 Attempts
            Text(
              "Attempts: ${provider.attempts}/${provider.maxAttempts}",
              style: const TextStyle(fontSize: 18),
            ),

            const SizedBox(height: 10),

            // 📈 Progress Bar
            LinearProgressIndicator(
              value: provider.attempts / provider.maxAttempts,
              minHeight: 10,
            ),

            const SizedBox(height: 20),

            // 🎨 Guess Card
            GuessCard(
              child: Column(
                children: [
                  const Text(
                    "Enter Your Guess (1-100)",
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),

                  const SizedBox(height: 10),

                  TextField(
                    controller: controller,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // 🎯 Guess Button
            CustomButton(
              text: "Submit Guess",
              onPressed: () {
                if (controller.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Enter a number")),
                  );
                  return;
                }

                int guess = int.tryParse(controller.text) ?? 0;

                if (guess < 1 || guess > 100) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Enter between 1-100")),
                  );
                  return;
                }

                provider.makeGuess(guess);

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const ResultScreen(),
                  ),
                );

                controller.clear();
              },
            ),

            const SizedBox(height: 20),

            // 🔄 Restart Button
            CustomButton(
              text: "Restart Game",
              color: Colors.red,
              onPressed: provider.startNewGame,
            ),
          ],
        ),
      ),
    );
  }
}