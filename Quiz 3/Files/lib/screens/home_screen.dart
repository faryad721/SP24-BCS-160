import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'form_view.dart';
import 'list_view.dart';
import '../models/submission.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  Submission? _editingSubmission;

  void _onEdit(Submission submission) {
    setState(() {
      _editingSubmission = submission;
      _currentIndex = 0; // Switch to Form
    });
  }

  void _clearEdit() {
    setState(() {
      _editingSubmission = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F172A).withOpacity(0.5),
        elevation: 0,
        title: LayoutBuilder(
          builder: (context, constraints) {
            bool isSmall = constraints.maxWidth < 300;
            return Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0EA5E9),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text('Q3', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 14)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'CSC303: Mobile App Dev', 
                        style: TextStyle(fontSize: isSmall ? 14 : 16, fontWeight: FontWeight.bold),
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        'QUIZ 3 // SUPABASE INTEGRATION', 
                        style: TextStyle(fontSize: 9, color: Colors.lightBlue.shade400, letterSpacing: 1.2),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: Colors.grey.shade800, height: 1),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: IndexedStack(
              index: _currentIndex,
              children: [
                FormView(
                  submission: _editingSubmission,
                  onSuccess: () {
                    setState(() {
                      _currentIndex = 1;
                      _editingSubmission = null;
                    });
                  },
                  onCancel: _clearEdit,
                ),
                RecordsListView(onEdit: _onEdit),
              ],
            ),
          ),
          // Footer Visualizer Area
          Container(
            height: 90,
            decoration: BoxDecoration(
              color: const Color(0xFF0F172A).withOpacity(0.5),
              border: Border(top: BorderSide(color: Colors.grey.shade800)),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('SUPABASE TRANSACTION LOAD', style: TextStyle(color: Colors.grey, fontSize: 8, fontWeight: FontWeight.bold, letterSpacing: 1)),
                      const SizedBox(height: 8),
                      Expanded(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [2, 4, 1, 6, 3, 5, 4, 8, 5, 2, 7, 3, 5, 6].map((h) => Expanded(
                            child: Container(
                              margin: const EdgeInsets.symmetric(horizontal: 1),
                              decoration: BoxDecoration(
                                color: h == 8 ? const Color(0xFF0EA5E9) : const Color(0xFF0EA5E9).withOpacity(0.3),
                                borderRadius: const BorderRadius.vertical(top: Radius.circular(2)),
                                boxShadow: h == 8 ? [const BoxShadow(color: Color(0xFF0EA5E9), blurRadius: 8)] : null,
                              ),
                              height: h * 5.0,
                            ),
                          )).toList(),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 24),
                Container(width: 1, color: Colors.grey.shade800, height: double.infinity),
                const SizedBox(width: 24),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildStat('TABLE_REF:', 'submissions'),
                    _buildStat('AUTH_MODE:', 'ANON_KEY', color: Colors.pinkAccent),
                    _buildStat('LATENCY:', '142ms', color: Colors.greenAccent),
                  ],
                ),
              ],
            ),
          ),
          // Status Bar
          Container(
            height: 24,
            color: const Color(0xFF020617),
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('SUPABASE_VERSION: v2.6.0', style: TextStyle(color: Colors.grey, fontSize: 8, fontFamily: 'Monospace')),
                Row(
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(color: Color(0xFF0EA5E9), shape: BoxShape.circle),
                    ),
                    const SizedBox(width: 6),
                    const Text('CLO-3 READY', style: TextStyle(color: Colors.grey, fontSize: 8, fontWeight: FontWeight.bold)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
            if (index == 1) _editingSubmission = null;
          });
        },
        backgroundColor: const Color(0xFF020617),
        selectedItemColor: const Color(0xFF0EA5E9),
        unselectedItemColor: Colors.grey.shade600,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(LucideIcons.plusCircle), label: 'Form'),
          BottomNavigationBarItem(icon: Icon(LucideIcons.list), label: 'Records'),
        ],
      ),
    );
  }

  Widget _buildStat(String label, String value, {Color color = const Color(0xFF0EA5E9)}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 8, fontFamily: 'Monospace')),
        const SizedBox(width: 8),
        Text(value, style: TextStyle(color: color, fontSize: 8, fontWeight: FontWeight.bold, fontFamily: 'Monospace')),
      ],
    );
  }
}
