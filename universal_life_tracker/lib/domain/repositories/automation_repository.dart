import 'package:lifeos/domain/entities/automation.dart';

abstract class AutomationRepository {
  Future<List<AutomationRule>> getAllRules();
  Future<List<AutomationRule>> getActiveRules();
  Future<AutomationRule?> getRuleById(String id);
  Future<AutomationRule> createRule(AutomationRule rule);
  Future<AutomationRule> updateRule(AutomationRule rule);
  Future<void> deleteRule(String id);
  Future<void> toggleRule(String id, bool isActive);
  Future<void> triggerRule(String id);
}
