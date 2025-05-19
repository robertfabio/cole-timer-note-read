import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../widgets/timer_display.dart';
import '../widgets/timer_controls.dart';

class FullscreenTimerScreen extends StatefulWidget {
  const FullscreenTimerScreen({Key? key}) : super(key: key);

  @override
  _FullscreenTimerScreenState createState() => _FullscreenTimerScreenState();
}

class _FullscreenTimerScreenState extends State<FullscreenTimerScreen> {
  @override
  void initState() {
    super.initState();
    // Set the device to landscape mode
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    // Hide system UI for full immersion
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  }

  @override
  void dispose() {
    // Reset to portrait mode when exiting
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    // Show system UI again
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.manual,
      overlays: [SystemUiOverlay.top, SystemUiOverlay.bottom],
    );
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      body: GestureDetector(
        onTap: () {
          Navigator.pop(context);
        },
        child: Container(
          width: double.infinity,
          height: double.infinity,
          child: Stack(
            children: [
              // Timer Display (centered)
              Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: TimerDisplay(isFullScreen: true),
                    ),
                    Expanded(
                      child: TimerControls(isFullScreen: true),
                    ),
                  ],
                ),
              ),
              
              // Exit button (top-right)
              Positioned(
                top: 16,
                right: 16,
                child: Container(
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceVariant.withOpacity(0.7),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: IconButton(
                    icon: Icon(Icons.fullscreen_exit),
                    color: theme.colorScheme.onSurfaceVariant,
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                ),
              ),
              
              // Tap to exit hint (bottom)
              Positioned(
                bottom: 24,
                left: 0,
                right: 0,
                child: Center(
                  child: Text(
                    'Toque na tela para sair',
                    style: TextStyle(
                      color: theme.colorScheme.onBackground.withOpacity(0.5),
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 