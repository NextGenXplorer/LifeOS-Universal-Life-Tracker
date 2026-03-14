import 'dart:convert';
import 'dart:io';
import 'package:csv/csv.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:archive/archive_io.dart';
import '../constants/database_constants.dart';
import 'database_service.dart';

class BackupService {
  static Future<void> exportToJson() async {
    final data = await _collectAllData();
    final jsonString = jsonEncode(data);
    
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/lifeos_backup.json');
    await file.writeAsString(jsonString);
    
    await Share.shareXFiles(
      [XFile(file.path)],
      subject: 'LifeOS Backup',
    );
  }

  static Future<void> exportToCsv() async {
    final directory = await getApplicationDocumentsDirectory();
    final timestamp = DateTime.now().toIso8601String();
    final exportDir = Directory('${directory.path}/export_$timestamp');
    await exportDir.create();

    // Export each table to CSV
    final tables = [
      DatabaseConstants.habitsTable,
      DatabaseConstants.tasksTable,
      DatabaseConstants.expensesTable,
      DatabaseConstants.goalsTable,
    ];

    for (final table in tables) {
      final data = await DatabaseService.query(table);
      if (data.isNotEmpty) {
        final csvData = const ListToCsvConverter().convert([
          data.first.keys.toList(),
          ...data.map((row) => row.values.toList()),
        ]);
        
        final file = File('${exportDir.path}/$table.csv');
        await file.writeAsString(csvData);
      }
    }

    // Create ZIP
    final zipFile = File('${directory.path}/lifeos_export_$timestamp.zip');
    await ZipFile.createFromDirectory(
      sourceDir: exportDir,
      zipFile: zipFile,
    );

    await Share.shareXFiles(
      [XFile(zipFile.path)],
      subject: 'LifeOS Export',
    );

    // Cleanup
    await exportDir.delete(recursive: true);
  }

  static Future<void> exportToPdf() async {
    final pdf = pw.Document();

    // Add habit stats
    final habits = await DatabaseService.query(DatabaseConstants.habitsTable);
    pdf.addPage(
      pw.Page(
        build: (context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text('LifeOS Report', style: pw.TextStyle(fontSize: 24)),
            pw.SizedBox(height: 20),
            pw.Text('Habits', style: pw.TextStyle(fontSize: 18)),
            pw.SizedBox(height: 10),
            ...habits.map((h) => pw.Text('- ${h['title']}')),
          ],
        ),
      ),
    );

    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/lifeos_report.pdf');
    await file.writeAsBytes(await pdf.save());

    await Share.shareXFiles(
      [XFile(file.path)],
      subject: 'LifeOS Report',
    );
  }

  static Future<void> importFromJson(String filePath) async {
    final file = File(filePath);
    final jsonString = await file.readAsString();
    final data = jsonDecode(jsonString) as Map<String, dynamic>;

    // Import each table
    for (final entry in data.entries) {
      final tableName = entry.key;
      final rows = entry.value as List;
      
      for (final row in rows) {
        await DatabaseService.insert(tableName, row as Map<String, dynamic>);
      }
    }
  }

  static Future<Map<String, dynamic>> _collectAllData() async {
    final tables = [
      DatabaseConstants.activitiesTable,
      DatabaseConstants.habitsTable,
      DatabaseConstants.habitCompletionsTable,
      DatabaseConstants.tasksTable,
      DatabaseConstants.expensesTable,
      DatabaseConstants.goalsTable,
      DatabaseConstants.milestonesTable,
      DatabaseConstants.scheduleTable,
      DatabaseConstants.activityLogsTable,
      DatabaseConstants.templatesTable,
      DatabaseConstants.settingsTable,
    ];

    final data = <String, dynamic>{};
    for (final table in tables) {
      data[table] = await DatabaseService.query(table);
    }

    return {
      'exportDate': DateTime.now().toIso8601String(),
      'version': '1.0.0',
      'data': data,
    };
  }
}
