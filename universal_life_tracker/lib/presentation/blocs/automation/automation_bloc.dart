import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:lifeos/domain/entities/automation.dart';
import 'package:lifeos/domain/repositories/automation_repository.dart';
import 'package:lifeos/services/automation/automation_engine.dart';

// Events
abstract class AutomationEvent extends Equatable {
  const AutomationEvent();

  @override
  List<Object?> get props => [];
}

class LoadAutomationRules extends AutomationEvent {}

class CreateAutomationRule extends AutomationEvent {
  final AutomationRule rule;

  const CreateAutomationRule(this.rule);

  @override
  List<Object?> get props => [rule];
}

class UpdateAutomationRule extends AutomationEvent {
  final AutomationRule rule;

  const UpdateAutomationRule(this.rule);

  @override
  List<Object?> get props => [rule];
}

class DeleteAutomationRule extends AutomationEvent {
  final String ruleId;

  const DeleteAutomationRule(this.ruleId);

  @override
  List<Object?> get props => [ruleId];
}

class ToggleAutomationRule extends AutomationEvent {
  final String ruleId;
  final bool isActive;

  const ToggleAutomationRule(this.ruleId, this.isActive);

  @override
  List<Object?> get props => [ruleId, isActive];
}

class TriggerAutomationRule extends AutomationEvent {
  final String ruleId;

  const TriggerAutomationRule(this.ruleId);

  @override
  List<Object?> get props => [ruleId];
}

class StartAutomationEngine extends AutomationEvent {}

class StopAutomationEngine extends AutomationEvent {}

// States
abstract class AutomationState extends Equatable {
  const AutomationState();

  @override
  List<Object?> get props => [];
}

class AutomationInitial extends AutomationState {}

class AutomationLoading extends AutomationState {}

class AutomationLoaded extends AutomationState {
  final List<AutomationRule> allRules;
  final List<AutomationRule> activeRules;
  final bool isEngineRunning;

  const AutomationLoaded({
    required this.allRules,
    required this.activeRules,
    required this.isEngineRunning,
  });

  @override
  List<Object?> get props => [allRules, activeRules, isEngineRunning];
}

class AutomationError extends AutomationState {
  final String message;

  const AutomationError(this.message);

  @override
  List<Object?> get props => [message];
}

// BLoC
class AutomationBloc extends Bloc<AutomationEvent, AutomationState> {
  final AutomationRepository _repository;
  final AutomationEngine _engine;

  AutomationBloc(this._repository, this._engine) : super(AutomationInitial()) {
    on<LoadAutomationRules>(_onLoadRules);
    on<CreateAutomationRule>(_onCreateRule);
    on<UpdateAutomationRule>(_onUpdateRule);
    on<DeleteAutomationRule>(_onDeleteRule);
    on<ToggleAutomationRule>(_onToggleRule);
    on<TriggerAutomationRule>(_onTriggerRule);
    on<StartAutomationEngine>(_onStartEngine);
    on<StopAutomationEngine>(_onStopEngine);
  }

  Future<void> _onLoadRules(
    LoadAutomationRules event,
    Emitter<AutomationState> emit,
  ) async {
    emit(AutomationLoading());
    try {
      final allRules = await _repository.getAllRules();
      final activeRules = await _repository.getActiveRules();

      emit(AutomationLoaded(
        allRules: allRules,
        activeRules: activeRules,
        isEngineRunning: true, // Engine starts automatically
      ));
    } catch (e) {
      emit(AutomationError(e.toString()));
    }
  }

  Future<void> _onCreateRule(
    CreateAutomationRule event,
    Emitter<AutomationState> emit,
  ) async {
    try {
      await _repository.createRule(event.rule);
      add(LoadAutomationRules());
    } catch (e) {
      emit(AutomationError(e.toString()));
    }
  }

  Future<void> _onUpdateRule(
    UpdateAutomationRule event,
    Emitter<AutomationState> emit,
  ) async {
    try {
      await _repository.updateRule(event.rule);
      add(LoadAutomationRules());
    } catch (e) {
      emit(AutomationError(e.toString()));
    }
  }

  Future<void> _onDeleteRule(
    DeleteAutomationRule event,
    Emitter<AutomationState> emit,
  ) async {
    try {
      await _repository.deleteRule(event.ruleId);
      add(LoadAutomationRules());
    } catch (e) {
      emit(AutomationError(e.toString()));
    }
  }

  Future<void> _onToggleRule(
    ToggleAutomationRule event,
    Emitter<AutomationState> emit,
  ) async {
    try {
      await _repository.toggleRule(event.ruleId, event.isActive);
      add(LoadAutomationRules());
    } catch (e) {
      emit(AutomationError(e.toString()));
    }
  }

  Future<void> _onTriggerRule(
    TriggerAutomationRule event,
    Emitter<AutomationState> emit,
  ) async {
    try {
      await _engine.triggerManually(event.ruleId);
    } catch (e) {
      emit(AutomationError(e.toString()));
    }
  }

  void _onStartEngine(
    StartAutomationEngine event,
    Emitter<AutomationState> emit,
  ) {
    _engine.start();
    add(LoadAutomationRules());
  }

  void _onStopEngine(
    StopAutomationEngine event,
    Emitter<AutomationState> emit,
  ) {
    _engine.stop();
    add(LoadAutomationRules());
  }
}
