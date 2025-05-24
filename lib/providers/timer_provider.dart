import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../models/study_session.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../services/notification_service.dart';

enum TimerMode { focus, shortBreak, longBreak }
enum TimerState { idle, running, paused, completed }
enum NotificationType { pomodoroComplete, breakComplete, sessionComplete }

class TimerProvider extends ChangeNotifier {
  // Timer state
  TimerState _timerState = TimerState.idle;
  DateTime? _startTime;
  int _pausedTime = 0;
  int _totalStudyTime = 0;
  List<StudySession> _studySessions = [];
  TimerMode _timerMode = TimerMode.focus;
  int _pomodoroCount = 0;
  bool _isPomodoroActive = false;
  int _timeLeft = 0;
  int? _customTimerDuration;
  bool _isSaving = false;
  Map<TimerMode, int?> _customDurations = {
    TimerMode.focus: null,
    TimerMode.shortBreak: null,
    TimerMode.longBreak: null,
  };
  bool _isZenModeActive = false;
  DateTime? _zenModeStartTime;
  int _zenModeAccumulatedTime = 0;
  
  // Study consistency tracking
  int _currentStreak = 0;
  DateTime? _lastStudyDay;
  List<bool> _weeklyStudyDays = List.filled(7, false);
  Map<String, int> _monthlyStudyMinutes = {};
  
  // Timer
  Timer? _timer;
  
  // Progress value (0.0 to 1.0)
  double _progress = 0.0;
  
  // Storage keys
  static const String _timerStateKey = 'cole_timer_state';
  static const String _sessionsKey = 'cole_study_sessions';
  static const String _streakKey = 'cole_study_streak';
  
  // Notification service
  final NotificationService _notificationService = NotificationService();
  
  // Constructor
  TimerProvider() {
    _loadSavedData();
    _initializeNotifications();
  }
  
  // Getters
  TimerState get timerState => _timerState;
  bool get isRunning => _timerState == TimerState.running;
  int get totalStudyTime => _totalStudyTime;
  List<StudySession> get studySessions => _studySessions;
  TimerMode get timerMode => _timerMode;
  int get pomodoroCount => _pomodoroCount;
  bool get isPomodoroActive => _isPomodoroActive;
  int get timeLeft => _timeLeft;
  bool get isSaving => _isSaving;
  bool get isZenModeActive => _isZenModeActive;
  double get progress => _progress;
  
  // Streak getters
  int get currentStreak => _currentStreak;
  DateTime? get lastStudyDay => _lastStudyDay;
  List<bool> get weeklyStudyDays => _weeklyStudyDays;
  Map<String, int> get monthlyStudyMinutes => _monthlyStudyMinutes;
  
  // Default durations (in milliseconds)
  static const Map<TimerMode, int> _defaultDurations = {
    TimerMode.focus: 25 * 60 * 1000, // 25 minutes
    TimerMode.shortBreak: 5 * 60 * 1000, // 5 minutes
    TimerMode.longBreak: 15 * 60 * 1000, // 15 minutes
  };
  
  // Get current mode duration
  int _getCurrentModeDuration({TimerMode? mode}) {
    final currentMode = mode ?? _timerMode;
    return _customDurations[currentMode] ?? _defaultDurations[currentMode]!;
  }
  
  // Load saved data
  Future<void> _loadSavedData() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Load timer state
    final timerStateJson = prefs.getString(_timerStateKey);
    if (timerStateJson != null) {
      final timerState = jsonDecode(timerStateJson);
      
      _timerState = _stringToTimerState(timerState['timerState'] ?? 'idle');
      _pausedTime = timerState['pausedTime'] ?? 0;
      _totalStudyTime = timerState['totalStudyTime'] ?? 0;
      _timerMode = _stringToTimerMode(timerState['timerMode'] ?? 'focus');
      _pomodoroCount = timerState['pomodoroCount'] ?? 0;
      _isPomodoroActive = timerState['isPomodoroActive'] ?? false;
      _timeLeft = timerState['timeLeft'] ?? 0;
      _customTimerDuration = timerState['customTimerDuration'];
      
      if (timerState['customDurations'] != null) {
        final customDurations = Map<String, dynamic>.from(timerState['customDurations']);
        _customDurations = {
          TimerMode.focus: customDurations['focus'],
          TimerMode.shortBreak: customDurations['shortBreak'],
          TimerMode.longBreak: customDurations['longBreak'],
        };
      }
      
      _isZenModeActive = false; // Always start with zen mode off
      _zenModeAccumulatedTime = timerState['zenModeAccumulatedTime'] ?? 0;
    }
    
