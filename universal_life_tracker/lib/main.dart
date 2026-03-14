import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lifeos/config/injection_container.dart' as di;
import 'package:lifeos/config/app_router.dart';
import 'package:lifeos/presentation/blocs/habit/habit_bloc.dart';
import 'package:lifeos/presentation/blocs/task/task_bloc.dart';
import 'package:lifeos/presentation/blocs/gamification/gamification_bloc.dart';
import 'package:lifeos/presentation/blocs/insights/insights_bloc.dart';
import 'package:lifeos/presentation/blocs/automation/automation_bloc.dart';
import 'package:lifeos/presentation/blocs/settings/settings_bloc.dart';
import 'package:lifeos/presentation/theme/neo_glass_theme.dart';
import 'package:lifeos/services/notifications/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize dependency injection
  await di.init();
  
  // Initialize notifications
  await NotificationService.instance.initialize();
  
  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  
  // Set system UI overlay style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Color(0xFF0D0D0D),
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );
  
  runApp(const LifeOSApp());
}

class LifeOSApp extends StatelessWidget {
  const LifeOSApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<HabitBloc>(
          create: (_) => di.sl<HabitBloc>()..add(LoadHabits()),
        ),
        BlocProvider<TaskBloc>(
          create: (_) => di.sl<TaskBloc>()..add(LoadTasks()),
        ),
        BlocProvider<GamificationBloc>(
          create: (_) => di.sl<GamificationBloc>()..add(LoadGamificationData()),
        ),
        BlocProvider<InsightsBloc>(
          create: (_) => di.sl<InsightsBloc>()..add(LoadInsights()),
        ),
        BlocProvider<AutomationBloc>(
          create: (_) => di.sl<AutomationBloc>()..add(LoadAutomationRules()),
        ),
        BlocProvider<SettingsBloc>(
          create: (_) => di.sl<SettingsBloc>()..add(LoadSettings()),
        ),
      ],
      child: MaterialApp.router(
        title: 'LifeOS',
        debugShowCheckedModeBanner: false,
        theme: NeoGlassTheme.darkTheme,
        routerConfig: AppRouter.router,
      ),
    );
  }
}
