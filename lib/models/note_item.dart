class CheckItemState {
  final String id;
  final String text;
  bool isCompleted;
  
  CheckItemState({
    required this.id,
    required this.text,
    this.isCompleted = false,
  });
  
  factory CheckItemState.fromJson(Map<String, dynamic> json) {
    return CheckItemState(
      id: json['id'],
      text: json['text'],
      isCompleted: json['isCompleted'] ?? false,
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'text': text,
      'isCompleted': isCompleted,
    };
  }
  
  CheckItemState copyWith({
    String? id,
    String? text,
    bool? isCompleted,
  }) {
    return CheckItemState(
      id: id ?? this.id,
      text: text ?? this.text,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}

class NoteItem {
  final String id;
  final String title;
  final String content;
  final List<CheckItemState> checkItems;
  final DateTime dateCreated;
  final DateTime dateModified;
  
  NoteItem({
    required this.id,
    required this.title,
    this.content = '',
    this.checkItems = const [],
    required this.dateCreated,
    required this.dateModified,
  });
  
  bool get hasCheckboxes => checkItems.isNotEmpty;
  
  factory NoteItem.fromJson(Map<String, dynamic> json) {
    return NoteItem(
      id: json['id'],
      title: json['title'],
      content: json['content'] ?? '',
      checkItems: json['checkItems'] != null 
          ? (json['checkItems'] as List)
              .map((item) => CheckItemState.fromJson(item))
              .toList()
          : [],
      dateCreated: DateTime.parse(json['dateCreated']),
      dateModified: DateTime.parse(json['dateModified']),
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'checkItems': checkItems.map((item) => item.toJson()).toList(),
      'dateCreated': dateCreated.toIso8601String(),
      'dateModified': dateModified.toIso8601String(),
    };
  }
  
  NoteItem copyWith({
    String? id,
    String? title,
    String? content,
    List<CheckItemState>? checkItems,
    DateTime? dateCreated,
    DateTime? dateModified,
  }) {
    return NoteItem(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      checkItems: checkItems ?? this.checkItems,
      dateCreated: dateCreated ?? this.dateCreated,
      dateModified: dateModified ?? this.dateModified,
    );
  }
} 