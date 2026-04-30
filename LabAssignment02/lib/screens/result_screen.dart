import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/game_provider.dart';
import '../widgets/custom_button.dart';

class ResultScreen extends StatefulWidget {
  const ResultScreen({super.key});

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  late ConfettiController _controller;

  @override
  void initState() {
    super.initState();
    _controller = ConfettiController(duration: const Duration(seconds: 2));

    final provider = Provider.of<GameProvider>(context, listen: false);

    if (provider.isWin) {
      _controller.play();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Color getStatusColor(String msg) {
    if (msg.contains("Correct")) return Colors.green;
    if (msg.contains("High")) return Colors.red;
    if (msg.contains("Low")) return Colors.blue;
    return Colors.grey;
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<GameProvider>(context);

    return Scaffold(
      appBar: AppBar(title: const Text("Game Result")),
      body: Stack(
        children: [
          Center(
            child: Container(
              width: 320,
              padding: const EdgeInsets.all(25),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(25),
                boxShadow: const [
                  BoxShadow(
                    blurRadius: 10,
                    color: Colors.black26,
                  )
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [

                  Icon(
                    provider.isWin ? Icons.celebration : Icons.close,
                    size: 70,
                    color: provider.isWin ? Colors.green : Colors.red,
                  ),

                  const SizedBox(height: 20),

                  Text(
                    provider.message,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: getStatusColor(provider.message),
                    ),
                  ),

                  const SizedBox(height: 15),

                  Text(
                    "Attempts: ${provider.attempts}/${provider.maxAttempts}",
                    style: const TextStyle(fontSize: 16),
                  ),

                  const SizedBox(height: 25),

                  CustomButton(
                    text: "Back to Game",
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
            ),
          ),

          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _controller,
              blastDirectionality: BlastDirectionality.explosive,
            ),
          ),
        ],
      ),
    );
  }
}