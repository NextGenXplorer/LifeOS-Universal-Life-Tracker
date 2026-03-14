import 'package:get_it/get_it.dart';
import 'package:lifeos/data/datasources/local/app_database.dart';
import 'package:lifeos/data/repositories/habit_repository_impl.dart';
import 'package:lifeos/data/repositories/task_repository_impl.dart';
import 'package:lifeos/data/repositories/gamification_repository_impl.dart';
import 'package:lifeos/data/repositories/insights_repository_impl.dart';
import 'package:lifeos/data/repositories/automation_repository_impl.dart';
import 'package:lifeos/data/repositories/settings_repository_impl.dart';
import 'package:lifeos/domain/repositories/habit_repository.dart';
import 'package:lifeos/domain/repositories/task_repository.dart';
import 'package:lifeos/domain/repositories/gamification_repository.dart';
import 'package:lifeos/domain/repositories/insights_repository.dart';
import 'package:lifeos/domain/repositories/automation_repository.dart' as domain;
import 'package:lifeos/domain/repositories/settings_repository.dart';
import 'package:lifeos/presentation/blocs/habit/habit_bloc.dart';
import 'package:lifeos/presentation/blocs/task/task_bloc.dart';
import 'package:lifeos/presentation/blocs/gamification/gamification_bloc.dart';
import 'package:lifeos/presentation/blocs/insights/insights_bloc.dart';
import 'package:lifeos/presentation/blocs/automation/automation_bloc.dart';
import 'package:lifeos/presentation/blocs/settings/settings_bloc.dart';
import 'package:lifeos/services/ai/model_manager.dart';
import 'package:lifeos/services/gamification/xp_calculator.dart';
import 'package:lifeos/services/notifications/notification_service.dart';
import 'package:lifeos/services/automation/automation_engine.dart';
import 'package:lifeos/services/pattern_recognition/pattern_recognizer.dart';
import 'package:lifeos/services/prediction/prediction_service.dart';
import 'package:lifeos/services/voice/voice_command_parser.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // Database
  sl.registerLazySingleton<AppDatabase>(
    () => AppDatabase.instance,
  );
  
  await sl<AppDatabase>().initialize();
  
  // Services
  sl.registerLazySingleton<NotificationService>(
    () => NotificationService.instance,
  );
  
  sl.registerLazySingleton<ModelManager>(
    () => ModelManager(),
  );
  
  sl.registerLazySingleton<XpCalculator>(
    () => XpCalculator(),
  );
  
  sl.registerLazySingleton<AutomationEngine>(
    () => AutomationEngine(sl() as domain.AutomationRepository),
  );
  
  sl.registerLazySingleton<PatternRecognizer>(
    () => PatternRecognizer(),
  );
  
  sl.registerLazySingleton<PredictionService>(
    () => PredictionService(sl(), sl()),
  );
  
  sl.registerLazySingleton<VoiceCommandParser>(
    () => VoiceCommandParser(),
  );
  
  // Repositories
  sl.registerLazySingleton<HabitRepository>(
    () => HabitRepositoryImpl(sl()),
  );
  
  sl.registerLazySingleton<TaskRepository>(
    () => TaskRepositoryImpl(sl()),
  );
  
  sl.registerLazySingleton<GamificationRepository>(
    () => GamificationRepositoryImpl(sl()),
  );
  
  sl.registerLazySingleton<InsightsRepository>(
    () => InsightsRepositoryImpl(sl(), sl(), sl()),
  );
  
  sl.registerLazySingleton<domain.AutomationRepository>(
    () => AutomationRepositoryImpl(sl()),
  );
  
  sl.registerLazySingleton<SettingsRepository>(
    () => SettingsRepositoryImpl(),
  );
  
  // BLoCs
  sl.registerFactory<HabitBloc>(
    () => HabitBloc(sl(), sl()),
  );
  
  sl.registerFactory<TaskBloc>(
    () => TaskBloc(sl(), sl()),
  );
  
  sl.registerFactory<GamificationBloc>(
    () => GamificationBloc(sl(), sl()),
  );
  
  sl.registerFactory<InsightsBloc>(
    () => InsightsBloc(sl()),
  );
  
  sl.registerFactory<AutomationBloc>(
    () => AutomationBloc(sl(), sl()),
  );
  
  sl.registerFactory<SettingsBloc>(
    () => SettingsBloc(sl()),
  );
}
