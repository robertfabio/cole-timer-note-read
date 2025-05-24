import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import '../providers/timer_provider.dart';

class TimerDisplay extends StatelessWidget {
  final bool isFullScreen;
  
  const TimerDisplay({
    Key? key,
    this.isFullScreen = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final timerProvider = Provider.of<TimerProvider>(context);
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;
    
    // Calculate the size based on the screen and fullscreen mode
    final circleSize = isFullScreen 
        ? size.width * 0.7
        : size.width * 0.6;
    
    final textSize = isFullScreen 
        ? 60.0
        : 48.0;
    
    final progressColor = timerProvider.isPomodoroActive
        ? timerProvider.timerMode == TimerMode.focus
            ? theme.colorScheme.primary
            : theme.colorScheme.secondary
        : theme.colorScheme.primary;
    
    final timeText = timerProvider.isPomodoroActive
        ? _formatTimeMinutesSeconds(timerProvider.timeLeft)
        : timerProvider.formatTime(timerProvider.totalStudyTime);
    
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularPercentIndicator(
            radius: circleSize / 2,
            lineWidth: 8.0,
            percent: timerProvider.progress,
            center: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
              timeText,
              style: TextStyle(
                fontSize: textSize,
                    fontWeight: FontWeight.w300,
                color: theme.colorScheme.onBackground,
                fontFamily: 'Segoe UI Light',
                    letterSpacing: -1.0,
                  ),
                ),
                if (timerProvider.isPomodoroActive)
                  Text(
                    _getModeText(timerProvider.timerMode),
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      color: progressColor,
                      letterSpacing: 0.5,
                    ),
              ),
              ],
            ),
            progressColor: progressColor,
            backgroundColor: theme.colorScheme.surfaceVariant.withOpacity(0.3),
            circularStrokeCap: CircularStrokeCap.round,
            animation: true,
            animateFromLastPercent: true,
          ),
          
          // Removida a exibição dos indicadores de pomodoro aqui,
          // agora eles estão na própria tela do timer
        ],
      ),
    );
  }
  
  String _formatTimeMinutesSeconds(int milliseconds) {
    final minutes = (milliseconds / (1000 * 60)).floor();
    final seconds = ((milliseconds % (1000 * 60)) / 1000).floor();
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }
  
  String _getModeText(TimerMode mode) {
    switch (mode) {
      case TimerMode.focus:
        return 'FOCO';
      case TimerMode.shortBreak:
        return 'PAUSA CURTA';
      case TimerMode.longBreak:
        return 'PAUSA LONGA';
    }
  }
} 