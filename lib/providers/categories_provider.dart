import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class CategoriesProvider extends ChangeNotifier {
  List<String> _categories = [
    'Estudo',
    'Trabalho',
    'Pessoal',
    'Projeto',
    'Leitura',
  ];
  
  List<String> _tags = [
    'Importante',
    'Urgente',
    'Faculdade',
    'Trabalho',
    'Concentração',
    'Pesquisa',
    'Línguas',
    'Programação',
    'Matemática',
    'Leitura',
  ];
  
  static const String _categoriesKey = 'cole_app_categories';
  static const String _tagsKey = 'cole_app_tags';
  
  CategoriesProvider() {
    _loadData();
  }
  
  List<String> get categories => _categories;
  List<String> get tags => _tags;
  
  Future<void> _loadData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      final categoriesJson = prefs.getString(_categoriesKey);
      if (categoriesJson != null) {
        final List<dynamic> decodedCategories = jsonDecode(categoriesJson);
        _categories = decodedCategories.cast<String>();
      }
      
      final tagsJson = prefs.getString(_tagsKey);
      if (tagsJson != null) {
        final List<dynamic> decodedTags = jsonDecode(tagsJson);
        _tags = decodedTags.cast<String>();
      }
    } catch (e) {
      debugPrint('Erro ao carregar categorias e tags: $e');
    }
    
    notifyListeners();
  }
  
  Future<void> _saveData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      await prefs.setString(_categoriesKey, jsonEncode(_categories));
      await prefs.setString(_tagsKey, jsonEncode(_tags));
    } catch (e) {
      debugPrint('Erro ao salvar categorias e tags: $e');
    }
  }
  
  void addCategory(String category) {
    if (category.isNotEmpty && !_categories.contains(category)) {
      _categories.add(category);
      _saveData();
      notifyListeners();
    }
  }
  
  void removeCategory(String category) {
    if (_categories.length > 1) { // Manter pelo menos uma categoria
      _categories.remove(category);
      _saveData();
      notifyListeners();
    }
  }
  
  void addTag(String tag) {
    if (tag.isNotEmpty && !_tags.contains(tag)) {
      _tags.add(tag);
      _saveData();
      notifyListeners();
    }
  }
  
  void removeTag(String tag) {
    _tags.remove(tag);
    _saveData();
    notifyListeners();
  }
} 