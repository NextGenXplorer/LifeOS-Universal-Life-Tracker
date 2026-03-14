import 'package:equatable/equatable.dart';

class AutomationRule extends Equatable {
  final String id;
  final String name;
  final String? description;
  final String triggerType;
  final Map<String, dynamic> triggerConfig;
  final String? conditionType;
  final Map<String, dynamic>? conditionConfig;
  final String actionType;
  final Map<String, dynamic> actionConfig;
  final bool isActive;
  final DateTime createdAt;
  final DateTime? lastTriggered;

  const AutomationRule({
    required this.id,
    required this.name,
    this.description,
    required this.triggerType,
    required this.triggerConfig,
    this.conditionType,
    this.conditionConfig,
    required this.actionType,
    required this.actionConfig,
    this.isActive = true,
    required this.createdAt,
    this.lastTriggered,
  });

  AutomationRule copyWith({
    String? id,
    String? name,
    String? description,
    String? triggerType,
    Map<String, dynamic>? triggerConfig,
    String? conditionType,
    Map<String, dynamic>? conditionConfig,
    String? actionType,
    Map<String, dynamic>? actionConfig,
    bool? isActive,
    DateTime? createdAt,
    DateTime? lastTriggered,
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
      lastTriggered: lastTriggered ?? this.lastTriggered,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'triggerType': triggerType,
      'triggerConfig': triggerConfig.toString(),
      'conditionType': conditionType,
      'conditionConfig': conditionConfig?.toString(),
      'actionType': actionType,
      'actionConfig': actionConfig.toString(),
      'isActive': isActive ? 1 : 0,
      'createdAt': createdAt.toIso8601String(),
      'lastTriggered': lastTriggered?.toIso8601String(),
    };
  }

  factory AutomationRule.fromMap(Map<String, dynamic> map) {
    return AutomationRule(
      id: map['id'] as String,
      name: map['name'] as String,
      description: map['description'] as String?,
      triggerType: map['triggerType'] as String,
      triggerConfig: _parseConfig(map['triggerConfig'] as String),
      conditionType: map['conditionType'] as String?,
      conditionConfig: map['conditionConfig'] != null
          ? _parseConfig(map['conditionConfig'] as String)
          : null,
      actionType: map['actionType'] as String,
      actionConfig: _parseConfig(map['actionConfig'] as String),
      isActive: map['isActive'] == 1,
      createdAt: DateTime.parse(map['createdAt'] as String),
      lastTriggered: map['lastTriggered'] != null
          ? DateTime.parse(map['lastTriggered'] as String)
          : null,
    );
  }

  static Map<String, dynamic> _parseConfig(String config) {
    // Simple config parsing - in production would use proper JSON
    final result = <String, dynamic>{};
    final pairs = config.replaceAll('{', '').replaceAll('}', '').split(', ');
    for (final pair in pairs) {
      if (pair.isNotEmpty) {
        final parts = pair.split(': ');
        if (parts.length == 2) {
          result[parts[0].trim()] = parts[1].trim();
        }
      }
    }
    return result;
  }

  @override
  List<Object?> get props => [
        id,
        name,
        description,
        triggerType,
        triggerConfig,
        conditionType,
        conditionConfig,
        actionType,
        actionConfig,
        isActive,
        createdAt,
        lastTriggered,
      ];
}

// Trigger Types
class TriggerTypes {
  static const String time = 'time';
  static const String location = 'location';
  static const String habitCompleted = 'habit_completed';
  static const String taskCompleted = 'task_completed';
  static const String dailyStreak = 'daily_streak';
  static const String sensor = 'sensor';
}

// Action Types
class ActionTypes {
  static const String sendNotification = 'send_notification';
  static const String awardXp = 'award_xp';
  static const String createTask = 'create_task';
  static const String sendReminder = 'send_reminder';
  static const String playSound = 'play_sound';
}
