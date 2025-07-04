import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AchievementsScreen extends StatefulWidget {
  const AchievementsScreen({super.key});

  @override
  State<AchievementsScreen> createState() => _AchievementsScreenState();
}

class _AchievementsScreenState extends State<AchievementsScreen> {
  List<_Achievement> _achievements = [];

  @override
  void initState() {
    super.initState();
    _loadAchievements();
  }

  Future<void> _loadAchievements() async {
    final prefs = await SharedPreferences.getInstance();
    final rawList = prefs.getStringList('achievements') ?? [];
    final parsed = rawList.map((entry) {
      // entry format: "2025-03-14T10:34:23|Ask a stranger..."
      final parts = entry.split('|');
      final date = DateTime.parse(parts[0]);
      return _Achievement(
        dare: parts[1],
        date: date,
      );
    }).toList();

    setState(() => _achievements = parsed.reversed.toList());
  }

  String _formatDate(DateTime dt) {
    final y = dt.year;
    final m = dt.month.toString().padLeft(2, '0');
    final d = dt.day.toString().padLeft(2, '0');
    return '$y.$m.$d';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            children: [
              const Text(
                'Achievements',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 24),

              Expanded(
                child: _achievements.isEmpty
                    ? const Center(child: Text('No achievements yet.'))
                    : ListView.separated(
                        itemCount: _achievements.length,
                        separatorBuilder: (_, __) => const Divider(height: 32),
                        itemBuilder: (context, index) {
                          final a = _achievements[index];
                          return Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Text(
                                  a.dare,
                                  style: const TextStyle(
                                    fontSize: 18,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Text(
                                _formatDate(a.date),
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          );
                        },
                      ),
              ),

              const SizedBox(height: 16),

              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () {
                    // Back to home
                    Navigator.of(context).popUntil((route) => route.isFirst);
                  },
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.black, width: 2),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    textStyle: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  child: const Text('Close'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Achievement {
  final String dare;
  final DateTime date;
  _Achievement({required this.dare, required this.date});
}
