class VoiceCommandParser {
  final Map<String, List<String>> _commandPatterns = {
    'add_habit': ['add habit', 'new habit', 'create habit', 'start habit'],
    'complete_habit': ['complete habit', 'done habit', 'finish habit', 'mark habit done'],
    'add_task': ['add task', 'new task', 'create task', 'add todo'],
    'complete_task': ['complete task', 'done task', 'finish task', 'mark task done'],
    'show_stats': ['show stats', 'show statistics', 'my stats', 'how am i doing'],
    'show_achievements': ['show achievements', 'my achievements', 'badges', 'unlocked achievements'],
    'show_level': ['show level', 'my level', 'what level am i', 'xp'],
    'set_reminder': ['remind me', 'set reminder', 'reminder'],
    'add_journal': ['journal entry', 'write journal', 'new entry', 'log thoughts'],
  };

  Map<String, dynamic>? parseCommand(String input) {
    final normalizedInput = input.toLowerCase().trim();
    
    for (final entry in _commandPatterns.entries) {
      for (final pattern in entry.value) {
        if (normalizedInput.contains(pattern)) {
          return _extractIntent(entry.key, normalizedInput, pattern);
        }
      }
    }
    
    return null;
  }

  Map<String, dynamic>? _extractIntent(
    String intent,
    String input,
    String matchedPattern,
  ) {
    final extracted = <String, dynamic>{'intent': intent};
    
    // Extract entities based on intent
    switch (intent) {
      case 'add_habit':
      case 'complete_habit':
      case 'add_task':
      case 'complete_task':
        extracted['entity'] = _extractEntityName(input, matchedPattern);
        break;
      case 'set_reminder':
        extracted['time'] = _extractTime(input);
        extracted['entity'] = _extractEntityName(input, matchedPattern);
        break;
    }
    
    return extracted;
  }

  String? _extractEntityName(String input, String pattern) {
    // Remove the matched pattern from input
    String remaining = input.replaceFirst(pattern, '').trim();
    
    // Clean up common filler words
    final fillers = ['to', 'the', 'a', 'an', 'my', 'that'];
    for (final filler in fillers) {
      if (remaining.startsWith('$filler ')) {
        remaining = remaining.substring(filler.length + 1).trim();
      }
    }
    
    return remaining.isNotEmpty ? remaining : null;
  }

  String? _extractTime(String input) {
    final timePatterns = {
      'morning': '08:00',
      'afternoon': '14:00',
      'evening': '18:00',
      'night': '21:00',
    };
    
    for (final entry in timePatterns.entries) {
      if (input.contains(entry.key)) {
        return entry.value;
      }
    }
    
    // Try to extract specific time
    final timeRegex = RegExp(r'(\d{1,2}):(\d{2})');
    final match = timeRegex.firstMatch(input);
    if (match != null) {
      return '${match.group(1)}:${match.group(2)}';
    }
    
    return null;
  }

  List<String> getSupportedCommands() {
    return _commandPatterns.keys.toList();
  }

  bool isCommandSupported(String input) {
    final normalized = input.toLowerCase();
    return _commandPatterns.values.any(
      (patterns) => patterns.any((p) => normalized.contains(p)),
    );
  }
}
