import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../services/notification_service.dart';

class NotificationItem {
  final String id;
  final String title;
  final String message;
  final DateTime time;
  final bool read;
  final String type;

  NotificationItem({
    required this.id,
    required this.title,
    required this.message,
    required this.time,
    this.read = false,
    required this.type,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'message': message,
      'time': time.toIso8601String(),
      'read': read,
      'type': type,
    };
  }

  factory NotificationItem.fromJson(Map<String, dynamic> json) {
    return NotificationItem(
      id: json['id'],
      title: json['title'],
      message: json['message'],
      time: DateTime.parse(json['time']),
      read: json['read'] ?? false,
      type: json['type'],
    );
  }

  NotificationItem copyWith({
    String? id,
    String? title,
    String? message,
    DateTime? time,
    bool? read,
    String? type,
  }) {
    return NotificationItem(
      id: id ?? this.id,
      title: title ?? this.title,
      message: message ?? this.message,
      time: time ?? this.time,
      read: read ?? this.read,
      type: type ?? this.type,
    );
  }
}

class NotificationsProvider extends ChangeNotifier {
  List<NotificationItem> _notifications = [];
  bool _areNotificationsEnabled = true;
  Map<String, bool> _notificationTypeSettings = {
    'streak': true,
    'reminder': true,
    'achievement': true,
    'system': true,
  };

  static const String _notificationsKey = 'cole_app_notifications';
  static const String _settingsKey = 'cole_app_notification_settings';

  NotificationsProvider() {
    _loadNotifications();
    _loadSettings();
  }

  List<NotificationItem> get notifications => _notifications;
  bool get areNotificationsEnabled => _areNotificationsEnabled;
  Map<String, bool> get notificationTypeSettings => _notificationTypeSettings;

  Future<void> _loadNotifications() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? notificationsJson = prefs.getString(_notificationsKey);
      
      if (notificationsJson != null) {
        final List<dynamic> decodedNotifications = jsonDecode(notificationsJson);
        _notifications = decodedNotifications
            .map((json) => NotificationItem.fromJson(json))
            .toList();
      }
    } catch (e) {
      debugPrint('Erro ao carregar notificações: $e');
    }
    
    notifyListeners();
  }

  Future<void> _saveNotifications() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String notificationsJson = jsonEncode(
        _notifications.map((notification) => notification.toJson()).toList(),
      );
      await prefs.setString(_notificationsKey, notificationsJson);
    } catch (e) {
      debugPrint('Erro ao salvar notificações: $e');
    }
  }

  Future<void> _loadSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? settingsJson = prefs.getString(_settingsKey);
      
      if (settingsJson != null) {
        final Map<String, dynamic> settings = jsonDecode(settingsJson);
        _areNotificationsEnabled = settings['enabled'] ?? true;
        
        if (settings.containsKey('typeSettings')) {
          final Map<String, dynamic> typeSettings = settings['typeSettings'];
          typeSettings.forEach((key, value) {
            if (_notificationTypeSettings.containsKey(key)) {
              _notificationTypeSettings[key] = value;
            }
          });
        }
      }
    } catch (e) {
      debugPrint('Erro ao carregar configurações de notificações: $e');
    }
    
    notifyListeners();
  }

  Future<void> _saveSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final Map<String, dynamic> settings = {
        'enabled': _areNotificationsEnabled,
        'typeSettings': _notificationTypeSettings,
      };
      
      await prefs.setString(_settingsKey, jsonEncode(settings));
    } catch (e) {
      debugPrint('Erro ao salvar configurações de notificações: $e');
    }
  }

  void toggleNotificationsEnabled() {
    _areNotificationsEnabled = !_areNotificationsEnabled;
    _saveSettings();
    notifyListeners();
  }

  void toggleNotificationType(String type, bool value) {
    if (_notificationTypeSettings.containsKey(type)) {
      _notificationTypeSettings[type] = value;
      _saveSettings();
      notifyListeners();
    }
  }

  void addNotification({
    required String title,
    required String message,
    required String type,
  }) {
    // Only add notification if notifications are enabled and the type is enabled
    if (!_areNotificationsEnabled || !(_notificationTypeSettings[type] ?? false)) {
      return;
    }

    final newNotification = NotificationItem(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      message: message,
      time: DateTime.now(),
      type: type,
    );

    _notifications.insert(0, newNotification);
    _saveNotifications();
    notifyListeners();

    // Dispara notificação real do sistema para tipos relevantes
    if (type == 'reminder' || type == 'achievement' || type == 'streak') {
      NotificationService().showNotification(title: title, body: message);
    }
  }

  void markAsRead(String id) {
    final index = _notifications.indexWhere((notification) => notification.id == id);
    if (index != -1) {
      _notifications[index] = _notifications[index].copyWith(read: true);
      _saveNotifications();
      notifyListeners();
    }
  }

  void markAllAsRead() {
    _notifications = _notifications.map((notification) => 
      notification.copyWith(read: true)
    ).toList();
    
    _saveNotifications();
    notifyListeners();
  }

  void deleteNotification(String id) {
    _notifications.removeWhere((notification) => notification.id == id);
    _saveNotifications();
    notifyListeners();
  }

  void clearAllNotifications() {
    _notifications.clear();
    _saveNotifications();
    notifyListeners();
  }

  // Generate streak notification
  void generateStreakNotification(int streakCount) {
    if (streakCount > 0 && streakCount % 3 == 0) {
      addNotification(
        title: 'Sequência de estudos!',
        message: 'Você está estudando há $streakCount dias seguidos. Continue assim!',
        type: 'streak',
      );
    }
  }

  // Generate achievement notification
  void generateAchievementNotification(int studyTimeMinutes) {
    if (studyTimeMinutes >= 120) { // 2 hours or more
      addNotification(
        title: 'Novo recorde!',
        message: 'Você estudou ${studyTimeMinutes ~/ 60} horas hoje! Seu novo recorde diário.',
        type: 'achievement',
      );
    }
  }
} 