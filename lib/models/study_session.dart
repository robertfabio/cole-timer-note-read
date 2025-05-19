class StudySession {
  final String id;
  final String name;
  final int duration; // Duration in milliseconds
  final DateTime date;
  final List<String>? tags;
  final String? category;
  final bool isScheduledSession;
  final String? scheduledSessionId;

  StudySession({
    required this.id,
    required this.name,
    required this.duration,
    required this.date,
    this.tags,
    this.category,
    this.isScheduledSession = false,
    this.scheduledSessionId,
  });

  // Create from JSON
  factory StudySession.fromJson(Map<String, dynamic> json) {
    return StudySession(
      id: json['id'],
      name: json['name'],
      duration: json['duration'],
      date: DateTime.parse(json['date']),
      tags: json['tags'] != null 
          ? List<String>.from(json['tags'])
          : null,
      category: json['category'],
      isScheduledSession: json['isScheduledSession'] ?? false,
      scheduledSessionId: json['scheduledSessionId'],
    );
  }

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'duration': duration,
      'date': date.toIso8601String(),
      'tags': tags,
      'category': category,
      'isScheduledSession': isScheduledSession,
      'scheduledSessionId': scheduledSessionId,
    };
  }
} 