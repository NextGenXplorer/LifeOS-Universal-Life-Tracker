import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/activity.dart';

abstract class ActivityRepository {
  Future<Either<Failure, List<Activity>>> getActivities();
  Future<Either<Failure, Activity>> createActivity(Activity activity);
  Future<Either<Failure, Activity>> updateActivity(Activity activity);
  Future<Either<Failure, void>> deleteActivity(String id);
}
