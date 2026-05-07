import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../widgets/glass_card.dart';

class ComparisonScreen extends StatefulWidget {
  const ComparisonScreen({super.key});

  @override
  State<ComparisonScreen> createState() => _ComparisonScreenState();
}

class _ComparisonScreenState extends State<ComparisonScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Weather Analytics', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: Stack(
        children: [
          Positioned(
            bottom: 0,
            left: 0,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                color: Colors.indigoAccent.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: TabBar(
                    controller: _tabController,
                    indicator: BoxDecoration(
                      color: Colors.blueAccent,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    indicatorSize: TabBarIndicatorSize.tab,
                    dividerColor: Colors.transparent,
                    labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                    unselectedLabelColor: Colors.white38,
                    tabs: const [
                      Tab(text: 'HOURLY'),
                      Tab(text: '7 DAYS'),
                      Tab(text: '30 DAYS'),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildTrendTab('Hourly Temperature', _generateHourlyData()),
                      _buildTrendTab('7-Day Forecast', _generate7DayData()),
                      _buildTrendTab('30-Day Outlook (Estimated)', _generate30DayData()),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrendTab(String title, List<FlSpot> data) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const Text('Average Variance: ±2.5°C', style: TextStyle(fontSize: 12, color: Colors.white38)),
              ],
            ),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: Colors.blueAccent.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
              child: const Icon(LucideIcons.trendingUp, size: 20, color: Colors.blueAccent),
            ),
          ],
        ),
        const SizedBox(height: 32),
        Expanded(
          flex: 2,
          child: GlassCard(
            padding: const EdgeInsets.all(24),
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (value) => FlLine(color: Colors.white12, strokeWidth: 1),
                ),
                titlesData: FlTitlesData(show: false),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: data,
                    isCurved: true,
                    gradient: const LinearGradient(colors: [Colors.blueAccent, Colors.cyanAccent]),
                    barWidth: 4,
                    isStrokeCapRound: true,
                    dotData: FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.blueAccent.withOpacity(0.3), Colors.transparent],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 24),
        const Text('METRIC COMPARISON', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 2, color: Colors.white24)),
        const SizedBox(height: 16),
        Expanded(
          child: GridView.count(
            crossAxisCount: 2,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            childAspectRatio: 2.5,
            children: [
              _buildSimpleStat('Humidity', '64%', LucideIcons.droplets, Colors.purpleAccent),
              _buildSimpleStat('Pressure', '1012', LucideIcons.thermometer, Colors.greenAccent),
              _buildSimpleStat('Wind', '12 km/h', LucideIcons.wind, Colors.blueAccent),
              _buildSimpleStat('UV Index', '2.4', LucideIcons.sun, Colors.orangeAccent),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSimpleStat(String label, String value, IconData icon, Color color) {
    return GlassCard(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 12),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(fontSize: 10, color: Colors.white38, fontWeight: FontWeight.bold)),
              Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
            ],
          ),
        ],
      ),
    );
  }

  List<FlSpot> _generateHourlyData() {
    return [
      FlSpot(0, 18), FlSpot(1, 19), FlSpot(2, 17), FlSpot(3, 20),
      FlSpot(4, 22), FlSpot(5, 25), FlSpot(6, 24), FlSpot(7, 23),
    ];
  }

  List<FlSpot> _generate7DayData() {
    return [
      FlSpot(0, 22), FlSpot(1, 25), FlSpot(2, 23), FlSpot(3, 27),
      FlSpot(4, 26), FlSpot(5, 28), FlSpot(6, 24),
    ];
  }

  List<FlSpot> _generate30DayData() {
    return [
      FlSpot(0, 20), FlSpot(5, 22), FlSpot(10, 19), FlSpot(15, 25),
      FlSpot(20, 24), FlSpot(25, 22), FlSpot(30, 21),
    ];
  }
}
