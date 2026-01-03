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

class _DashboardScreenState extends State<DashboardScreen>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<LearningProvider>().fetchAvailableSessions();
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final learning = context.watch<LearningProvider>();

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: Column(
        children: [
          const HudTopBar(),
          Expanded(
            child: learning.isLoading
                ? const Center(child: CircularProgressIndicator())
                : Stack(
                    children: [
                      // Decorative Background Glows
                      _buildBackgroundDecor(),

                      RefreshIndicator(
                        onRefresh: () => learning.fetchAvailableSessions(),
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.only(top: 24, bottom: 100),
                          child: _buildPathContent(learning),
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

  Widget _buildBackgroundDecor() {
    return Stack(
      children: [
        Positioned(
          top: 100,
          left: -40,
          child: Container(
            width: 250,
            height: 250,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.05),
              shape: BoxShape.circle,
            ),
          ),
        ),
        Positioned(
          bottom: 200,
          right: -40,
          child: Container(
            width: 300,
            height: 300,
            decoration: BoxDecoration(
              color: Colors.blue[900]?.withOpacity(0.05),
              shape: BoxShape.circle,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPathContent(LearningProvider learning) {
    if (learning.sessions.isEmpty) {
      return const Center(
        child: Text(
          "No sessions available yet.",
          style: TextStyle(color: Colors.white54),
        ),
      );
    }

    // Group sessions by lesson
    Map<String, List<dynamic>> groupedSessions = {};
    List<String> lessonOrder = [];

    for (var session in learning.sessions) {
      String lessonId = session['lesson_id'].toString();
      if (!groupedSessions.containsKey(lessonId)) {
        groupedSessions[lessonId] = [];
        lessonOrder.add(lessonId);
      }
      groupedSessions[lessonId]!.add(session);
    }

    int sessionGlobalIndex = 0;
    List<Widget> content = [];

    for (int i = 0; i < lessonOrder.length; i++) {
      String lid = lessonOrder[i];
      final lesson = learning.lessons[lid];
      final sessions = groupedSessions[lid]!;

      content.add(
        _buildUnitHeader(
          'Unit ${i + 1}',
          lesson?['name'] ?? 'Unknown Lesson',
          isCurrent: i == 0, // Simplified: first lesson with content is current
        ),
      );

      content.add(const SizedBox(height: 32));

      content.add(_buildSectionPath(sessions, learning, sessionGlobalIndex));
      sessionGlobalIndex += sessions.length;

      if (i < lessonOrder.length - 1) {
        content.add(_buildSectionDivider());
      }
    }

    return SizedBox(
      width: double.infinity,
      child: Column(children: content),
    );
  }

  Widget _buildSectionPath(
    List<dynamic> sessions,
    LearningProvider learning,
    int startIndex,
  ) {
    return Stack(
      alignment: Alignment.topCenter,
      children: [
        // Connectivity Line
        Positioned(
          top: 40,
          bottom: 40,
          child: Container(
            width: 4,
            decoration: BoxDecoration(
              gradient: AppColors.pathLineGradient,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ),

        Column(
          children: List.generate(sessions.length, (index) {
            final session = sessions[index];
            final globalIdx = startIndex + index;

            final isPassed = learning.passedSessionIds.contains(
              session['id'].toString(),
            );
            // Session Sequencing: First session is next if not passed, or any session whose predecessor is passed.
            final bool isNext =
                !isPassed &&
                (globalIdx == 0 ||
                    learning.passedSessionIds.contains(
                      learning.sessions[globalIdx - 1]['id'].toString(),
                    ));
            final bool isLocked = !isPassed && !isNext;

            return _buildPathNode(
              session: session,
              index: globalIdx,
              isPassed: isPassed,
              isNext: isNext,
              isLocked: isLocked,
            );
          }),
        ),
      ],
    );
  }

  Widget _buildUnitHeader(String unit, String title, {bool isCurrent = false}) {
    return Column(
      children: [
        if (isCurrent)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            margin: const EdgeInsets.only(bottom: 8),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.primary.withOpacity(0.2)),
            ),
            child: const Text(
              'CURRENT UNIT',
              style: TextStyle(
                color: Color(0xFF93C5FD), // blue-300
                fontSize: 10,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.2,
              ),
            ),
          ),
        Text(
          '$unit: $title',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 4),
      ],
    );
  }

  Widget _buildSectionDivider() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(width: 40, height: 1, color: Colors.white10),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Icon(Icons.lock, color: Colors.white12, size: 20),
          ),
          Container(width: 40, height: 1, color: Colors.white10),
        ],
      ),
    );
  }

  Widget _buildPathNode({
    required Map<String, dynamic> session,
    required int index,
    required bool isPassed,
    required bool isLocked,
    required bool isNext,
  }) {
    // Zig-zag offsets based on design preference
    final List<double> offsets = [0, 50, -30, 0, -50, 30];
    double offset = offsets[index % offsets.length];

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Transform.translate(
        offset: Offset(offset, 0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isNext) _buildStartTooltip(),
            GestureDetector(
              onTap: isLocked ? null : () => _startSession(session),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Outer Glow for Active/Passed
                  if (!isLocked)
                    Container(
                      width: isNext ? 100 : 80,
                      height: isNext ? 100 : 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color:
                                (isPassed
                                        ? AppColors.accentGold
                                        : AppColors.primary)
                                    .withOpacity(0.3),
                            blurRadius: 20,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                    ),

                  // Pulsing animation for Next
                  if (isNext)
                    AnimatedBuilder(
                      animation: _pulseController,
                      builder: (context, child) {
                        return Container(
                          width: 90 + (20 * _pulseController.value),
                          height: 90 + (20 * _pulseController.value),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppColors.primary.withOpacity(
                                0.2 - (0.2 * _pulseController.value),
                              ),
                              width: 4,
                            ),
                          ),
                        );
                      },
                    ),

                  // Main Node Body
                  Container(
                    width: isNext ? 90 : (isPassed ? 80 : 70),
                    height: isNext ? 90 : (isPassed ? 80 : 70),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: isLocked
                          ? null
                          : LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: isPassed
                                  ? [
                                      AppColors.accentGold,
                                      const Color(0xFFD97706),
                                    ]
                                  : [AppColors.primaryLight, AppColors.primary],
                            ),
                      color: isLocked ? const Color(0xFF1C1E30) : null,
                      border: Border.all(
                        color: isPassed
                            ? AppColors.accentGold.withOpacity(0.5)
                            : (isLocked
                                  ? Colors.white.withOpacity(0.08)
                                  : const Color(0xFF3C47B5)),
                        width: 4,
                      ),
                    ),
                    child: Icon(
                      isPassed
                          ? Icons.check_circle
                          : (isLocked
                                ? Icons.lock
                                : _getIconForSession(session)),
                      color: isLocked ? Colors.white12 : Colors.white,
                      size: isNext ? 40 : 30,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            // Label
            SizedBox(
              width: 120,
              child: Text(
                session['name'].toUpperCase(),
                style: TextStyle(
                  color: isLocked
                      ? Colors.white12
                      : (isNext ? Colors.white : Colors.white70),
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.5,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getIconForSession(Map<String, dynamic> session) {
    // Map strategy or session type to icons
    final strategy = session['question_selection_strategy'] ?? '';
    if (strategy == 'random') return Icons.menu_book;
    if (strategy == 'error_review') return Icons.replay_circle_filled;
    return Icons.local_police;
  }

  Widget _buildStartTooltip() {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.white.withOpacity(0.4), blurRadius: 20),
        ],
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'START',
            style: TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.w900,
              fontSize: 12,
            ),
          ),
          SizedBox(width: 4),
          Text(
            '+10 XP',
            style: TextStyle(
              color: AppColors.primaryLight,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
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
    return Container(
      padding: const EdgeInsets.only(bottom: 24, top: 12),
      decoration: BoxDecoration(
        color: const Color(0xD91C1E30), // glass-nav
        border: Border(top: BorderSide(color: Colors.white.withOpacity(0.08))),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(Icons.map, 'PATH', active: true),
          _buildNavItem(Icons.emoji_events, 'RANK'),
          _buildNavItem(Icons.storefront, 'SHOP'),
          _buildNavItem(Icons.person, 'PROFILE'),
        ],
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, {bool active = false}) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: active
                ? AppColors.primary.withOpacity(0.2)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: active ? AppColors.primaryLight : Colors.white24,
            size: 26,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: active ? Colors.white : Colors.white24,
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
