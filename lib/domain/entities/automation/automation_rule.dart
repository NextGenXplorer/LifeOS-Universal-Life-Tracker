import 'dart:convert';
import 'package:equatable/equatable.dart';

enum TriggerType {
  time,
  event,
  location,
  sensor,
}

enum ConditionType {
  always,
  ifEnabled,
  streakBased,
  levelBased,
}

enum ActionType {
  showNotification,
  awardXpCoins,
  createTask,
  logActivity,
  startTimer,
}

class AutomationRule extends Equatable {
  final String id;
  final String name;
  final String? description;
  final TriggerType triggerType;
  final Map<String, dynamic>? triggerConfig;
  final ConditionType? conditionType;
  final Map<String, dynamic>? conditionConfig;
  final ActionType actionType;
  final Map<String, dynamic>? actionConfig;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  const AutomationRule({
    required this.id,
    required this.name,
    this.description,
    required this.triggerType,
    this.triggerConfig,
    this.conditionType,
    this.conditionConfig,
    required this.actionType,
    this.actionConfig,
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
  });

  AutomationRule copyWith({
    String? id,
    String? name,
    String? description,
    TriggerType? triggerType,
    Map<String, dynamic>? triggerConfig,
    ConditionType? conditionType,
    Map<String, dynamic>? conditionConfig,
    ActionType? actionType,
    Map<String, dynamic>? actionConfig,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return AutomationRule(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      triggerType: triggerType ?? this.triggerType,
      triggerConfig: triggerConfig ?? this.triggerConfig,
      conditionType: conditionType ?? this.conditionType,
      conditionConfig: conditionConfig ?? this.conditionConfig,
      actionType: actionType ?? this.actionType,
      actionConfig: actionConfig ?? this.actionConfig,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'trigger_type': triggerType.name,
      'trigger_config': triggerConfig != null ? jsonEncode(triggerConfig) : null,
      'condition_type': conditionType?.name,
      'condition_config': conditionConfig != null ? jsonEncode(conditionConfig) : null,
      'action_type': actionType.name,
      'action_config': actionConfig != null ? jsonEncode(actionConfig) : null,
      'is_active': isActive ? 1 : 0,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory AutomationRule.fromMap(Map<String, dynamic> map) {
    return AutomationRule(
      id: map['id'] as String,
      name: map['name'] as String,
      description: map['description'] as String?,
      triggerType: TriggerType.values.firstWhere(
        (e) => e.name == map['trigger_type'],
        orElse: () => TriggerType.event,
      ),
      triggerConfig: map['trigger_config'] != null 
          ? jsonDecode(map['trigger_config'] as String) as Map<String, dynamic>
          : null,
      conditionType: map['condition_type'] != null 
          ? ConditionType.values.firstWhere((e) => e.name == map['condition_type'])
          : null,
      conditionConfig: map['condition_config'] != null 
          ? jsonDecode(map['condition_config'] as String) as Map<String, dynamic>
          : null,
      actionType: ActionType.values.firstWhere(
        (e) => e.name == map['action_type'],
        orElse: () => ActionType.showNotification,
      ),
      actionConfig: map['action_config'] != null 
          ? jsonDecode(map['action_config'] as String) as Map<String, dynamic>
          : null,
      isActive: (map['is_active'] as int?) == 1,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
    );
  }

  @override
  List<Object?> get props => [id, name, triggerType, actionType, isActive];
}

class AutomationLog extends Equatable {
  final String id;
  final String ruleId;
  final DateTime triggeredAt;
  final bool executed;
  final String? result;

  const AutomationLog({
    required this.id,
    required this.ruleId,
    required this.triggeredAt,
    this.executed = false,
    this.result,
  });

  AutomationLog copyWith({
    String? id,
    String? ruleId,
    DateTime? triggeredAt,
    bool? executed,
    String? result,
  }) {
    return AutomationLog(
      id: id ?? this.id,
      ruleId: ruleId ?? this.ruleId,
      triggeredAt: triggeredAt ?? this.triggeredAt,
      executed: executed ?? this.executed,
      result: result ?? this.result,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'rule_id': ruleId,
      'triggered_at': triggeredAt.toIso8601String(),
      'executed': executed ? 1 : 0,
      'result': result,
    };
  }

  factory AutomationLog.fromMap(Map<String, dynamic> map) {
    return AutomationLog(
      id: map['id'] as String,
      ruleId: map['rule_id'] as String,
      triggeredAt: DateTime.parse(map['triggered_at'] as String),
      executed: (map['executed'] as int?) == 1,
      result: map['result'] as String?,
    );
  }

  @override
  List<Object?> get props => [id, ruleId, triggeredAt, executed];
}
