import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:lifeos/domain/entities/habit.dart';
import 'package:lifeos/domain/repositories/habit_repository.dart';
import 'package:lifeos/services/gamification/xp_calculator.dart';

// Events
abstract class HabitEvent extends Equatable {
  const HabitEvent();

  @override
  List<Object?> get props => [];
}

class LoadHabits extends HabitEvent {}

class CreateHabit extends HabitEvent {
  final Habit habit;

  const CreateHabit(this.habit);

  @override
  List<Object?> get props => [habit];
}

class UpdateHabit extends HabitEvent {
  final Habit habit;

  const UpdateHabit(this.habit);

  @override
  List<Object?> get props => [habit];
}

class DeleteHabit extends HabitEvent {
  final String habitId;

  const DeleteHabit(this.habitId);

  @override
  List<Object?> get props => [habitId];
}

class CompleteHabit extends HabitEvent {
  final String habitId;

  const CompleteHabit(this.habitId);

  @override
  List<Object?> get props => [habitId];
}

class UncompleteHabit extends HabitEvent {
  final String habitId;

  const UncompleteHabit(this.habitId);

  @override
  List<Object?> get props => [habitId];
}

class ToggleHabitActive extends HabitEvent {
  final String habitId;

  const ToggleHabitActive(this.habitId);

  @override
  List<Object?> get props => [habitId];
}

// States
abstract class HabitState extends Equatable {
  const HabitState();

  @override
  List<Object?> get props => [];
}

class HabitInitial extends HabitState {}

class HabitLoading extends HabitState {}

class HabitLoaded extends HabitState {
  final List<Habit> habits;
  final List<HabitLog> todayLogs;
  final int completedToday;
  final int totalActiveHabits;

  const HabitLoaded({
    required this.habits,
    required this.todayLogs,
    required this.completedToday,
    required this.totalActiveHabits,
  });

  bool isHabitCompletedToday(String habitId) {
    return todayLogs.any((log) => log.habitId == habitId);
  }

  @override
  List<Object?> get props => [habits, todayLogs, completedToday, totalActiveHabits];
}

class HabitCompleted extends HabitState {
  final HabitLog log;
  final int xpEarned;
  final int newStreak;

  const HabitCompleted({
    required this.log,
    required this.xpEarned,
    required this.newStreak,
  });

  @override
  List<Object?> get props => [log, xpEarned, newStreak];
}

class HabitError extends HabitState {
  final String message;

  const HabitError(this.message);

  @override
  List<Object?> get props => [message];
}

// BLoC
class HabitBloc extends Bloc<HabitEvent, HabitState> {
  final HabitRepository _repository;
  final XpCalculator _xpCalculator;

  HabitBloc(this._repository, this._xpCalculator) : super(HabitInitial()) {
    on<LoadHabits>(_onLoadHabits);
    on<CreateHabit>(_onCreateHabit);
    on<UpdateHabit>(_onUpdateHabit);
    on<DeleteHabit>(_onDeleteHabit);
    on<CompleteHabit>(_onCompleteHabit);
    on<UncompleteHabit>(_onUncompleteHabit);
    on<ToggleHabitActive>(_onToggleHabitActive);
  }

  Future<void> _onLoadHabits(LoadHabits event, Emitter<HabitState> emit) async {
    emit(HabitLoading());
    try {
      final habits = await _repository.getActiveHabits();
      final todayLogs = await _repository.getTodayLogs();
      final completedToday = todayLogs.length;

      emit(HabitLoaded(
        habits: habits,
        todayLogs: todayLogs,
        completedToday: completedToday,
        totalActiveHabits: habits.length,
      ));
    } catch (e) {
      emit(HabitError(e.toString()));
    }
  }

  Future<void> _onCreateHabit(CreateHabit event, Emitter<HabitState> emit) async {
    try {
      await _repository.createHabit(event.habit);
      add(LoadHabits());
    } catch (e) {
      emit(HabitError(e.toString()));
    }
  }

  Future<void> _onUpdateHabit(UpdateHabit event, Emitter<HabitState> emit) async {
    try {
      await _repository.updateHabit(event.habit);
      add(LoadHabits());
    } catch (e) {
      emit(HabitError(e.toString()));
    }
  }

  Future<void> _onDeleteHabit(DeleteHabit event, Emitter<HabitState> emit) async {
    try {
      await _repository.deleteHabit(event.habitId);
      add(LoadHabits());
    } catch (e) {
      emit(HabitError(e.toString()));
    }
  }

  Future<void> _onCompleteHabit(CompleteHabit event, Emitter<HabitState> emit) async {
    try {
      final log = await _repository.completeHabit(event.habitId);
      final habit = await _repository.getHabitById(event.habitId);
      
      if (habit != null) {
        emit(HabitCompleted(
          log: log,
          xpEarned: log.xpEarned,
          newStreak: habit.currentStreak,
        ));
      }
      
      add(LoadHabits());
    } catch (e) {
      emit(HabitError(e.toString()));
    }
  }

  Future<void> _onUncompleteHabit(UncompleteHabit event, Emitter<HabitState> emit) async {
    // Logic to uncomplete a habit
    add(LoadHabits());
  }

  Future<void> _onToggleHabitActive(ToggleHabitActive event, Emitter<HabitState> emit) async {
    try {
      final habit = await _repository.getHabitById(event.habitId);
      if (habit != null) {
        await _repository.updateHabit(habit.copyWith(isActive: !habit.isActive));
        add(LoadHabits());
      }
    } catch (e) {
      emit(HabitError(e.toString()));
    }
  }
}
