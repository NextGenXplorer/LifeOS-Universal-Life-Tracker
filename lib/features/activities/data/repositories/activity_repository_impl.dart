import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import '../../../../core/constants/database_constants.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/services/database_service.dart';
import '../../domain/entities/activity.dart';
import '../../domain/repositories/activity_repository.dart';
import '../models/activity_model.dart';

class ActivityRepositoryImpl implements ActivityRepository {
  @override
  Future<Either<Failure, List<Activity>>> getActivities() async {
    try {
      final results = await DatabaseService.query(
        DatabaseConstants.activitiesTable,
        orderBy: 'created_at DESC',
      );
      
      final activities = results.map((json) => _mapToEntity(
        ActivityModel.fromJson(json),
      )).toList();
      
      return Right(activities);
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Activity>> createActivity(Activity activity) async {
    try {
      final model = _mapToModel(activity);
      await DatabaseService.insert(
        DatabaseConstants.activitiesTable,
        model.toJson(),
      );
      return Right(activity);
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Activity>> updateActivity(Activity activity) async {
    try {
      final model = _mapToModel(activity);
      await DatabaseService.update(
        DatabaseConstants.activitiesTable,
        model.toJson(),
        where: 'id = ?',
        whereArgs: [activity.id],
      );
      return Right(activity);
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteActivity(String id) async {
    try {
      await DatabaseService.delete(
        DatabaseConstants.activitiesTable,
        where: 'id = ?',
        whereArgs: [id],
      );
      return const Right(null);
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  Activity _mapToEntity(ActivityModel model) {
    return Activity(
      id: model.id,
      name: model.name,
      icon: model.icon != null ? _parseIcon(model.icon!) : null,
      color: model.color != null ? Color(model.color!) : null,
      category: model.category,
      isActive: model.isActive,
      createdAt: model.createdAt,
      updatedAt: model.updatedAt,
    );
  }

  ActivityModel _mapToModel(Activity entity) {
    return ActivityModel(
      id: entity.id,
      name: entity.name,
      icon: entity.icon?.codePoint.toString(),
      color: entity.color?.value,
      category: entity.category,
      isActive: entity.isActive,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }

  IconData _parseIcon(String codePoint) {
    return IconData(
      int.parse(codePoint),
      fontFamily: 'MaterialIcons',
    );
  }
}
