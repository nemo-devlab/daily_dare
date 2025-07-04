import 'package:daily_dare/screens/achievements_screen.dart';
import 'package:flutter/material.dart';
import 'the_rule_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'todays_dare_screen.dart';
import 'completed_dare_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'DAILY DARE',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 32),

                // Logo
                Image.asset(
                  'assets/logo.png',
                  height: 120,
                  width: 120,
                ),

                const SizedBox(height: 48),

                // Buttons
                _buildButton(
                  label: "See today's dare!",
                  onPressed: () async {
                    final prefs = await SharedPreferences.getInstance();
                    final todayKey = DateTime.now().toIso8601String().split('T').first;
                    final completed = prefs.getBool('completed_$todayKey') ?? false;

                    if (completed) {
                      // pull the exact snapshot you saved
                      final rem = prefs.getString('remaining_$todayKey') ?? '00:00:00';
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => CompletedTodaysDareScreen(remainingTime: rem),
                        ),
                      );
                    } else {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const TodaysDareScreen()),
                      );
                    }
                  },
                ),


                const SizedBox(height: 16),
                _buildButton(
                  label: "The RULE",
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const TheRuleScreen()),
                    );
                  },
                  isPrimary: true,
                ),
                const SizedBox(height: 16),
                _buildButton(
                  label: "Achievements",
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const AchievementsScreen()),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        mini: true,
        tooltip: 'Reset prefs (debug)',
        child: const Icon(Icons.refresh),
        onPressed: () async {
          final prefs = await SharedPreferences.getInstance();
          await prefs.clear();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Preferences cleared!')),
          );
        },
      ),
    );
  }

  Widget _buildButton({
    required String label,
    required VoidCallback onPressed,
    bool isPrimary = false,
  }) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          foregroundColor: isPrimary ? Colors.white : Colors.black,
          backgroundColor: isPrimary ? Colors.black : Colors.white,
          side: BorderSide(color: Colors.black, width: 2),
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        child: Text(label),
      ),
    );
  }
}
