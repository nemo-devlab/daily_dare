import 'dart:async';
import 'package:flutter/material.dart';
import '../data/dare_list.dart';
import 'pay_price_screen.dart';
import 'congrats_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

String getTodaysDare() {
  final today = DateTime.now();
  final dateSeed = today.year * 10000 + today.month * 100 + today.day;
  final index = dateSeed % dailyDares.length;
  return dailyDares[index];
}

class TodaysDareScreen extends StatefulWidget {
  const TodaysDareScreen({super.key});

  @override
  State<TodaysDareScreen> createState() => _TodaysDareScreenState();
}

class _TodaysDareScreenState extends State<TodaysDareScreen> {
  Timer? _timer; // nullable
  late DateTime _startTime;
  Duration _remaining = Duration.zero;
  bool _isTimeUp = false;

  // final Duration _dareDuration = const Duration(hours: 12);
  final Duration _dareDuration = const Duration(seconds: 10);

  @override
  void initState() {
    super.initState();

    DateTime now = DateTime.now();

    // Today at 7 AM
    DateTime today7AM = DateTime(now.year, now.month, now.day, 7);

    if (now.isBefore(today7AM)) {
      // It's before 7 AM: still on yesterday's dare → use yesterday's 7 AM
      today7AM = today7AM.subtract(const Duration(days: 1));
    }

    _startTime = today7AM;
    _startTimer();
  }


  void _startTimer() {
    _updateRemaining();

    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      _updateRemaining();
    });
  }

  void _updateRemaining() {
    final now = DateTime.now();
    final endTime = _startTime.add(_dareDuration);

    setState(() {
      _remaining = endTime.difference(now);
      _isTimeUp = _remaining.isNegative;
      if (_isTimeUp) {
        _remaining = Duration.zero;
        _timer?.cancel();
      }
    });
  }


  String _formatDuration(Duration d) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = twoDigits(d.inHours);
    final minutes = twoDigits(d.inMinutes.remainder(60));
    final seconds = twoDigits(d.inSeconds.remainder(60));
    return "$hours:$minutes:$seconds";
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dareText = getTodaysDare();

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  "Today’s Dare",
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 32),
                Text(
                  _formatDuration(_remaining),
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: _isTimeUp ? Colors.red[300] : Colors.yellow[700],
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    dareText,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 18,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                if (_isTimeUp)
                  Text(
                    "Oh no, time’s up!",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.red[400],
                    ),
                  ),
                const SizedBox(height: 32),
                _isTimeUp
                    ? ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const CoffeePaymentScreen()),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          "Pay the price",
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                      )
                    : Column(
                        children: [
                          OutlinedButton(
                            onPressed: () async {
                              // 1) stop the timer
                              _timer?.cancel();

                              // 2) snapshot remaining time
                              final snapshot = _formatDuration(_remaining);

                              // 3) persist completion + snapshot
                              final prefs = await SharedPreferences.getInstance();
                              final todayKey = DateTime.now().toIso8601String().split('T').first;
                              await prefs.setBool('completed_$todayKey', true);
                              await prefs.setString('remaining_$todayKey', snapshot);

                              // 4) save to achievements list if you want
                              await _saveAchievement(dareText);

                              // 5) navigate to the Congrats screen instead of the Completed screen
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => const CongratsScreen()),
                              );
                            },
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text(
                              "I did it!",
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                          ),


                          const SizedBox(height: 16),
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: const Text(
                              "Close",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Saves the completed dare into SharedPreferences
  Future<void> _saveAchievement(String dare) async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList('achievements') ?? [];
    list.add('${DateTime.now().toIso8601String()}|$dare');
    await prefs.setStringList('achievements', list);
  }
}
