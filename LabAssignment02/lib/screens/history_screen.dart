import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/game_provider.dart';
import '../widgets/history_tile.dart';
import 'stats_screen.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  void showDeleteDialog(BuildContext context, GameProvider provider) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Delete All Records?"),
        content: const Text("This action cannot be undone."),
        actions: [
          TextButton(
            child: const Text("Cancel"),
            onPressed: () => Navigator.pop(context),
          ),
          ElevatedButton(
            child: const Text("Delete"),
            onPressed: () {
              provider.clearHistory();
              Navigator.pop(context);

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("All records deleted")),
              );
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<GameProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Game History"),
        actions: [
          IconButton(
            icon: const Icon(Icons.bar_chart),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const StatsScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete_forever),
            onPressed: () => showDeleteDialog(context, provider),
          ),
        ],
      ),
      body: provider.history.isEmpty
          ? const Center(
              child: Text(
                "No Records Found",
                style: TextStyle(fontSize: 18),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: provider.history.length,
              itemBuilder: (context, index) {
                return HistoryTile(game: provider.history[index]);
              },
            ),
    );
  }
}