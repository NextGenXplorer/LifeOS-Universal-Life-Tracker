import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/activity_repository_impl.dart';
import '../../domain/entities/activity.dart';

final activityRepositoryProvider = Provider((ref) => ActivityRepositoryImpl());

final activitiesProvider = AsyncNotifierProvider<ActivitiesNotifier, List<Activity>>(
  ActivitiesNotifier.new,
);

class ActivitiesNotifier extends AsyncNotifier<List<Activity>> {
  @override
  Future<List<Activity>> build() async {
    final repository = ref.read(activityRepositoryProvider);
    final result = await repository.getActivities();
    return result.fold(
      (failure) => throw failure,
      (activities) => activities,
    );
  }

  Future<void> addActivity(Activity activity) async {
    final repository = ref.read(activityRepositoryProvider);
    final result = await repository.createActivity(activity);
    
    result.fold(
      (failure) => throw failure,
      (_) {
        state = AsyncValue.data([...state.value ?? [], activity]);
      },
    );
  }

  Future<void> updateActivity(Activity activity) async {
    final repository = ref.read(activityRepositoryProvider);
    final result = await repository.updateActivity(activity);
    
    result.fold(
      (failure) => throw failure,
      (_) {
        state = AsyncValue.data(
          (state.value ?? []).map((a) => 
            a.id == activity.id ? activity : a
          ).toList(),
        );
      },
    );
  }

  Future<void> deleteActivity(String id) async {
    final repository = ref.read(activityRepositoryProvider);
    final result = await repository.deleteActivity(id);
    
    result.fold(
      (failure) => throw failure,
      (_) {
        state = AsyncValue.data(
          (state.value ?? []).where((a) => a.id != id).toList(),
        );
      },
    );
  }
}
