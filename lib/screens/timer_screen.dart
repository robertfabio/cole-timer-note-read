import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/timer_provider.dart';
import '../widgets/timer_display.dart';
import '../widgets/timer_controls.dart';
import 'fullscreen_timer.dart';
import 'session_save_screen.dart';

class TimerScreen extends StatelessWidget {
  const TimerScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final timerProvider = Provider.of<TimerProvider>(context);
    final theme = Theme.of(context);
    
    // Only show save button if timer has run for some time
    final canSave = timerProvider.totalStudyTime.abs() > 0;
    
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 16),
              
              // Timer mode selector
              _buildTimerModeSelector(context, timerProvider),
              
              // Timer display area - use Expanded to prevent overflow
              Expanded(
                child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                      // Timer display
                    TimerDisplay(),
                      
                      const SizedBox(height: 16),
                      
                      // Fullscreen mode button
                      OutlinedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => FullscreenTimer(),
                            ),
                          );
                        },
                        icon: Icon(Icons.fullscreen),
                        label: Text('Modo Tela Cheia'),
                        style: OutlinedButton.styleFrom(
                          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        ),
                      ),
                  ],
                ),
                ),
              ),
              
              // Timer controls at the bottom with fixed height
              Container(
                padding: EdgeInsets.only(bottom: 16),
                child: TimerControls(),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: canSave && !timerProvider.isRunning
          ? FloatingActionButton(
              heroTag: 'fab_timer',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SessionSaveScreen(),
                  ),
                );
              },
              backgroundColor: theme.colorScheme.tertiary,
              child: Icon(
                Icons.save,
                color: theme.colorScheme.onTertiary,
              ),
            )
          : null,
    );
  }
  
  Widget _buildTimerModeSelector(BuildContext context, TimerProvider timerProvider) {
    final theme = Theme.of(context);
    
    return Column(
      children: [
        // Pomodoro toggle
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Técnica Pomodoro',
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(width: 16),
            Switch(
              value: timerProvider.isPomodoroActive,
              onChanged: (_) => timerProvider.togglePomodoroTimer(),
              activeColor: theme.colorScheme.primary,
            ),
          ],
        ),
        
        const SizedBox(height: 8),
        
        // Timer modes (only shown if Pomodoro is active)
        if (timerProvider.isPomodoroActive)
          Container(
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
              borderRadius: BorderRadius.circular(16),
            ),
            padding: const EdgeInsets.all(8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildModeButton(
                  context,
                  timerProvider,
                  TimerMode.focus,
                  'Foco',
                  Icons.psychology_outlined,
                ),
                _buildModeButton(
                  context,
                  timerProvider,
                  TimerMode.shortBreak,
                  'Pausa Curta',
                  Icons.coffee_outlined,
                ),
                _buildModeButton(
                  context,
                  timerProvider,
                  TimerMode.longBreak,
                  'Pausa Longa',
                  Icons.self_improvement_outlined,
                ),
              ],
            ),
          ),
      ],
    );
  }
  
  Widget _buildModeButton(
    BuildContext context,
    TimerProvider timerProvider,
    TimerMode mode,
    String label,
    IconData icon,
  ) {
    final theme = Theme.of(context);
    final isSelected = timerProvider.timerMode == mode;
    
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: TextButton(
          onPressed: () => timerProvider.switchTimerMode(mode),
          style: TextButton.styleFrom(
            backgroundColor: isSelected 
                ? theme.colorScheme.primary.withOpacity(0.2)
                : Colors.transparent,
            padding: const EdgeInsets.symmetric(vertical: 8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                color: isSelected ? theme.colorScheme.primary : theme.colorScheme.onSurfaceVariant,
                size: 20,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? theme.colorScheme.primary : theme.colorScheme.onSurfaceVariant,
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showPomodoroComplete(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.emoji_events_rounded, color: Theme.of(context).colorScheme.secondary, size: 28),
            SizedBox(width: 12),
            Expanded(child: Text('Parabéns! Pomodoro concluído! 🎉')),
          ],
        ),
        backgroundColor: Theme.of(context).colorScheme.secondary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        duration: Duration(seconds: 3),
      ),
    );
  }
} 