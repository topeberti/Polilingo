import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/app_colors.dart';
import '../../providers/learning_provider.dart';
import '../widgets/hud_top_bar.dart';
import 'session_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<LearningProvider>().fetchAvailableSessions();
    });
  }

  @override
  Widget build(BuildContext context) {
    final learning = context.watch<LearningProvider>();

    return Scaffold(
      body: Stack(
        children: [
          Container(color: AppColors.backgroundDark),
          // Decor
          Positioned(
            top: 150,
            left: -50,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                const HudTopBar(),
                Expanded(
                  child: learning.isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : RefreshIndicator(
                          onRefresh: () => learning.fetchAvailableSessions(),
                          child: SingleChildScrollView(
                            padding: const EdgeInsets.symmetric(vertical: 20),
                            child: Column(
                              children: [
                                _buildUnitHeader('Unit 1', 'Basic Rights'),
                                const SizedBox(height: 32),
                                _buildLearningPath(learning),
                              ],
                            ),
                          ),
                        ),
                ),
              ],
            ),
          ),
          _buildBottomNav(),
        ],
      ),
    );
  }

  Widget _buildUnitHeader(String unit, String title) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.2),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.primary.withOpacity(0.3)),
          ),
          child: Text(
            'CURRENT UNIT',
            style: TextStyle(
              color: Colors.blue[300],
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '$unit: $title',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const Text(
          'Constitutional Framework & Liberties',
          style: TextStyle(color: Colors.white54, fontSize: 14),
        ),
      ],
    );
  }

  Widget _buildLearningPath(LearningProvider learning) {
    List<Widget> nodes = [];
    for (int i = 0; i < learning.sessions.length; i++) {
      final session = learning.sessions[i];
      final isPassed = learning.passedSessionIds.contains(
        session['id'].toString(),
      );
      final isNext =
          i == 0 ||
          learning.passedSessionIds.contains(
            learning.sessions[i - 1]['id'].toString(),
          );
      final isLocked = !isPassed && !isNext;

      nodes.add(
        _buildPathNode(
          session: session,
          index: i,
          isPassed: isPassed,
          isLocked: isLocked,
          isNext: isNext && !isPassed,
        ),
      );

      if (i < learning.sessions.length - 1) {
        nodes.add(const SizedBox(height: 20)); // Spacing between nodes
      }
    }

    return Stack(
      children: [
        // The vertical line
        Positioned(
          top: 0,
          bottom: 0,
          left: MediaQuery.of(context).size.width / 2 - 1,
          child: Container(width: 2, color: Colors.white.withOpacity(0.05)),
        ),
        Column(children: nodes),
      ],
    );
  }

  Widget _buildPathNode({
    required Map<String, dynamic> session,
    required int index,
    required bool isPassed,
    required bool isLocked,
    required bool isNext,
  }) {
    // Alternating offsets for zig-zag
    double offset = (index % 3 == 0)
        ? -60
        : (index % 3 == 2)
        ? 60
        : 0;

    return Padding(
      padding: EdgeInsets.only(
        left: offset > 0 ? offset : 0,
        right: offset < 0 ? -offset : 0,
      ),
      child: Column(
        children: [
          if (isNext) _buildStartTooltip(),
          GestureDetector(
            onTap: isLocked ? null : () => _startSession(session),
            child: Container(
              width: isNext ? 90 : 70,
              height: isNext ? 90 : 70,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: isLocked
                    ? null
                    : LinearGradient(
                        colors: isPassed
                            ? [AppColors.accentGold, AppColors.goldLight]
                            : [AppColors.primary, const Color(0xFF3C47B5)],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                color: isLocked ? const Color(0xFF1C1E30) : null,
                border: Border.all(
                  color: isPassed
                      ? AppColors.accentGold
                      : (isLocked ? Colors.white12 : const Color(0xFF3C47B5)),
                  width: 4,
                ),
                boxShadow: [
                  if (!isLocked)
                    BoxShadow(
                      color:
                          (isPassed ? AppColors.accentGold : AppColors.primary)
                              .withOpacity(0.4),
                      blurRadius: 15,
                      spreadRadius: 2,
                    ),
                ],
              ),
              child: Icon(
                isPassed
                    ? Icons.check
                    : (isLocked ? Icons.lock : Icons.menu_book),
                color: isLocked ? Colors.white24 : Colors.white,
                size: isNext ? 40 : 30,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            session['name'],
            style: TextStyle(
              color: isLocked ? Colors.white24 : Colors.white70,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildStartTooltip() {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.white.withOpacity(0.3), blurRadius: 10),
        ],
      ),
      child: const Text(
        'START',
        style: TextStyle(
          color: AppColors.primary,
          fontWeight: FontWeight.w900,
          fontSize: 12,
        ),
      ),
    );
  }

  void _startSession(Map<String, dynamic> session) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => SessionScreen(session: session)),
    );
  }

  Widget _buildBottomNav() {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: const Color(0xFF1C1E30).withOpacity(0.9),
          border: Border(
            top: BorderSide(color: Colors.white.withOpacity(0.05)),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(Icons.map, 'Path', active: true),
            _buildNavItem(Icons.emoji_events, 'Rank'),
            _buildNavItem(Icons.storefront, 'Shop'),
            _buildNavItem(Icons.person, 'Profile'),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, {bool active = false}) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          color: active ? AppColors.primary : Colors.white24,
          size: 28,
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: active ? Colors.white : Colors.white24,
            fontSize: 10,
          ),
        ),
      ],
    );
  }
}
