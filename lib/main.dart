import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/app_colors.dart';
import 'core/services/database_service.dart';
import 'core/services/notification_service.dart';
import 'services/ai/model_manager.dart';
import 'services/automation/automation_engine.dart';
import 'presentation/screens/gamification/skill_tree_screen.dart';
import 'presentation/screens/gamification/achievements_screen.dart';
import 'presentation/screens/ai/insights_screen.dart';
import 'presentation/screens/automation/automation_rules_screen.dart';
import 'presentation/widgets/voice_input_button.dart';
import 'features/dashboard/presentation/screens/dashboard_screen.dart';
import 'features/habits/presentation/screens/habits_screen.dart';
import 'features/tasks/presentation/screens/tasks_screen.dart';
import 'features/expenses/presentation/screens/expenses_screen.dart';
import 'features/goals/presentation/screens/goals_screen.dart';
import 'features/activities/presentation/screens/activities_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize services
  await DatabaseService.database;
  await NotificationService.initialize();
  await ModelManager.initialize();
  await AutomationEngine.start();
  
  runApp(const ProviderScope(child: LifeOSApp()));
}

class LifeOSApp extends StatelessWidget {
  const LifeOSApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'LifeOS',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: const MainNavigationScreen(),
    );
  }
}

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _selectedIndex = 0;
  
  final List<Widget> _screens = const [
    DashboardScreen(),
    HabitsScreen(),
    TasksScreen(),
    ExpensesScreen(),
    GoalsScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        backgroundColor: AppColors.surface,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textSecondary,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.repeat), label: 'Habits'),
          BottomNavigationBarItem(icon: Icon(Icons.task_alt), label: 'Tasks'),
          BottomNavigationBarItem(icon: Icon(Icons.attach_money), label: 'Expenses'),
          BottomNavigationBarItem(icon: Icon(Icons.flag), label: 'Goals'),
        ],
      ),
      drawer: _buildDrawer(context),
    );
  }

  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      backgroundColor: AppColors.cardBackground,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.primary, AppColors.secondary],
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Icon(Icons.favorite, size: 48, color: Colors.white),
                const SizedBox(height: 8),
                Text('LifeOS', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                Text('Universal Life Tracker', style: TextStyle(color: Colors.white70, fontSize: 14)),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.dashboard),
            title: const Text('Dashboard'),
            onTap: () { Navigator.pop(context); setState(() => _selectedIndex = 0); },
          ),
          ListTile(
            leading: const Icon(Icons.repeat),
            title: const Text('Habits'),
            onTap: () { Navigator.pop(context); setState(() => _selectedIndex = 1); },
          ),
          ListTile(
            leading: const Icon(Icons.task_alt),
            title: const Text('Tasks'),
            onTap: () { Navigator.pop(context); setState(() => _selectedIndex = 2); },
          ),
          ListTile(
            leading: const Icon(Icons.attach_money),
            title: const Text('Expenses'),
            onTap: () { Navigator.pop(context); setState(() => _selectedIndex = 3); },
          ),
          ListTile(
            leading: const Icon(Icons.flag),
            title: const Text('Goals'),
            onTap: () { Navigator.pop(context); setState(() => _selectedIndex = 4); },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.psychology),
            title: const Text('Skill Trees'),
            onTap: () { Navigator.pop(context); Navigator.push(context, MaterialPageRoute(builder: (_) => const SkillTreeScreen())); },
          ),
          ListTile(
            leading: const Icon(Icons.emoji_events),
            title: const Text('Achievements'),
            onTap: () { Navigator.pop(context); Navigator.push(context, MaterialPageRoute(builder: (_) => const AchievementsScreen())); },
          ),
          ListTile(
            leading: const Icon(Icons.lightbulb),
            title: const Text('AI Insights'),
            onTap: () { Navigator.pop(context); Navigator.push(context, MaterialPageRoute(builder: (_) => const InsightsScreen())); },
          ),
          ListTile(
            leading: const Icon(Icons.automation),
            title: const Text('Automation'),
            onTap: () { Navigator.pop(context); Navigator.push(context, MaterialPageRoute(builder: (_) => const AutomationRulesScreen())); },
          ),
          ListTile(
            leading: const Icon(Icons.mic),
            title: const Text('Voice Commands'),
            onTap: () { Navigator.pop(context); Navigator.push(context, MaterialPageRoute(builder: (_) => const VoiceCommandHelp())); },
          ),
          ListTile(
            leading: const Icon(Icons.directions_run),
            title: const Text('Activities'),
            onTap: () { Navigator.pop(context); Navigator.push(context, MaterialPageRoute(builder: (_) => const ActivitiesScreen())); },
          ),
        ],
      ),
    );
  }
}
