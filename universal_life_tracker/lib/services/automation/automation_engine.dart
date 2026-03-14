import 'dart:async';
import 'package:lifeos/domain/entities/automation.dart';
import 'package:lifeos/services/notifications/notification_service.dart';

class AutomationEngine {
  final AutomationRepository _repository;
  Timer? _checkTimer;
  bool _isRunning = false;

  AutomationEngine(this._repository);

  void start() {
    if (_isRunning) return;
    _isRunning = true;
    
    // Check rules every 15 minutes
    _checkTimer = Timer.periodic(
      const Duration(minutes: 15),
      (_) => _checkAllRules(),
    );
    
    // Initial check
    _checkAllRules();
  }

  void stop() {
    _isRunning = false;
    _checkTimer?.cancel();
    _checkTimer = null;
  }

  Future<void> _checkAllRules() async {
    final rules = await _repository.getActiveRules();
    
    for (final rule in rules) {
      await _evaluateRule(rule);
    }
  }

  Future<void> _evaluateRule(AutomationRule rule) async {
    if (!rule.isActive) return;
    
    final triggerMet = await _checkTrigger(rule);
    
    if (!triggerMet) return;
    
    // Check condition if exists
    if (rule.conditionType != null) {
      final conditionMet = await _checkCondition(rule);
      if (!conditionMet) return;
    }
    
    // Execute action
    await _executeAction(rule);
    
    // Update last triggered
    await _repository.triggerRule(rule.id);
  }

  Future<bool> _checkTrigger(AutomationRule rule) async {
    switch (rule.triggerType) {
      case TriggerTypes.time:
        return _checkTimeTrigger(rule.triggerConfig);
      case TriggerTypes.habitCompleted:
        return _checkHabitCompletedTrigger(rule.triggerConfig);
      case TriggerTypes.taskCompleted:
        return _checkTaskCompletedTrigger(rule.triggerConfig);
      case TriggerTypes.dailyStreak:
        return _checkDailyStreakTrigger(rule.triggerConfig);
      default:
        return false;
    }
  }

  bool _checkTimeTrigger(Map<String, dynamic> config) {
    final now = DateTime.now();
    final targetHour = int.tryParse(config['hour']?.toString() ?? '');
    final targetMinute = int.tryParse(config['minute']?.toString() ?? '');
    
    if (targetHour == null || targetMinute == null) return false;
    
    // Check if current time matches (within 1 minute window)
    return now.hour == targetHour && 
           (now.minute - targetMinute).abs() <= 1;
  }

  Future<bool> _checkHabitCompletedTrigger(Map<String, dynamic> config) async {
    // This would need to be triggered by actual habit completion events
    return false;
  }

  Future<bool> _checkTaskCompletedTrigger(Map<String, dynamic> config) async {
    // This would need to be triggered by actual task completion events
    return false;
  }

  Future<bool> _checkDailyStreakTrigger(Map<String, dynamic> config) async {
    final targetStreak = int.tryParse(config['streak']?.toString() ?? '');
    if (targetStreak == null) return false;
    
    // Would check user's current streak
    return false;
  }

  Future<bool> _checkCondition(AutomationRule rule) async {
    if (rule.conditionType == null || rule.conditionConfig == null) {
      return true;
    }
    
    switch (rule.conditionType!) {
      case 'day_of_week':
        return _checkDayOfWeekCondition(rule.conditionConfig!);
      case 'time_range':
        return _checkTimeRangeCondition(rule.conditionConfig!);
      case 'habit_completed':
        return await _checkHabitCompletedCondition(rule.conditionConfig!);
      default:
        return true;
    }
  }

  bool _checkDayOfWeekCondition(Map<String, dynamic> config) {
    final now = DateTime.now();
    final days = config['days'] as String? ?? '';
    final dayList = days.split(',').map((d) => int.tryParse(d.trim())).toList();
    return dayList.contains(now.weekday);
  }

  bool _checkTimeRangeCondition(Map<String, dynamic> config) {
    final now = DateTime.now();
    final startHour = int.tryParse(config['start_hour']?.toString() ?? '') ?? 0;
    final endHour = int.tryParse(config['end_hour']?.toString() ?? '') ?? 24;
    
    return now.hour >= startHour && now.hour < endHour;
  }

  Future<bool> _checkHabitCompletedCondition(Map<String, dynamic> config) async {
    // Would check if a habit was completed
    return false;
  }

  Future<void> _executeAction(AutomationRule rule) async {
    switch (rule.actionType) {
      case ActionTypes.sendNotification:
        await _sendNotificationAction(rule.actionConfig);
        break;
      case ActionTypes.awardXp:
        await _awardXpAction(rule.actionConfig);
        break;
      case ActionTypes.sendReminder:
        await _sendReminderAction(rule.actionConfig);
        break;
    }
  }

  Future<void> _sendNotificationAction(Map<String, dynamic> config) async {
    final title = config['title'] as String? ?? 'LifeOS';
    final body = config['body'] as String? ?? '';
    
    await NotificationService.instance.showNotification(
      id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title: title,
      body: body,
    );
  }

  Future<void> _awardXpAction(Map<String, dynamic> config) async {
    final xp = int.tryParse(config['xp']?.toString() ?? '0') ?? 0;
    // Would award XP to user
    // await _gamificationRepository.addXp(xp);
  }

  Future<void> _sendReminderAction(Map<String, dynamic> config) async {
    final title = config['title'] as String? ?? 'Reminder';
    final body = config['body'] as String? ?? '';
    final delay = int.tryParse(config['delay_minutes']?.toString() ?? '0') ?? 0;
    
    final scheduledTime = DateTime.now().add(Duration(minutes: delay));
    
    await NotificationService.instance.scheduleNotification(
      id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title: title,
      body: body,
      scheduledTime: scheduledTime,
    );
  }

  Future<void> triggerManually(String ruleId) async {
    final rule = await _repository.getRuleById(ruleId);
    if (rule != null) {
      await _executeAction(rule);
    }
  }
}

// Placeholder for repository reference
abstract class AutomationRepository {
  Future<List<AutomationRule>> getActiveRules();
  Future<AutomationRule?> getRuleById(String id);
  Future<void> triggerRule(String id);
}
