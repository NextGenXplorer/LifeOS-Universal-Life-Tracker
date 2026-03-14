import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:lifeos/domain/entities/task.dart';
import 'package:lifeos/domain/repositories/task_repository.dart';
import 'package:lifeos/services/gamification/xp_calculator.dart';

// Events
abstract class TaskEvent extends Equatable {
  const TaskEvent();

  @override
  List<Object?> get props => [];
}

class LoadTasks extends TaskEvent {}

class CreateTask extends TaskEvent {
  final Task task;

  const CreateTask(this.task);

  @override
  List<Object?> get props => [task];
}

class UpdateTask extends TaskEvent {
  final Task task;

  const UpdateTask(this.task);

  @override
  List<Object?> get props => [task];
}

class DeleteTask extends TaskEvent {
  final String taskId;

  const DeleteTask(this.taskId);

  @override
  List<Object?> get props => [taskId];
}

class CompleteTask extends TaskEvent {
  final String taskId;
  final int? actualMinutes;

  const CompleteTask(this.taskId, {this.actualMinutes});

  @override
  List<Object?> get props => [taskId, actualMinutes];
}

class UncompleteTask extends TaskEvent {
  final String taskId;

  const UncompleteTask(this.taskId);

  @override
  List<Object?> get props => [taskId];
}

class UpdateTaskStatus extends TaskEvent {
  final String taskId;
  final TaskStatus status;

  const UpdateTaskStatus(this.taskId, this.status);

  @override
  List<Object?> get props => [taskId, status];
}

// States
abstract class TaskState extends Equatable {
  const TaskState();

  @override
  List<Object?> get props => [];
}

class TaskInitial extends TaskState {}

class TaskLoading extends TaskState {}

class TaskLoaded extends TaskState {
  final List<Task> pendingTasks;
  final List<Task> completedTasks;
  final List<Task> todayTasks;
  final List<Task> overdueTasks;
  final int completedToday;
  final int pendingCount;

  const TaskLoaded({
    required this.pendingTasks,
    required this.completedTasks,
    required this.todayTasks,
    required this.overdueTasks,
    required this.completedToday,
    required this.pendingCount,
  });

  @override
  List<Object?> get props => [
        pendingTasks,
        completedTasks,
        todayTasks,
        overdueTasks,
        completedToday,
        pendingCount,
      ];
}

class TaskCompleted extends TaskState {
  final Task task;
  final int xpEarned;

  const TaskCompleted({
    required this.task,
    required this.xpEarned,
  });

  @override
  List<Object?> get props => [task, xpEarned];
}

class TaskError extends TaskState {
  final String message;

  const TaskError(this.message);

  @override
  List<Object?> get props => [message];
}

// BLoC
class TaskBloc extends Bloc<TaskEvent, TaskState> {
  final TaskRepository _repository;
  final XpCalculator _xpCalculator;

  TaskBloc(this._repository, this._xpCalculator) : super(TaskInitial()) {
    on<LoadTasks>(_onLoadTasks);
    on<CreateTask>(_onCreateTask);
    on<UpdateTask>(_onUpdateTask);
    on<DeleteTask>(_onDeleteTask);
    on<CompleteTask>(_onCompleteTask);
    on<UncompleteTask>(_onUncompleteTask);
    on<UpdateTaskStatus>(_onUpdateTaskStatus);
  }

  Future<void> _onLoadTasks(LoadTasks event, Emitter<TaskState> emit) async {
    emit(TaskLoading());
    try {
      final pendingTasks = await _repository.getPendingTasks();
      final completedTasks = await _repository.getTasksByStatus(TaskStatus.completed);
      final todayTasks = await _repository.getTodayTasks();
      final overdueTasks = await _repository.getOverdueTasks();
      final completedToday = await _repository.getCompletedTasksCountToday();

      emit(TaskLoaded(
        pendingTasks: pendingTasks,
        completedTasks: completedTasks,
        todayTasks: todayTasks,
        overdueTasks: overdueTasks,
        completedToday: completedToday,
        pendingCount: pendingTasks.length,
      ));
    } catch (e) {
      emit(TaskError(e.toString()));
    }
  }

  Future<void> _onCreateTask(CreateTask event, Emitter<TaskState> emit) async {
    try {
      await _repository.createTask(event.task);
      add(LoadTasks());
    } catch (e) {
      emit(TaskError(e.toString()));
    }
  }

  Future<void> _onUpdateTask(UpdateTask event, Emitter<TaskState> emit) async {
    try {
      await _repository.updateTask(event.task);
      add(LoadTasks());
    } catch (e) {
      emit(TaskError(e.toString()));
    }
  }

  Future<void> _onDeleteTask(DeleteTask event, Emitter<TaskState> emit) async {
    try {
      await _repository.deleteTask(event.taskId);
      add(LoadTasks());
    } catch (e) {
      emit(TaskError(e.toString()));
    }
  }

  Future<void> _onCompleteTask(CompleteTask event, Emitter<TaskState> emit) async {
    try {
      final completedTask = await _repository.completeTask(
        event.taskId,
        actualMinutes: event.actualMinutes,
      );
      
      final xpEarned = _xpCalculator.calculateTaskXp(
        completedTask,
        actualMinutes: event.actualMinutes,
      );

      emit(TaskCompleted(
        task: completedTask,
        xpEarned: xpEarned,
      ));
      
      add(LoadTasks());
    } catch (e) {
      emit(TaskError(e.toString()));
    }
  }

  Future<void> _onUncompleteTask(UncompleteTask event, Emitter<TaskState> emit) async {
    try {
      final task = await _repository.getTaskById(event.taskId);
      if (task != null) {
        await _repository.updateTask(task.copyWith(
          status: TaskStatus.pending,
          completedAt: null,
        ));
        add(LoadTasks());
      }
    } catch (e) {
      emit(TaskError(e.toString()));
    }
  }

  Future<void> _onUpdateTaskStatus(UpdateTaskStatus event, Emitter<TaskState> emit) async {
    try {
      final task = await _repository.getTaskById(event.taskId);
      if (task != null) {
        await _repository.updateTask(task.copyWith(status: event.status));
        add(LoadTasks());
      }
    } catch (e) {
      emit(TaskError(e.toString()));
    }
  }
}
