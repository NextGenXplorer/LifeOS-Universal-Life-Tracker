import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:lifeos/domain/repositories/insights_repository.dart';

// Events
abstract class InsightsEvent extends Equatable {
  const InsightsEvent();

  @override
  List<Object?> get props => [];
}

class LoadInsights extends InsightsEvent {}

class RefreshInsights extends InsightsEvent {}

// States
abstract class InsightsState extends Equatable {
  const InsightsState();

  @override
  List<Object?> get props => [];
}

class InsightsInitial extends InsightsState {}

class InsightsLoading extends InsightsState {}

class InsightsLoaded extends InsightsState {
  final Map<String, dynamic> insights;
  final List<Map<String, dynamic>> habitInsights;
  final List<Map<String, dynamic>> productivityInsights;
  final Map<String, dynamic> weeklySummary;
  final Map<String, dynamic> predictions;
  final List<Map<String, dynamic>> recommendations;

  const InsightsLoaded({
    required this.insights,
    required this.habitInsights,
    required this.productivityInsights,
    required this.weeklySummary,
    required this.predictions,
    required this.recommendations,
  });

  @override
  List<Object?> get props => [
        insights,
        habitInsights,
        productivityInsights,
        weeklySummary,
        predictions,
        recommendations,
      ];
}

class InsightsError extends InsightsState {
  final String message;

  const InsightsError(this.message);

  @override
  List<Object?> get props => [message];
}

// BLoC
class InsightsBloc extends Bloc<InsightsEvent, InsightsState> {
  final InsightsRepository _repository;

  InsightsBloc(this._repository) : super(InsightsInitial()) {
    on<LoadInsights>(_onLoadInsights);
    on<RefreshInsights>(_onRefreshInsights);
  }

  Future<void> _onLoadInsights(
    LoadInsights event,
    Emitter<InsightsState> emit,
  ) async {
    emit(InsightsLoading());
    try {
      final insights = await _repository.getInsights();
      
      emit(InsightsLoaded(
        insights: insights,
        habitInsights: insights['habitInsights'] ?? [],
        productivityInsights: insights['productivityInsights'] ?? [],
        weeklySummary: insights['weeklySummary'] ?? {},
        predictions: insights['predictions'] ?? {},
        recommendations: insights['recommendations'] ?? [],
      ));
    } catch (e) {
      emit(InsightsError(e.toString()));
    }
  }

  Future<void> _onRefreshInsights(
    RefreshInsights event,
    Emitter<InsightsState> emit,
  ) async {
    add(LoadInsights());
  }
}
