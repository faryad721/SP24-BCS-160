import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/game_provider.dart';

class StatsScreen extends StatelessWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final history = Provider.of<GameProvider>(context).history;

    int wins = history.where((e) => e.result.contains("Correct")).length;
    int losses = history.length - wins;

    return Scaffold(
      appBar: AppBar(title: const Text("📊 Stats")),
      body: Center(
        child: PieChart(
          PieChartData(
            sections: [
              PieChartSectionData(
                value: wins.toDouble(),
                title: "Win",
              ),
              PieChartSectionData(
                value: losses.toDouble(),
                title: "Lose",
              ),
            ],
          ),
        ),
      ),
    );
  }
}