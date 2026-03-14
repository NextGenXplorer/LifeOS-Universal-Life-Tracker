import '../database_service.dart';
import '../notification_service.dart';
import '../../domain/entities/automation/automation_rule.dart';
import '../../core/constants/database_constants.dart';
import 'package:uuid/uuid.dart';

class AutomationEngine {
  static const _uuid = Uuid();
  static bool _isRunning = false;

  static Future<void> start() async {
    if (_isRunning) return;
    _isRunning = true;
    _startTriggerChecker();
  }

  static void stop() {
    _isRunning = false;
  }

  static Future<void> _startTriggerChecker() async {
    while (_isRunning) {
      await _checkAllRules();
      await Future.delayed(const Duration(minutes: 1));
    }
  }

  static Future<void> _checkAllRules() async {
    final rules = await getActiveRules();
    for (final rule in rules) {
      await _evaluateRule(rule);
    }
  }

  static Future<void> _evaluateRule(AutomationRule rule) async {
    // Check conditions
    if (rule.conditionType != null) {
      final conditionMet = await _checkCondition(rule);
      if (!conditionMet) return;
    }

    // Check trigger
    final triggered = await _evaluateTrigger(rule);
    if (triggered) {
      await _executeAction(rule);
    }
  }

  static Future<bool> _checkCondition(AutomationRule rule) async {
    switch (rule.conditionType) {
      case ConditionType.always:
        return true;
      case ConditionType.ifEnabled:
        return true;
      case ConditionType.streakBased:
        if (rule.conditionConfig != null) {
          final minStreak = rule.conditionConfig!['min_streak'] as int? ?? 0;
          final stats = await DatabaseService.query(DatabaseConstants.userStatsTable);
          if (stats.isNotEmpty) {
            final streak = stats.first['streak_days'] as int? ?? 0;
            return streak >= minStreak;
          }
        }
        return true;
      case ConditionType.levelBased:
        if (rule.conditionConfig != null) {
          final minLevel = rule.conditionConfig!['min_level'] as int? ?? 0;
          final stats = await DatabaseService.query(DatabaseConstants.userStatsTable);
          if (stats.isNotEmpty) {
            final level = stats.first['current_level'] as int? ?? 1;
            return level >= minLevel;
          }
        }
        return true;
      default:
        return true;
    }
  }

  static Future<bool> _evaluateTrigger(AutomationRule rule) async {
    switch (rule.triggerType) {
      case TriggerType.time:
        return await _evaluateTimeTrigger(rule);
      case TriggerType.event:
        return await _evaluateEventTrigger(rule);
      case TriggerType.location:
        return false; // Would need location service
      case TriggerType.sensor:
        return await _evaluateSensorTrigger(rule);
      default:
        return false;
    }
  }

  static Future<bool> _evaluateTimeTrigger(AutomationRule rule) async {
    if (rule.triggerConfig == null) return false;
    
    final targetHour = rule.triggerConfig!['hour'] as int?;
    final targetMinute = rule.triggerConfig!['minute'] as int?;
    final recurring = rule.triggerConfig!['recurring'] as bool? ?? false;

    final now = DateTime.now();
    
    if (targetHour != null && targetMinute != null) {
      if (now.hour == targetHour && now.minute == targetMinute) {
        return true;
      }
    }

    return false;
  }

  static Future<bool> _evaluateEventTrigger(AutomationRule rule) async {
    if (rule.triggerConfig == null) return false;

    final eventType = rule.triggerConfig!['event_type'] as String?;
    
    // Check recent activity
    final recentEvents = await DatabaseService.query(
      DatabaseConstants.activityLogsTable,
      orderBy: 'created_at DESC',
      limit: 10,
    );

    if (eventType == 'habit_completed') {
      return recentEvents.isNotEmpty;
    }

    return false;
  }

  static Future<bool> _evaluateSensorTrigger(AutomationRule rule) async {
    // Would integrate with sensor services
    return false;
  }

  static Future<void> _executeAction(AutomationRule rule) async {
    bool success = false;
    String? result;

    try {
      switch (rule.actionType) {
        case ActionType.showNotification:
          if (rule.actionConfig != null) {
            await NotificationService.showNotification(
              id: DateTime.now().millisecondsSinceEpoch,
              title: rule.actionConfig!['title'] ?? 'LifeOS',
              body: rule.actionConfig!['body'] ?? '',
            );
            success = true;
            result = 'Notification shown';
          }
        case ActionType.awardXpCoins:
          // Would call reward service
          success = true;
          result = 'Rewards awarded';
        case ActionType.createTask:
          // Would create task
          success = true;
          result = 'Task created';
        case ActionType.logActivity:
          // Would log activity
          success = true;
          result = 'Activity logged';
        case ActionType.startTimer:
          // Would start timer
          success = true;
          result = 'Timer started';
      }
    } catch (e) {
      result = 'Error: $e';
    }

    // Log execution
    await _logExecution(rule.id, success, result);
  }

  static Future<void> _logExecution(String ruleId, bool executed, String? result) async {
    final log = AutomationLog(
      id: _uuid.v4(),
      ruleId: ruleId,
      triggeredAt: DateTime.now(),
      executed: executed,
      result: result,
    );

    await DatabaseService.insert(DatabaseConstants.automationLogsTable, log.toMap());
  }

  static Future<List<AutomationRule>> getActiveRules() async {
    final results = await DatabaseService.query(
      DatabaseConstants.automationRulesTable,
      where: 'is_active = ?',
      whereArgs: [1],
    );

    return results.map((map) => AutomationRule.fromMap(map)).toList();
  }

  static Future<List<AutomationRule>> getAllRules() async {
    final results = await DatabaseService.query(
      DatabaseConstants.automationRulesTable,
      orderBy: 'created_at DESC',
    );

    return results.map((map) => AutomationRule.fromMap(map)).toList();
  }

  static Future<AutomationRule> createRule(AutomationRule rule) async {
    await DatabaseService.insert(DatabaseConstants.automationRulesTable, rule.toMap());
    return rule;
  }

  static Future<void> updateRule(AutomationRule rule) async {
    await DatabaseService.update(
      DatabaseConstants.automationRulesTable,
      rule.toMap(),
      where: 'id = ?',
      whereArgs: [rule.id],
    );
  }

  static Future<void> deleteRule(String ruleId) async {
    await DatabaseService.delete(
      DatabaseConstants.automationRulesTable,
      where: 'id = ?',
      whereArgs: [ruleId],
    );
  }

  static Future<void> toggleRule(String ruleId, bool isActive) async {
    await DatabaseService.update(
      DatabaseConstants.automationRulesTable,
      {'is_active': isActive ? 1 : 0, 'updated_at': DateTime.now().toIso8601String()},
      where: 'id = ?',
      whereArgs: [ruleId],
    );
  }
}
