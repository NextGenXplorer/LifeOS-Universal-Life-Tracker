import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:lifeos/domain/entities/settings.dart';
import 'package:lifeos/domain/repositories/settings_repository.dart';

// Events
abstract class SettingsEvent extends Equatable {
  const SettingsEvent();

  @override
  List<Object?> get props => [];
}

class LoadSettings extends SettingsEvent {}

class UpdateSettings extends SettingsEvent {
  final AppSettings settings;

  const UpdateSettings(this.settings);

  @override
  List<Object?> get props => [settings];
}

class ToggleDarkMode extends SettingsEvent {}

class ToggleNotifications extends SettingsEvent {}

class ToggleHaptic extends SettingsEvent {}

class ToggleSound extends SettingsEvent {}

class ToggleBiometric extends SettingsEvent {}

class CompleteOnboarding extends SettingsEvent {}

// States
abstract class SettingsState extends Equatable {
  const SettingsState();

  @override
  List<Object?> get props => [];
}

class SettingsInitial extends SettingsState {}

class SettingsLoading extends SettingsState {}

class SettingsLoaded extends SettingsState {
  final AppSettings settings;

  const SettingsLoaded(this.settings);

  @override
  List<Object?> get props => [settings];
}

class SettingsError extends SettingsState {
  final String message;

  const SettingsError(this.message);

  @override
  List<Object?> get props => [message];
}

// BLoC
class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  final SettingsRepository _repository;

  SettingsBloc(this._repository) : super(SettingsInitial()) {
    on<LoadSettings>(_onLoadSettings);
    on<UpdateSettings>(_onUpdateSettings);
    on<ToggleDarkMode>(_onToggleDarkMode);
    on<ToggleNotifications>(_onToggleNotifications);
    on<ToggleHaptic>(_onToggleHaptic);
    on<ToggleSound>(_onToggleSound);
    on<ToggleBiometric>(_onToggleBiometric);
    on<CompleteOnboarding>(_onCompleteOnboarding);
  }

  Future<void> _onLoadSettings(
    LoadSettings event,
    Emitter<SettingsState> emit,
  ) async {
    emit(SettingsLoading());
    try {
      final settings = await _repository.getSettings();
      emit(SettingsLoaded(settings));
    } catch (e) {
      emit(SettingsError(e.toString()));
    }
  }

  Future<void> _onUpdateSettings(
    UpdateSettings event,
    Emitter<SettingsState> emit,
  ) async {
    try {
      await _repository.saveSettings(event.settings);
      emit(SettingsLoaded(event.settings));
    } catch (e) {
      emit(SettingsError(e.toString()));
    }
  }

  Future<void> _onToggleDarkMode(
    ToggleDarkMode event,
    Emitter<SettingsState> emit,
  ) async {
    final currentState = state;
    if (currentState is SettingsLoaded) {
      final newSettings = currentState.settings.copyWith(
        darkMode: !currentState.settings.darkMode,
      );
      add(UpdateSettings(newSettings));
    }
  }

  Future<void> _onToggleNotifications(
    ToggleNotifications event,
    Emitter<SettingsState> emit,
  ) async {
    final currentState = state;
    if (currentState is SettingsLoaded) {
      final newSettings = currentState.settings.copyWith(
        notificationsEnabled: !currentState.settings.notificationsEnabled,
      );
      add(UpdateSettings(newSettings));
    }
  }

  Future<void> _onToggleHaptic(
    ToggleHaptic event,
    Emitter<SettingsState> emit,
  ) async {
    final currentState = state;
    if (currentState is SettingsLoaded) {
      final newSettings = currentState.settings.copyWith(
        hapticEnabled: !currentState.settings.hapticEnabled,
      );
      add(UpdateSettings(newSettings));
    }
  }

  Future<void> _onToggleSound(
    ToggleSound event,
    Emitter<SettingsState> emit,
  ) async {
    final currentState = state;
    if (currentState is SettingsLoaded) {
      final newSettings = currentState.settings.copyWith(
        soundEnabled: !currentState.settings.soundEnabled,
      );
      add(UpdateSettings(newSettings));
    }
  }

  Future<void> _onToggleBiometric(
    ToggleBiometric event,
    Emitter<SettingsState> emit,
  ) async {
    final currentState = state;
    if (currentState is SettingsLoaded) {
      final newSettings = currentState.settings.copyWith(
        biometricEnabled: !currentState.settings.biometricEnabled,
      );
      add(UpdateSettings(newSettings));
    }
  }

  Future<void> _onCompleteOnboarding(
    CompleteOnboarding event,
    Emitter<SettingsState> emit,
  ) async {
    final currentState = state;
    if (currentState is SettingsLoaded) {
      final newSettings = currentState.settings.copyWith(
        onboardingComplete: true,
      );
      add(UpdateSettings(newSettings));
    }
  }
}