    // Load study sessions
    final sessionsJson = prefs.getString(_sessionsKey);
    if (sessionsJson != null) {
      final sessions = jsonDecode(sessionsJson) as List;
      _studySessions = sessions
          .map((session) => StudySession.fromJson(session))
          .toList();
    }
    
    // Load streak data
    final streakJson = prefs.getString(_streakKey);
    if (streakJson != null) {
      final streakData = jsonDecode(streakJson);
      _currentStreak = streakData['currentStreak'] ?? 0;
      _lastStudyDay = streakData['lastStudyDay'] != null 
          ? DateTime.parse(streakData['lastStudyDay'])
          : null;
      
      if (streakData['weeklyStudyDays'] != null) {
        final weeklyData = List<bool>.from(streakData['weeklyStudyDays']);
        _weeklyStudyDays = weeklyData;
      }
      
      if (streakData['monthlyStudyMinutes'] != null) {
        _monthlyStudyMinutes = Map<String, int>.from(streakData['monthlyStudyMinutes']);
      }
    }
    
    // Check if we need to reset streak due to missed days
    _checkAndUpdateStreak();
    
    notifyListeners();
  }
  
  // Check and update streak status
  void _checkAndUpdateStreak() {
    if (_lastStudyDay == null) return;
    
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final lastDay = DateTime(_lastStudyDay!.year, _lastStudyDay!.month, _lastStudyDay!.day);
    
    // Calculate difference in days
    final difference = today.difference(lastDay).inDays;
    
    // If more than one day has passed, reset streak
    if (difference > 1) {
      _currentStreak = 0;
      _saveStreakData();
    }
  }
  
  // Update streak when a study session is saved
  void _updateStreak() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    
    // If first study session or studied on a different day than last time
    if (_lastStudyDay == null || 
        today.difference(DateTime(
          _lastStudyDay!.year, 
          _lastStudyDay!.month, 
          _lastStudyDay!.day
        )).inDays >= 1) {
      
      // If consecutive day (yesterday)
      if (_lastStudyDay != null &&
          today.difference(DateTime(
            _lastStudyDay!.year, 
            _lastStudyDay!.month, 
            _lastStudyDay!.day
          )).inDays == 1) {
        _currentStreak++;
      } 
      // If first study session or streak was broken
      else if (_lastStudyDay == null || 
               today.difference(DateTime(
                 _lastStudyDay!.year, 
                 _lastStudyDay!.month, 
                 _lastStudyDay!.day
               )).inDays > 1) {
        _currentStreak = 1;
      }
      
      _lastStudyDay = today;
      
      // Update weekly study days
      final weekday = today.weekday - 1; // 0 = Monday, 6 = Sunday
      _weeklyStudyDays[weekday] = true;
      
      // Update monthly study minutes
      final monthKey = '${today.year}-${today.month.toString().padLeft(2, '0')}';
      final dayMinutes = _studySessions
          .where((s) => 
              s.date.year == today.year && 
              s.date.month == today.month && 
              s.date.day == today.day)
          .fold<int>(0, (sum, s) => sum + (s.duration ~/ (1000 * 60)));
      
      _monthlyStudyMinutes[monthKey] = (_monthlyStudyMinutes[monthKey] ?? 0) + dayMinutes;
      
      _saveStreakData();
    }
  }
  
  // Save streak data
  Future<void> _saveStreakData() async {
    final prefs = await SharedPreferences.getInstance();
    
    final streakData = {
      'currentStreak': _currentStreak,
      'lastStudyDay': _lastStudyDay?.toIso8601String(),
      'weeklyStudyDays': _weeklyStudyDays,
      'monthlyStudyMinutes': _monthlyStudyMinutes,
    };
    
    await prefs.setString(_streakKey, jsonEncode(streakData));
  }
  
  // Save timer state
  Future<void> _saveTimerState() async {
    final prefs = await SharedPreferences.getInstance();
    
    final timerState = {
      'timerState': _timerStateToString(_timerState),
      'pausedTime': _pausedTime,
      'totalStudyTime': _totalStudyTime,
      'timerMode': _timerModeToString(_timerMode),
      'pomodoroCount': _pomodoroCount,
      'isPomodoroActive': _isPomodoroActive,
      'timeLeft': _timeLeft,
      'customTimerDuration': _customTimerDuration,
      'customDurations': {
        'focus': _customDurations[TimerMode.focus],
        'shortBreak': _customDurations[TimerMode.shortBreak],
        'longBreak': _customDurations[TimerMode.longBreak],
      },
      'isZenModeActive': _isZenModeActive,
      'zenModeAccumulatedTime': _zenModeAccumulatedTime,
    };
    
    await prefs.setString(_timerStateKey, jsonEncode(timerState));
  }
  
  // Save study sessions
  Future<void> _saveStudySessions() async {
    final prefs = await SharedPreferences.getInstance();
    final sessionsJson = jsonEncode(_studySessions.map((s) => s.toJson()).toList());
    await prefs.setString(_sessionsKey, sessionsJson);
  }
  
  // Timer mode conversion helpers
  String _timerModeToString(TimerMode mode) {
    switch (mode) {
      case TimerMode.focus:
        return 'focus';
      case TimerMode.shortBreak:
        return 'shortBreak';
      case TimerMode.longBreak:
        return 'longBreak';
    }
  }
  
  TimerMode _stringToTimerMode(String mode) {
    switch (mode) {
      case 'shortBreak':
        return TimerMode.shortBreak;
      case 'longBreak':
        return TimerMode.longBreak;
      case 'focus':
      default:
        return TimerMode.focus;
    }
  }
  
  TimerState _stringToTimerState(String state) {
    switch (state) {
      case 'running':
        return TimerState.running;
      case 'paused':
        return TimerState.paused;
      case 'completed':
        return TimerState.completed;
      default:
        return TimerState.idle;
    }
  }
  
  String _timerStateToString(TimerState state) {
    switch (state) {
      case TimerState.running:
        return 'running';
      case TimerState.paused:
        return 'paused';
      case TimerState.completed:
        return 'completed';
      default:
        return 'idle';
    }
  }
  
  // Timer control methods with improved state management
  void startTimer() {
    if (_timerState == TimerState.running) return;
    
    _timerState = TimerState.running;
    _startTime = DateTime.now();
    
    _startTimerInterval();
    
    notifyListeners();
    _saveTimerState();
  }
  
  void pauseTimer() {
    if (_timerState != TimerState.running) return;
    
    _timerState = TimerState.paused;
    if (_startTime != null) {
      _pausedTime += DateTime.now().difference(_startTime!).inMilliseconds;
      _startTime = null;
    }
    
    _timer?.cancel();
    
    notifyListeners();
    _saveTimerState();
  }
  
  void resetTimer() {
    pauseTimer();
    
    _timerState = TimerState.idle;
    _startTime = null;
    _pausedTime = 0;
    _totalStudyTime = _customTimerDuration != null ? -_customTimerDuration! : 0;
    _progress = 0.0;
    
    notifyListeners();
    _saveTimerState();
  }
  
  // Improved Pomodoro handling
  void _handlePomodoroComplete() async {
    pauseTimer();
    
    TimerMode nextMode;
    if (_timerMode == TimerMode.focus) {
      _pomodoroCount++;
      await _showNotification(NotificationType.pomodoroComplete);
      // After 4 focus sessions, take a long break
      nextMode = (_pomodoroCount % 4 == 0) ? TimerMode.longBreak : TimerMode.shortBreak;
    } else {
      await _showNotification(NotificationType.breakComplete);
      // Notificação cartoon ao fim do descanso
      final notificationService = NotificationService();
      await notificationService.showNotification(
        title: 'Descanso finalizado!',
        body: 'Hora de voltar ao foco! Continue sua jornada.',
      );
      nextMode = TimerMode.focus;
    }
    _timerMode = nextMode;
    _timeLeft = _getCurrentModeDuration(mode: nextMode);
    _progress = 1.0;
    _pausedTime = 0;
    _startTime = null;
    
    notifyListeners();
    _saveTimerState();
  }
  
  // Improved session saving
  Future<void> saveSession(
    String name, {
    bool isScheduledSession = false,
    String? scheduledSessionId,
    String? category,
    List<String>? tags
  }) async {
    if (_totalStudyTime <= 0) return;
    
    _isSaving = true;
    notifyListeners();
    
    final session = StudySession(
      id: const Uuid().v4(),
      name: name.isNotEmpty ? name : "Sessão de Estudo",
      duration: _totalStudyTime.abs(),
      date: DateTime.now(),
      isScheduledSession: isScheduledSession,
      scheduledSessionId: scheduledSessionId,
      category: category,
      tags: tags,
    );
    
    _studySessions = [session, ..._studySessions];
    
    _timerState = TimerState.idle;
    _startTime = null;
    _pausedTime = 0;
    _totalStudyTime = 0;
    _customTimerDuration = null;
    
    // Update study streak
    _updateStreak();
    
    await _showNotification(NotificationType.sessionComplete);
    await _saveStudySessions();
    await _saveTimerState();
    
    _isSaving = false;
    notifyListeners();
  }
  
  void switchTimerMode(TimerMode mode) {
    pauseTimer();
    
    _timerMode = mode;
    _startTime = null;
    _pausedTime = 0;
    
    if (_isPomodoroActive) {
      _timeLeft = _getCurrentModeDuration();
      _progress = 1.0;
    }
    
    notifyListeners();
    _saveTimerState();
  }
  
  void togglePomodoroTimer() {
    pauseTimer();
    
    _isPomodoroActive = !_isPomodoroActive;
    _timerMode = TimerMode.focus;
    _startTime = null;
    _pausedTime = 0;
    _customTimerDuration = null;
    
    if (_isPomodoroActive) {
      _timeLeft = _getCurrentModeDuration();
      _progress = 1.0;
    } else {
      _progress = 0.0;
    }
    
    notifyListeners();
    _saveTimerState();
  }
  
  void updateTimeDuration(int duration) {
    if (duration <= 0) return;
    
    pauseTimer();
    
    if (_isPomodoroActive) {
      _customDurations[_timerMode] = duration;
      _timeLeft = duration;
    } else {
      _customTimerDuration = duration;
      _totalStudyTime = -duration;
    }
    
    _startTime = null;
    _pausedTime = 0;
    
    notifyListeners();
    _saveTimerState();
  }
  
  void toggleZenMode() {
    if (_isZenModeActive) {
      // Calculate accumulated time when deactivating
      if (_zenModeStartTime != null) {
        final additionalTime = DateTime.now().difference(_zenModeStartTime!).inMilliseconds;
        _zenModeAccumulatedTime += additionalTime;
      }
      _isZenModeActive = false;
      _zenModeStartTime = null;
    } else {
      _isZenModeActive = true;
      _zenModeStartTime = DateTime.now();
    }
    
    notifyListeners();
    _saveTimerState();
  }
  
  void markPomodoro() {
    if (_isPomodoroActive && _timerMode == TimerMode.focus) {
      _pomodoroCount++;
      
      // After focus session marked as complete, restart timer with the appropriate break
      TimerMode nextMode = (_pomodoroCount % 4 == 0) ? TimerMode.longBreak : TimerMode.shortBreak;
      
      // Update timer mode, reset timing values
      _timerMode = nextMode;
      _timeLeft = _getCurrentModeDuration(mode: nextMode);
      _progress = 1.0;
      _pausedTime = 0;
      _startTime = null; // Reset start time
      
      // Start the timer automatically if it was running
      if (_timerState == TimerState.running) {
        _startTime = DateTime.now();
        _startTimerInterval();
      }
      
      notifyListeners();
      _saveTimerState();
      
      // Show visual feedback or play sound if implemented
      // TODO: Add sound or haptic feedback here
    }
  }
  
  // Timer interval for updating the UI
  void _startTimerInterval() {
    _timer?.cancel();
    
    _timer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      if (_timerState != TimerState.running) {
        timer.cancel();
        return;
      }
      
      final now = DateTime.now();
      final elapsedSinceStart = _startTime != null 
          ? now.difference(_startTime!).inMilliseconds 
          : 0;
      final totalElapsed = _pausedTime + elapsedSinceStart;
      
      if (_isPomodoroActive) {
        final totalDuration = _getCurrentModeDuration();
        final newTimeLeft = totalDuration - totalElapsed;
        
        if (newTimeLeft <= 0) {
          _handlePomodoroComplete();
        } else {
          _timeLeft = newTimeLeft;
          _progress = newTimeLeft / totalDuration;
        }
      } else {
        if (_customTimerDuration != null) {
          _totalStudyTime = totalElapsed - _customTimerDuration!;
        } else {
          _totalStudyTime = totalElapsed;
        }
        
        // Update progress for countdown timer
        if (_customTimerDuration != null) {
          _progress = _totalStudyTime < 0 
              ? _totalStudyTime.abs() / _customTimerDuration! 
              : 0.0;
        } else {
          _progress = 0.0;
        }
      }
      
      notifyListeners();
    });
  }
  
  // Get next pomodoro mode
  TimerMode getNextPomodoroMode() {
    if (_timerMode == TimerMode.focus) {
      if ((_pomodoroCount + 1) % 4 == 0) {
        return TimerMode.longBreak;
      } else {
        return TimerMode.shortBreak;
      }
    } else {
      return TimerMode.focus;
    }
  }
  
  // Format the time as string
  String formatTime(int milliseconds) {
    final isNegative = milliseconds < 0;
    final absMillis = milliseconds.abs();
    
    final seconds = (absMillis / 1000).floor() % 60;
    final minutes = (absMillis / (1000 * 60)).floor() % 60;
    final hours = (absMillis / (1000 * 60 * 60)).floor();
    
    final hoursStr = hours > 0 ? '${hours.toString().padLeft(2, '0')}:' : '';
    final minutesStr = '${minutes.toString().padLeft(2, '0')}';
    final secondsStr = '${seconds.toString().padLeft(2, '0')}';
    
    return '${isNegative ? '-' : ''}$hoursStr$minutesStr:$secondsStr';
  }
  
  // Initialize notifications
  Future<void> _initializeNotifications() async {
    await _notificationService.initialize();
  }

  // Show notification based on type
  Future<void> _showNotification(NotificationType type) async {
    String title;
    String body;

    switch (type) {
      case NotificationType.pomodoroComplete:
        title = 'Pomodoro Concluído!';
        body = 'Hora de fazer uma pausa.';
        break;
      case NotificationType.breakComplete:
        title = 'Pausa Finalizada!';
        body = 'Hora de voltar aos estudos.';
        break;
      case NotificationType.sessionComplete:
        title = 'Sessão Concluída!';
        body = 'Parabéns por manter o foco!';
        break;
    }

    await _notificationService.showNotification(
      title: title,
      body: body,
      payload: type.toString(),
    );
  }
  
  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
} 