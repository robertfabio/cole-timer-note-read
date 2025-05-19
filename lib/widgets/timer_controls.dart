import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/timer_provider.dart';

class TimerControls extends StatelessWidget {
  final bool isFullScreen;
  
  const TimerControls({
    Key? key,
    this.isFullScreen = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final timerProvider = Provider.of<TimerProvider>(context);
    final theme = Theme.of(context);
    
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Column(
        children: [
          // Controles principais
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Botão de resetar
              _buildSecondaryButton(
                context,
                icon: Icons.replay_rounded,
                onPressed: timerProvider.resetTimer,
                tooltip: 'Reiniciar',
              ),
              
              const SizedBox(width: 24),
              
              // Botão de Play/Pause
              _buildPrimaryButton(
                context,
                icon: timerProvider.isRunning 
                    ? Icons.pause_rounded 
                    : Icons.play_arrow_rounded,
                onPressed: timerProvider.isRunning 
                    ? timerProvider.pauseTimer 
                    : timerProvider.startTimer,
                tooltip: timerProvider.isRunning ? 'Pausar' : 'Iniciar',
              ),
              
              const SizedBox(width: 24),
              
              // Botão de marcar/salvar
              _buildSecondaryButton(
                context,
                icon: Icons.flag_rounded,
                onPressed: () {
                  if (timerProvider.isPomodoroActive && timerProvider.timerMode == TimerMode.focus) {
                    timerProvider.markPomodoro();
                  } else if (!timerProvider.isPomodoroActive && timerProvider.totalStudyTime > 0) {
                    // Lógica para salvar sessão
                    _showSaveSessionDialog(context);
                  }
                },
                tooltip: timerProvider.isPomodoroActive ? 'Marcar Pomodoro' : 'Salvar Sessão',
                isDisabled: timerProvider.isPomodoroActive && timerProvider.timerMode != TimerMode.focus,
              ),
            ],
          ),
          
          if (timerProvider.isPomodoroActive && !isFullScreen) ...[
          const SizedBox(height: 24),
            // Contador de pomodoros completados
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                'Pomodoros completados: ${timerProvider.pomodoroCount}',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
  
  Widget _buildPrimaryButton(
    BuildContext context, {
    required IconData icon,
    required VoidCallback onPressed,
    required String tooltip,
  }) {
    final theme = Theme.of(context);
    
    return Material(
      shape: const CircleBorder(),
      elevation: 2,
      color: theme.colorScheme.primary,
      child: InkWell(
        onTap: onPressed,
        customBorder: const CircleBorder(),
        child: Tooltip(
          message: tooltip,
          child: Container(
            width: 70,
            height: 70,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
            ),
        child: Icon(
          icon,
              size: 36,
              color: theme.colorScheme.onPrimary,
            ),
          ),
        ),
      ),
    );
  }
  
  Widget _buildSecondaryButton(
    BuildContext context, {
    required IconData icon,
    required VoidCallback onPressed,
    required String tooltip,
    bool isDisabled = false,
  }) {
    final theme = Theme.of(context);
    
    final color = isDisabled 
        ? theme.colorScheme.surfaceVariant.withOpacity(0.5)
        : theme.colorScheme.surfaceVariant;
    
    final iconColor = isDisabled 
        ? theme.colorScheme.onSurfaceVariant.withOpacity(0.4)
        : theme.colorScheme.primary;
    
    return Material(
      shape: const CircleBorder(),
      elevation: 1,
      color: color,
      child: InkWell(
        onTap: isDisabled ? null : onPressed,
        customBorder: const CircleBorder(),
        child: Tooltip(
          message: tooltip,
          child: Container(
            width: 50,
            height: 50,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: 24,
              color: iconColor,
            ),
          ),
        ),
      ),
    );
  }
  
  void _showSaveSessionDialog(BuildContext context) {
    final TextEditingController nameController = TextEditingController(text: 'Sessão de Estudo');
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Salvar Sessão'),
        content: TextField(
          controller: nameController,
          decoration: const InputDecoration(
            labelText: 'Nome da sessão',
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              Provider.of<TimerProvider>(context, listen: false).saveSession(
                nameController.text.trim(),
              );
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Sessão salva com sucesso')),
              );
            },
            child: const Text('Salvar'),
          ),
        ],
      ),
    );
  }
} 