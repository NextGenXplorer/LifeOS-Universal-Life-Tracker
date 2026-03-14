import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:lifeos/domain/entities/gamification.dart';
import 'package:lifeos/domain/repositories/gamification_repository.dart';
import 'package:lifeos/services/gamification/xp_calculator.dart';

// Events
abstract class GamificationEvent extends Equatable {
  const GamificationEvent();

  @override
  List<Object?> get props => [];
}

class LoadGamificationData extends GamificationEvent {}

class AddXP extends GamificationEvent {
  final int xp;
  final String? reason;

  const AddXP(this.xp, {this.reason});

  @override
  List<Object?> get props => [xp, reason];
}

class AddCoins extends GamificationEvent {
  final int coins;

  const AddCoins(this.coins);

  @override
  List<Object?> get props => [coins];
}

class UnlockAchievement extends GamificationEvent {
  final String achievementId;

  const UnlockAchievement(this.achievementId);

  @override
  List<Object?> get props => [achievementId];
}

class UpdateAchievementProgress extends GamificationEvent {
  final String achievementId;
  final double progress;

  const UpdateAchievementProgress(this.achievementId, this.progress);

  @override
  List<Object?> get props => [achievementId, progress];
}

class AddSkillXP extends GamificationEvent {
  final String skillId;
  final int xp;

  const AddSkillXP(this.skillId, this.xp);

  @override
  List<Object?> get props => [skillId, xp];
}

class UpdateDayStreak extends GamificationEvent {}

// States
abstract class GamificationState extends Equatable {
  const GamificationState();

  @override
  List<Object?> get props => [];
}

class GamificationInitial extends GamificationState {}

class GamificationLoading extends GamificationState {}

class GamificationLoaded extends GamificationState {
  final UserProfile profile;
  final List<Achievement> allAchievements;
  final List<Achievement> unlockedAchievements;
  final List<Skill> allSkills;
  final int levelProgressPercent;
  final int xpToNextLevel;

  const GamificationLoaded({
    required this.profile,
    required this.allAchievements,
    required this.unlockedAchievements,
    required this.allSkills,
    required this.levelProgressPercent,
    required this.xpToNextLevel,
  });

  @override
  List<Object?> get props => [
        profile,
        allAchievements,
        unlockedAchievements,
        allSkills,
        levelProgressPercent,
        xpToNextLevel,
      ];
}

class XPAdded extends GamificationState {
  final int xpAdded;
  final int newLevel;
  final bool leveledUp;

  const XPAdded({
    required this.xpAdded,
    required this.newLevel,
    required this.leveledUp,
  });

  @override
  List<Object?> get props => [xpAdded, newLevel, leveledUp];
}

class AchievementUnlocked extends GamificationState {
  final Achievement achievement;

  const AchievementUnlocked(this.achievement);

  @override
  List<Object?> get props => [achievement];
}

class GamificationError extends GamificationState {
  final String message;

  const GamificationError(this.message);

  @override
  List<Object?> get props => [message];
}

// BLoC
class GamificationBloc extends Bloc<GamificationEvent, GamificationState> {
  final GamificationRepository _repository;
  final XpCalculator _xpCalculator;

  GamificationBloc(this._repository, this._xpCalculator) : super(GamificationInitial()) {
    on<LoadGamificationData>(_onLoadGamificationData);
    on<AddXP>(_onAddXP);
    on<AddCoins>(_onAddCoins);
    on<UnlockAchievement>(_onUnlockAchievement);
    on<UpdateAchievementProgress>(_onUpdateAchievementProgress);
    on<AddSkillXP>(_onAddSkillXP);
    on<UpdateDayStreak>(_onUpdateDayStreak);
  }

  Future<void> _onLoadGamificationData(
    LoadGamificationData event,
    Emitter<GamificationState> emit,
  ) async {
    emit(GamificationLoading());
    try {
      final profile = await _repository.getUserProfile();
      final allAchievements = await _repository.getAllAchievements();
      final unlockedAchievements = await _repository.getUnlockedAchievements();
      final allSkills = await _repository.getAllSkills();

      final progress = _xpCalculator.levelProgress(profile.level, profile.currentXp);
      final xpToNext = _xpCalculator.xpToNextLevel(profile.level, profile.currentXp);

      emit(GamificationLoaded(
        profile: profile,
        allAchievements: allAchievements,
        unlockedAchievements: unlockedAchievements,
        allSkills: allSkills,
        levelProgressPercent: (progress * 100).round(),
        xpToNextLevel: xpToNext,
      ));
    } catch (e) {
      emit(GamificationError(e.toString()));
    }
  }

  Future<void> _onAddXP(AddXP event, Emitter<GamificationState> emit) async {
    try {
      final previousProfile = await _repository.getUserProfile();
      final previousLevel = previousProfile.level;
      
      final updatedProfile = await _repository.addXp(event.xp);
      
      emit(XPAdded(
        xpAdded: event.xp,
        newLevel: updatedProfile.level,
        leveledUp: updatedProfile.level > previousLevel,
      ));
      
      add(LoadGamificationData());
    } catch (e) {
      emit(GamificationError(e.toString()));
    }
  }

  Future<void> _onAddCoins(AddCoins event, Emitter<GamificationState> emit) async {
    try {
      await _repository.addCoins(event.coins);
      add(LoadGamificationData());
    } catch (e) {
      emit(GamificationError(e.toString()));
    }
  }

  Future<void> _onUnlockAchievement(
    UnlockAchievement event,
    Emitter<GamificationState> emit,
  ) async {
    try {
      final achievement = await _repository.unlockAchievement(event.achievementId);
      emit(AchievementUnlocked(achievement));
      add(LoadGamificationData());
    } catch (e) {
      emit(GamificationError(e.toString()));
    }
  }

  Future<void> _onUpdateAchievementProgress(
    UpdateAchievementProgress event,
    Emitter<GamificationState> emit,
  ) async {
    try {
      await _repository.updateAchievementProgress(event.achievementId, event.progress);
      add(LoadGamificationData());
    } catch (e) {
      emit(GamificationError(e.toString()));
    }
  }

  Future<void> _onAddSkillXP(AddSkillXP event, Emitter<GamificationState> emit) async {
    try {
      await _repository.addSkillXp(event.skillId, event.xp);
      add(LoadGamificationData());
    } catch (e) {
      emit(GamificationError(e.toString()));
    }
  }

  Future<void> _onUpdateDayStreak(
    UpdateDayStreak event,
    Emitter<GamificationState> emit,
  ) async {
    try {
      await _repository.updateDayStreak();
      add(LoadGamificationData());
    } catch (e) {
      emit(GamificationError(e.toString()));
    }
  }
}
