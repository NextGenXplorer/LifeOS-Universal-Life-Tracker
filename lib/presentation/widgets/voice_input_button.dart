import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class VoiceInputButton extends StatefulWidget {
  final Function(String) onResult;
  final VoidCallback? onStartListening;
  final VoidCallback? onStopListening;
  final bool isEnabled;

  const VoiceInputButton({
    super.key,
    required this.onResult,
    this.onStartListening,
    this.onStopListening,
    this.isEnabled = true,
  });

  @override
  State<VoiceInputButton> createState() => _VoiceInputButtonState();
}

class _VoiceInputButtonState extends State<VoiceInputButton>
    with SingleTickerProviderStateMixin {
  bool _isListening = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.isEnabled ? _toggleListening : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: _isListening ? 56 : 48,
        height: _isListening ? 56 : 48,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: _isListening ? AppColors.primary : AppColors.cardBackground,
          boxShadow: _isListening
              ? [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.4),
                    blurRadius: 12,
                    spreadRadius: 2,
                  ),
                ]
              : null,
        ),
        child: Icon(
          _isListening ? Icons.mic : Icons.mic_none,
          color: _isListening ? Colors.white : AppColors.textSecondary,
        ),
      ),
    );
  }

  void _toggleListening() async {
    if (_isListening) {
      _stopListening();
    } else {
      _startListening();
    }
  }

  void _startListening() {
    setState(() => _isListening = true);
    widget.onStartListening?.call();
    
    // This would integrate with VoiceCommandService in production
    // For demo, show a snackbar
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Voice recognition started...'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _stopListening() {
    setState(() => _isListening = false);
    widget.onStopListening?.call();
    
    // Simulate result for demo
    widget.onResult('Demo voice command');
  }
}

class VoiceCommandHelp extends StatelessWidget {
  const VoiceCommandHelp({super.key});

  @override
  Widget build(BuildContext context) {
    final commands = [
      {'command': 'Add habit [name]', 'description': 'Create a new habit'},
      {'command': 'Complete [habit]', 'description': 'Mark habit as done'},
      {'command': 'Add task [title]', 'description': 'Create a new task'},
      {'command': 'Log expense [amount] for [category]', 'description': 'Track spending'},
      {'command': 'What\'s my streak?', 'description': 'Show current streak'},
      {'command': 'Start focus mode', 'description': 'Begin focus timer'},
      {'command': 'Show insights', 'description': 'Open AI insights'},
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Voice Commands'),
        backgroundColor: Colors.transparent,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: commands.length,
        itemBuilder: (context, index) {
          final cmd = commands[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              leading: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.mic, color: AppColors.primary),
              ),
              title: Text(
                cmd['command']!,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              subtitle: Text(
                cmd['description']!,
                style: TextStyle(color: AppColors.textSecondary),
              ),
            ),
          );
        },
      ),
    );
  }
}
