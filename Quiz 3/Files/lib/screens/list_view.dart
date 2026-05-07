import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../models/submission.dart';

class RecordsListView extends StatefulWidget {
  final Function(Submission) onEdit;
  const RecordsListView({super.key, required this.onEdit});

  @override
  State<RecordsListView> createState() => _RecordsListViewState();
}

class _RecordsListViewState extends State<RecordsListView> {
  int _refreshKey = 0;

  Future<List<Map<String, dynamic>>> _fetchItems() async {
    final res = await Supabase.instance.client.from('submissions').select().order('created_at');
    // Supabase returns List<dynamic>; cast to List<Map<String, dynamic>> when possible
    if (res is List) return List<Map<String, dynamic>>.from(res.cast<Map<String, dynamic>>());
    return <Map<String, dynamic>>[];
  }

  Future<bool> _delete(String id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirm Deletion'),
        content: const Text('Are you sure you want to remove this record?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Delete', style: TextStyle(color: Colors.red))),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await Supabase.instance.client.from('submissions').delete().eq('id', id);
        return true;
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Delete failed: $e')));
        return false;
      }
    }
    return false;
  }

  Future<void> _handleDelete(String? id) async {
    if (id == null) return;
    final ok = await _delete(id);
    if (ok) {
      setState(() => _refreshKey++);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Record deleted')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('OUTPUT VIEW', style: TextStyle(color: Color(0xFF0EA5E9), letterSpacing: 3, fontWeight: FontWeight.w900, fontSize: 9)),
              const SizedBox(height: 4),
              Row(
                children: [
                  const Text('Stored Records', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, letterSpacing: -0.5)),
                  const Spacer(),
                  IconButton(
                    onPressed: () => setState(() => _refreshKey++),
                    icon: const Icon(LucideIcons.refreshCw, size: 16, color: Colors.grey),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ],
          ),
        ),
        Expanded(
          child: FutureBuilder<List<Map<String, dynamic>>>(
            future: _fetchItems(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator(strokeWidth: 2));
              }
              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(child: Text('NO DATA IN CACHE.', style: TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1)));
              }

              final items = snapshot.data!.map((m) => Submission.fromMap(m)).toList();

              return ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final item = items[index];
                  return Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      border: Border(bottom: BorderSide(color: Colors.grey.shade800, width: 0.5)),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.fullName, 
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFFE2E8F0)),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 2),
                              Text(
                                item.email.toLowerCase(), 
                                style: TextStyle(color: Colors.lightBlue.shade400.withOpacity(0.8), fontSize: 10, fontFamily: 'Monospace'),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Icon(LucideIcons.phone, size: 10, color: Colors.grey.shade600),
                                  const SizedBox(width: 4),
                                  Text(item.phoneNumber, style: TextStyle(color: Colors.grey.shade600, fontSize: 10, fontFamily: 'Monospace')),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                              decoration: BoxDecoration(
                                color: item.gender == 'Male' ? Colors.blue.withOpacity(0.08) : Colors.pink.withOpacity(0.08),
                                borderRadius: BorderRadius.circular(4),
                                border: Border.all(color: (item.gender == 'Male' ? Colors.blue : Colors.pink).withOpacity(0.2)),
                              ),
                              child: Text(
                                item.gender.toUpperCase(), 
                                style: TextStyle(fontSize: 8, fontWeight: FontWeight.w900, color: item.gender == 'Male' ? Colors.blue.shade400 : Colors.pink.shade400, letterSpacing: 0.5)
                              ),
                            ),
                            const SizedBox(height: 6),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                _buildActionBtn(LucideIcons.edit, Colors.lightBlue, () => widget.onEdit(item)),
                                const SizedBox(width: 8),
                                _buildActionBtn(LucideIcons.trash2, Colors.pinkAccent, () => _handleDelete(item.id)),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildActionBtn(IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Icon(icon, size: 12, color: color),
      ),
    );
  }
}
