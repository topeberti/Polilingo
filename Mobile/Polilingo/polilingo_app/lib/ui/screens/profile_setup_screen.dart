import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/app_colors.dart';
import '../../providers/auth_provider.dart';

class ProfileSetupScreen extends StatefulWidget {
  const ProfileSetupScreen({super.key});

  @override
  State<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
  final _usernameController = TextEditingController();
  int _selectedGoal = 50;
  bool _isLoading = false;

  final List<Map<String, dynamic>> _goals = [
    {
      'name': 'Casual',
      'xp': 10,
      'icon': '☕',
      'desc': 'Light review, steady progress.',
      'time': '5m/day',
    },
    {
      'name': 'Regular',
      'xp': 30,
      'icon': '🏃',
      'desc': 'Consistent daily practice.',
      'time': '15m/day',
    },
    {
      'name': 'Serious',
      'xp': 50,
      'icon': 'local_police',
      'desc': 'Hardcore prep for the academy.',
      'time': '30m/day',
      'recommended': true,
    },
    {
      'name': 'Insane',
      'xp': 100,
      'icon': '🔥',
      'desc': 'No days off. Total focus.',
      'time': '60m/day',
    },
  ];

  String? _validateUsername(String username) {
    if (username.isEmpty) {
      return 'Please fill in your username';
    }
    if (username.length < 3 || username.length > 20) {
      return 'Username must be between 3 and 20 characters';
    }
    final validChars = RegExp(r'^[a-zA-Z0-9_]+$');
    if (!validChars.hasMatch(username)) {
      return 'Username can only contain letters, numbers, and underscores';
    }
    if (username.startsWith('_')) {
      return 'Username cannot start with an underscore';
    }
    if (username.contains('__')) {
      return 'Username cannot have consecutive underscores';
    }

    const reservedNames = {
      'admin',
      'teacher',
      'student',
      'guest',
      'support',
      'root',
      'system',
      'moderator',
      'bot',
      'settings',
      'api',
      'login',
    };
    if (reservedNames.contains(username.toLowerCase())) {
      return 'This username is reserved';
    }

    return null;
  }

