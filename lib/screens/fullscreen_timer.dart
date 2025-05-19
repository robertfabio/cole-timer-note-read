import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/timer_provider.dart';
import 'dart:async';

class FullscreenTimer extends StatefulWidget {
  const FullscreenTimer({Key? key}) : super(key: key);

  @override
  _FullscreenTimerState createState() => _FullscreenTimerState();
}

class _FullscreenTimerState extends State<FullscreenTimer> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  bool _isControlsVisible = true;
  Timer? _hideControlsTimer;
  
  @override
  void initState() {
    super.initState();
    
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    
    // Set fullscreen and landscape mode
    _setLandscapeMode();
    
    _animationController.forward();
    _startHideControlsTimer();
  }

  Future<void> _setLandscapeMode() async {
    await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  }

  Future<void> _resetOrientation() async {
    await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  }

  @override
  void dispose() {
    // Restore system UI and portrait mode when screen is closed
    _resetOrientation();
    
    _animationController.dispose();
    _hideControlsTimer?.cancel();
    super.dispose();
  }
  
  void _startHideControlsTimer() {
    _hideControlsTimer?.cancel();
    _hideControlsTimer = Timer(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _isControlsVisible = false;
        });
        _animationController.reverse();
      }
    });
  }
  
  void _toggleControlsVisibility() {
    setState(() {
      _isControlsVisible = !_isControlsVisible;
    });
    
    if (_isControlsVisible) {
      _animationController.forward();
      _startHideControlsTimer();
    } else {
      _animationController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    final timerProvider = Provider.of<TimerProvider>(context);
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;
    
    // Format the time
    final String timerDisplay = timerProvider.isPomodoroActive
        ? _formatTimeMinutesSeconds(timerProvider.timeLeft)
        : timerProvider.formatTime(timerProvider.totalStudyTime);
    
    // Current mode
    final String modeText = timerProvider.isPomodoroActive
        ? _getModeText(timerProvider.timerMode)
        : 'Cronômetro';
    
    // Progress color based on mode
    final Color progressColor = timerProvider.isPomodoroActive
        ? timerProvider.timerMode == TimerMode.focus
            ? theme.colorScheme.primary
            : theme.colorScheme.secondary
        : theme.colorScheme.primary;
    
    return OrientationBuilder(
      builder: (context, orientation) {
        final isLandscape = orientation == Orientation.landscape;
        
        if (!isLandscape) {
          // Force landscape mode if not already in landscape
          _setLandscapeMode();
          return Center(
            child: CircularProgressIndicator(),
          );
        }
        
        return Scaffold(
          backgroundColor: theme.colorScheme.background,
          body: GestureDetector(
            onTap: _toggleControlsVisibility,
            behavior: HitTestBehavior.opaque,
            child: Stack(
              children: [
                // Subtle gradient background
                Container(
                  width: size.width,
                  height: size.height,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        theme.colorScheme.background,
                        theme.colorScheme.background.withOpacity(0.95),
                        timerProvider.timerMode == TimerMode.focus
                            ? theme.colorScheme.primary.withOpacity(0.03)
                            : theme.colorScheme.secondary.withOpacity(0.03),
                      ],
                    ),
                  ),
                ),
                
                // Timer display
                Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Timer with progress
                      SizedBox(
                        width: size.height * 0.7,
                        height: size.height * 0.7,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            // Background glow effect
                            AnimatedContainer(
                              duration: Duration(milliseconds: 500),
                              width: size.height * 0.7,
                              height: size.height * 0.7,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: progressColor.withOpacity(0.15),
                                    blurRadius: 40,
                                    spreadRadius: 5,
                                  ),
                                ],
                              ),
                            ),
                            
                            // Progress indicator
                            if (timerProvider.isPomodoroActive)
                              TweenAnimationBuilder<double>(
                                tween: Tween<double>(
                                  begin: 0,
                                  end: timerProvider.progress,
                                ),
                                duration: Duration(milliseconds: 300),
                                builder: (context, value, child) {
                                  return CircularProgressIndicator(
                                    value: value,
                                    strokeWidth: 8,
                                    backgroundColor: theme.colorScheme.surfaceVariant.withOpacity(0.2),
                                    valueColor: AlwaysStoppedAnimation<Color>(progressColor),
                                  );
                                },
                              ),
                            
                            // Timer text
                            Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                AnimatedSwitcher(
                                  duration: Duration(milliseconds: 300),
                                  transitionBuilder: (Widget child, Animation<double> animation) {
                                    return FadeTransition(
                                      opacity: animation,
                                      child: child,
                                    );
                                  },
                                  child: Text(
                                    timerDisplay,
                                    key: ValueKey<String>(timerDisplay),
                                    style: TextStyle(
                                      fontSize: size.height * 0.2,
                                      fontWeight: FontWeight.w200,
                                      letterSpacing: -2,
                                      color: theme.colorScheme.onSurface,
                                      fontFamily: 'Montserrat',
                                    ),
                                  ),
                                ),
                                SizedBox(height: 16),
                                AnimatedContainer(
                                  duration: Duration(milliseconds: 300),
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: progressColor.withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(50),
                                  ),
                                  child: Text(
                                    modeText.toUpperCase(),
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      letterSpacing: 1.2,
                                      color: progressColor,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      
                      // Controls for landscape mode
                      if (_isControlsVisible)
                        AnimatedBuilder(
                          animation: _animationController,
                          builder: (context, child) {
                            return FadeTransition(
                              opacity: _animationController,
                              child: SlideTransition(
                                position: Tween<Offset>(
                                  begin: Offset(0.2, 0.0),
                                  end: Offset.zero,
                                ).animate(_animationController),
                                child: child,
                              ),
                            );
                          },
                          child: Padding(
                            padding: const EdgeInsets.only(left: 48.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                _buildControlButton(
                                  context,
                                  icon: timerProvider.isRunning 
                                      ? Icons.pause_rounded 
                                      : Icons.play_arrow_rounded,
                                  size: 70,
                                  onPressed: timerProvider.isRunning 
                                      ? timerProvider.pauseTimer 
                                      : timerProvider.startTimer,
                                  color: progressColor,
                                ),
                                SizedBox(height: 32),
                                _buildControlButton(
                                  context,
                                  icon: Icons.replay_rounded,
                                  size: 54,
                                  onPressed: timerProvider.resetTimer,
                                  color: theme.colorScheme.surfaceVariant,
                                ),
                                SizedBox(height: 32),
                                _buildControlButton(
                                  context,
                                  icon: Icons.flag_rounded,
                                  size: 54,
                                  onPressed: () {
                                    if (timerProvider.isPomodoroActive && timerProvider.timerMode == TimerMode.focus) {
                                      timerProvider.markPomodoro();
                                    }
                                  },
                                  isDisabled: !timerProvider.isPomodoroActive || timerProvider.timerMode != TimerMode.focus,
                                  color: theme.colorScheme.surfaceVariant,
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                
                // Close button (top right)
                if (_isControlsVisible)
                  AnimatedBuilder(
                    animation: _animationController,
                    builder: (context, child) {
                      return FadeTransition(
                        opacity: _animationController,
                        child: child,
                      );
                    },
                    child: SafeArea(
                      child: Align(
                        alignment: Alignment.topRight,
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Material(
                            color: theme.colorScheme.background.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(30),
                            elevation: 0,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(30),
                              onTap: () {
                                Navigator.pop(context);
                              },
                              child: Container(
                                padding: const EdgeInsets.all(12),
                                child: Icon(
                                  Icons.close_rounded,
                                  color: theme.colorScheme.onSurface,
                                  size: 28,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
  
  Widget _buildControlButton(
    BuildContext context, {
    required IconData icon,
    required VoidCallback onPressed,
    required Color color,
    double size = 56,
    bool isDisabled = false,
  }) {
    final theme = Theme.of(context);
    final disabledColor = Colors.grey.withOpacity(0.3);
    
    return AnimatedContainer(
      duration: Duration(milliseconds: 200),
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: isDisabled ? disabledColor : color,
        shape: BoxShape.circle,
        boxShadow: isDisabled 
            ? [] 
            : [
                BoxShadow(
                  color: color.withOpacity(0.3),
                  blurRadius: 12,
                  offset: Offset(0, 4),
                ),
              ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isDisabled ? null : onPressed,
          customBorder: const CircleBorder(),
          splashColor: theme.colorScheme.onPrimary.withOpacity(0.1),
          highlightColor: theme.colorScheme.onPrimary.withOpacity(0.05),
          child: Center(
            child: Icon(
              icon,
              size: size * 0.5,
              color: isDisabled 
                  ? Colors.white.withOpacity(0.5) 
                  : Colors.white,
            ),
          ),
        ),
      ),
    );
  }
  
  String _formatTimeMinutesSeconds(int milliseconds) {
    final minutes = (milliseconds / (1000 * 60)).floor();
    final seconds = ((milliseconds % (1000 * 60)) / 1000).floor();
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }
  
  String _getModeText(TimerMode mode) {
    switch (mode) {
      case TimerMode.focus:
        return 'Foco';
      case TimerMode.shortBreak:
        return 'Pausa Curta';
      case TimerMode.longBreak:
        return 'Pausa Longa';
      default:
        return 'Timer';
    }
  }
} 