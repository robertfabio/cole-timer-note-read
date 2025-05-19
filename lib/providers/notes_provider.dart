import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/note_item.dart';

class NotesProvider extends ChangeNotifier {
  List<NoteItem> _notes = [];
  static const String _storageKey = 'cole_app_notes';
  bool _isLoading = false;
  
  NotesProvider() {
    _loadNotes();
  }
  
  bool get isLoading => _isLoading;
  List<NoteItem> get notes => _notes;
  
  Future<void> _loadNotes() async {
    _isLoading = true;
    notifyListeners();
    
    try {
      final prefs = await SharedPreferences.getInstance();
      final notesJson = prefs.getString(_storageKey);
      
      if (notesJson != null) {
        final List<dynamic> decodedNotes = jsonDecode(notesJson);
        _notes = decodedNotes.map((note) => NoteItem.fromJson(note)).toList();
        // Ordenar por data de modificação (mais recente primeiro)
        _notes.sort((a, b) => b.dateModified.compareTo(a.dateModified));
      }
    } catch (e) {
      debugPrint('Erro ao carregar notas: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  Future<void> _saveNotes() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final notesJson = jsonEncode(_notes.map((note) => note.toJson()).toList());
      await prefs.setString(_storageKey, notesJson);
    } catch (e) {
      debugPrint('Erro ao salvar notas: $e');
    }
  }
  
  void addNote({
    required String title,
    String content = '',
    List<CheckItemState> checkItems = const [],
  }) {
    final now = DateTime.now();
    final newNote = NoteItem(
      id: UniqueKey().toString(),
      title: title,
      content: content,
      checkItems: checkItems,
      dateCreated: now,
      dateModified: now,
    );
    
    _notes.insert(0, newNote);
    notifyListeners();
    _saveNotes();
  }
  
  void updateNote({
    required String noteId,
    required String title,
    String content = '',
    List<CheckItemState> checkItems = const [],
  }) {
    final index = _notes.indexWhere((note) => note.id == noteId);
    if (index != -1) {
      final now = DateTime.now();
      final updatedNote = _notes[index].copyWith(
        title: title,
        content: content,
        checkItems: checkItems,
        dateModified: now,
      );
      
      _notes[index] = updatedNote;
      // Reordenar após atualização
      _notes.sort((a, b) => b.dateModified.compareTo(a.dateModified));
      notifyListeners();
      _saveNotes();
    }
  }
  
  void deleteNote(String noteId) {
    _notes.removeWhere((note) => note.id == noteId);
    notifyListeners();
    _saveNotes();
  }
  
  void toggleCheckItem(String noteId, String itemId) {
    final noteIndex = _notes.indexWhere((note) => note.id == noteId);
    if (noteIndex != -1) {
      final note = _notes[noteIndex];
      final itemIndex = note.checkItems.indexWhere((item) => item.id == itemId);
      
      if (itemIndex != -1) {
        // Criar uma nova lista de checkItems com o item atualizado
        final updatedCheckItems = List<CheckItemState>.from(note.checkItems);
        updatedCheckItems[itemIndex] = updatedCheckItems[itemIndex].copyWith(
          isCompleted: !updatedCheckItems[itemIndex].isCompleted,
        );
        
        // Atualizar a nota com a nova lista
        _notes[noteIndex] = note.copyWith(
          checkItems: updatedCheckItems,
          dateModified: DateTime.now(),
        );
        
        notifyListeners();
        _saveNotes();
      }
    }
  }
  
  NoteItem? getNote(String noteId) {
    final index = _notes.indexWhere((note) => note.id == noteId);
    return index != -1 ? _notes[index] : null;
  }
} 