  void _handleComplete() async {
    final username = _usernameController.text.trim();
    final error = _validateUsername(username);

    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error), backgroundColor: Colors.redAccent),
      );
      return;
    }

    setState(() => _isLoading = true);
    final success = await context.read<AuthProvider>().createProfile(
      _usernameController.text,
      _selectedGoal,
    );
    if (mounted) {
      setState(() => _isLoading = false);
      if (success) {
        Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to create profile. Try another username.'),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(color: AppColors.backgroundDark),
          ),
          // Background Glows
          Positioned(
            top: -100,
            left: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                _buildHeader(),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildProfileAvatar(),
                        const SizedBox(height: 32),
                        const Text(
                          'IDENTITY & OBJECTIVES',
                          style: TextStyle(
                            color: AppColors.textSecondaryDark,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.2,
                          ),
                        ),
                        const SizedBox(height: 16),

                        _buildTextField(
                          controller: _usernameController,
                          label: 'Username',
                          hint: 'PoliciaFuture',
                          prefix: '@',
                        ),
                        const SizedBox(height: 32),
                        const Text(
                          'DAILY TRAINING GOAL',
                          style: TextStyle(
                            color: AppColors.textSecondaryDark,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.2,
                          ),
                        ),
                        const SizedBox(height: 16),
                        ..._goals.map((goal) => _buildGoalCard(goal)).toList(),
                        const SizedBox(height: 100), // Space for sticky button
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          _buildStickyButton(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.backgroundDark.withOpacity(0.8),
        border: Border(
          bottom: BorderSide(color: Colors.white.withOpacity(0.05)),
        ),
      ),
      child: Column(
        children: [
          // Title
          const Text(
            'Profile Setup',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 12),
          // Progress Bar
          Container(
            height: 6,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(3),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: 0.25,
              child: Container(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.primary, Color(0x00D4FF)],
                  ),
                  borderRadius: BorderRadius.circular(3),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0x00D4FF).withOpacity(0.5),
                      blurRadius: 10,
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          // Progress Labels
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'STEP 1 OF 4',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                  color: AppColors.primary.withOpacity(0.8),
                ),
              ),
              Text(
                'CADET DETAILS',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                  color: AppColors.textSecondaryDark,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProfileAvatar() {
    return Center(
      child: Column(
        children: [
          Stack(
            children: [
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.surfaceDark,
                  border: Border.all(color: Colors.white12, width: 2),
                ),
                child: const Icon(
                  Icons.add_a_photo,
                  color: Colors.white54,
                  size: 30,
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.edit, color: Colors.white, size: 14),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            'Identity & Objectives',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const Text(
            'Set your badge name and training intensity.',
            style: TextStyle(color: AppColors.textSecondaryDark, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    String? prefix,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.white54,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(12),
          ),
          child: TextField(
            controller: controller,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(color: Colors.white.withOpacity(0.2)),
              prefixText: prefix,
              prefixStyle: const TextStyle(color: Colors.white54),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGoalCard(Map<String, dynamic> goal) {
    bool isSelected = _selectedGoal == goal['xp'];
    bool isRecommended = goal['recommended'] == true;
    bool useMaterialIcon = goal['icon'] == 'local_police';

    return GestureDetector(
      onTap: () => setState(() => _selectedGoal = goal['xp']),
      child: Stack(
        children: [
          Container(
            margin: EdgeInsets.only(bottom: 12, top: isRecommended ? 8 : 0),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isSelected
                  ? AppColors.primary.withOpacity(0.3)
                  : Colors.white.withOpacity(0.03),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isSelected ? AppColors.primary : Colors.white12,
                width: isSelected ? 2 : 1.5,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.3),
                        blurRadius: 20,
                        spreadRadius: 0,
                      ),
                    ]
                  : null,
            ),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? Colors.white.withOpacity(0.1)
                        : Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(12),
                    border: isSelected
                        ? Border.all(color: Colors.white.withOpacity(0.1))
                        : null,
                  ),
                  alignment: Alignment.center,
                  child: useMaterialIcon
                      ? Icon(
                          Icons.local_police,
                          color: isSelected ? Colors.white : Colors.white70,
                          size: 24,
                        )
                      : Text(
                          goal['icon'],
                          style: const TextStyle(fontSize: 24),
                        ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            goal['name'],
                            style: TextStyle(
                              color: isSelected ? Colors.white : Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            goal['time'],
                            style: TextStyle(
                              color: isSelected
                                  ? Colors.white.withOpacity(0.8)
                                  : Colors.white54,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        goal['desc'],
                        style: TextStyle(
                          color: isSelected
                              ? Colors.white.withOpacity(0.7)
                              : Colors.white54,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Column(
                  children: [
                    Text(
                      '${goal['xp']}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        fontSize: 18,
                      ),
                    ),
                    Text(
                      'XP',
                      style: TextStyle(
                        color: isSelected
                            ? Colors.white.withOpacity(0.8)
                            : AppColors.primary,
                        fontWeight: FontWeight.bold,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Recommended Badge
          if (isRecommended)
            Positioned(
              top: 0,
              right: 16,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0x00D4FF), Color(0x303BC9)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0x00D4FF).withOpacity(0.3),
                      blurRadius: 8,
                    ),
                  ],
                ),
                child: const Text(
                  'RECOMMENDED',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildStickyButton() {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.backgroundDark.withOpacity(0),
              AppColors.backgroundDark,
            ],
          ),
        ),
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(color: AppColors.accentGold),
              )
            : ElevatedButton(
                onPressed: _handleComplete,
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('CONFIRM PROFILE'),
                    SizedBox(width: 8),
                    Icon(Icons.arrow_forward, size: 20),
                  ],
                ),
              ),
      ),
    );
  }
}
