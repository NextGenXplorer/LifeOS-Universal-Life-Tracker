import 'package:lifeos/domain/entities/automation.dart';
import 'package:lifeos/domain/repositories/automation_repository.dart';
import 'package:lifeos/data/datasources/local/app_database.dart';
import 'package:uuid/uuid.dart';

class AutomationRepositoryImpl implements AutomationRepository {
  final AppDatabase _database;
  final _uuid = const Uuid();

  AutomationRepositoryImpl(this._database);

  @override
  Future<List<AutomationRule>> getAllRules() async {
    final db = await _database.database;
    final maps = await db.query('automation_rules', orderBy: 'createdAt DESC');
    return maps.map((map) => AutomationRule.fromMap(map)).toList();
  }

  @override
  Future<List<AutomationRule>> getActiveRules() async {
    final db = await _database.database;
    final maps = await db.query(
      'automation_rules',
      where: 'isActive = ?',
      whereArgs: [1],
      orderBy: 'createdAt DESC',
    );
    return maps.map((map) => AutomationRule.fromMap(map)).toList();
  }

  @override
  Future<AutomationRule?> getRuleById(String id) async {
    final db = await _database.database;
    final maps = await db.query(
      'automation_rules',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isEmpty) return null;
    return AutomationRule.fromMap(maps.first);
  }

  @override
  Future<AutomationRule> createRule(AutomationRule rule) async {
    final db = await _database.database;
    final newRule = rule.copyWith(
      id: rule.id.isEmpty ? _uuid.v4() : rule.id,
    );
    await db.insert('automation_rules', newRule.toMap());
    return newRule;
  }

  @override
  Future<AutomationRule> updateRule(AutomationRule rule) async {
    final db = await _database.database;
    await db.update(
      'automation_rules',
      rule.toMap(),
      where: 'id = ?',
      whereArgs: [rule.id],
    );
    return rule;
  }

  @override
  Future<void> deleteRule(String id) async {
    final db = await _database.database;
    await db.delete('automation_rules', where: 'id = ?', whereArgs: [id]);
  }

  @override
  Future<void> toggleRule(String id, bool isActive) async {
    final db = await _database.database;
    await db.update(
      'automation_rules',
      {'isActive': isActive ? 1 : 0},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  @override
  Future<void> triggerRule(String id) async {
    final db = await _database.database;
    await db.update(
      'automation_rules',
      {'lastTriggered': DateTime.now().toIso8601String()},
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
