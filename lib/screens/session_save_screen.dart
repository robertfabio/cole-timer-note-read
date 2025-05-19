import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/timer_provider.dart';
import '../providers/categories_provider.dart';

class SessionSaveScreen extends StatefulWidget {
  const SessionSaveScreen({Key? key}) : super(key: key);

  @override
  _SessionSaveScreenState createState() => _SessionSaveScreenState();
}

class _SessionSaveScreenState extends State<SessionSaveScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _newCategoryController = TextEditingController();
  final TextEditingController _newTagController = TextEditingController();
  final FocusNode _nameFocusNode = FocusNode();
  String _selectedCategory = 'Estudo';
  List<String> _selectedTags = [];

  @override
  void initState() {
    super.initState();
    _nameController.text = 'Sessão de Estudo';
    _nameFocusNode.requestFocus();
    
    // Initialize selected category with first available category
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final categoriesProvider = Provider.of<CategoriesProvider>(context, listen: false);
      if (categoriesProvider.categories.isNotEmpty) {
        setState(() {
          _selectedCategory = categoriesProvider.categories[0];
        });
      }
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _newCategoryController.dispose();
    _newTagController.dispose();
    _nameFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final timerProvider = Provider.of<TimerProvider>(context);
    final categoriesProvider = Provider.of<CategoriesProvider>(context);
    final theme = Theme.of(context);
    
    final studyTimeText = timerProvider.formatTime(timerProvider.totalStudyTime.abs());
    
    // Get keyboard height to adjust padding
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    
    return Scaffold(
      appBar: AppBar(
        title: Text('Salvar Sessão'),
        leading: IconButton(
          icon: Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      // Use resizeToAvoidBottomInset to prevent overflow
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        // Use SafeArea to respect system UI
        child: SingleChildScrollView(
          padding: EdgeInsets.only(
            left: 16.0, 
            right: 16.0, 
            top: 16.0,
            // Add extra padding when keyboard is visible
            bottom: 16.0 + (bottomInset > 0 ? 120 : 0),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Duration display
              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(vertical: 20),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Text(
                      'Duração Total',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: theme.colorScheme.onBackground,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      studyTimeText,
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ],
                ),
              ),
              
              SizedBox(height: 24),
              
              // Session name
              TextField(
                controller: _nameController,
                focusNode: _nameFocusNode,
                decoration: InputDecoration(
                  labelText: 'Nome da Sessão',
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: theme.colorScheme.surface,
                ),
                style: TextStyle(
                  fontSize: 16,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              
              SizedBox(height: 24),
              
              // Category selection
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    'Categoria',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.onBackground,
                    ),
                  ),
                  TextButton.icon(
                    onPressed: () {
                      _showAddCategoryDialog(context, categoriesProvider);
                    },
                    icon: Icon(Icons.add),
                    label: Text('Nova Categoria'),
                  ),
                ],
              ),
              SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: theme.colorScheme.outline.withOpacity(0.3),
                  ),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedCategory,
                    isExpanded: true,
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    icon: Icon(Icons.arrow_drop_down),
                    iconSize: 24,
                    elevation: 16,
                    style: TextStyle(
                      color: theme.colorScheme.onSurface,
                      fontSize: 16,
                    ),
                    onChanged: (String? newValue) {
                      if (newValue != null) {
                        setState(() {
                          _selectedCategory = newValue;
                        });
                      }
                    },
                    items: categoriesProvider.categories.map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(child: Text(value)),
                            if (categoriesProvider.categories.length > 1)
                              IconButton(
                                icon: Icon(Icons.delete_outline, size: 20),
                                onPressed: () {
                                  categoriesProvider.removeCategory(value);
                                  if (value == _selectedCategory && categoriesProvider.categories.isNotEmpty) {
                                    setState(() {
                                      _selectedCategory = categoriesProvider.categories[0];
                                    });
                                  }
                                },
                                padding: EdgeInsets.zero,
                                constraints: BoxConstraints(),
                                iconSize: 20,
                                splashRadius: 20,
                              ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
              
              SizedBox(height: 24),
              
              // Tags selection
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    'Tags',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.onBackground,
                    ),
                  ),
                  TextButton.icon(
                    onPressed: () {
                      _showAddTagDialog(context, categoriesProvider);
                    },
                    icon: Icon(Icons.add),
                    label: Text('Nova Tag'),
                  ),
                ],
              ),
              SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: categoriesProvider.tags.map((tag) {
                  final isSelected = _selectedTags.contains(tag);
                  return InputChip(
                    label: Text(tag),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        if (selected) {
                          _selectedTags.add(tag);
                        } else {
                          _selectedTags.remove(tag);
                        }
                      });
                    },
                    backgroundColor: theme.colorScheme.surface,
                    selectedColor: theme.colorScheme.primary.withOpacity(0.2),
                    checkmarkColor: theme.colorScheme.primary,
                    labelStyle: TextStyle(
                      color: isSelected
                          ? theme.colorScheme.primary
                          : theme.colorScheme.onSurface,
                    ),
                    deleteIcon: Icon(Icons.close, size: 16),
                    onDeleted: () {
                      _showDeleteTagConfirmation(context, categoriesProvider, tag);
                    },
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ),
      // Move the button to bottomNavigationBar to avoid overflow
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Container(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: () async {
              final name = _nameController.text.trim();
              if (name.isNotEmpty) {
                final session = await timerProvider.saveSession(
                  name,
                  category: _selectedCategory,
                  tags: _selectedTags.isNotEmpty ? _selectedTags : null,
                );
                Navigator.pop(context);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.primary,
              foregroundColor: theme.colorScheme.onPrimary,
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              'SALVAR SESSÃO',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }
  
  void _showAddCategoryDialog(BuildContext context, CategoriesProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Nova Categoria'),
        content: TextField(
          controller: _newCategoryController,
          decoration: InputDecoration(
            hintText: 'Nome da categoria',
            border: OutlineInputBorder(),
          ),
          textCapitalization: TextCapitalization.sentences,
          autofocus: true,
          onSubmitted: (_) {
            _addCategory(provider);
            Navigator.pop(context);
          },
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _newCategoryController.clear();
            },
            child: Text('CANCELAR'),
          ),
          FilledButton(
            onPressed: () {
              _addCategory(provider);
              Navigator.pop(context);
            },
            child: Text('ADICIONAR'),
          ),
        ],
      ),
    );
  }
  
  void _addCategory(CategoriesProvider provider) {
    final category = _newCategoryController.text.trim();
    if (category.isNotEmpty) {
      provider.addCategory(category);
      setState(() {
        _selectedCategory = category;
      });
      _newCategoryController.clear();
    }
  }
  
  void _showAddTagDialog(BuildContext context, CategoriesProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Nova Tag'),
        content: TextField(
          controller: _newTagController,
          decoration: InputDecoration(
            hintText: 'Nome da tag',
            border: OutlineInputBorder(),
          ),
          textCapitalization: TextCapitalization.sentences,
          autofocus: true,
          onSubmitted: (_) {
            _addTag(provider);
            Navigator.pop(context);
          },
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _newTagController.clear();
            },
            child: Text('CANCELAR'),
          ),
          FilledButton(
            onPressed: () {
              _addTag(provider);
              Navigator.pop(context);
            },
            child: Text('ADICIONAR'),
          ),
        ],
      ),
    );
  }
  
  void _addTag(CategoriesProvider provider) {
    final tag = _newTagController.text.trim();
    if (tag.isNotEmpty) {
      provider.addTag(tag);
      setState(() {
        _selectedTags.add(tag);
      });
      _newTagController.clear();
    }
  }
  
  void _showDeleteTagConfirmation(BuildContext context, CategoriesProvider provider, String tag) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Excluir tag?'),
        content: Text('Tem certeza que deseja excluir a tag "$tag"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('CANCELAR'),
          ),
          FilledButton(
            onPressed: () {
              provider.removeTag(tag);
              setState(() {
                _selectedTags.remove(tag);
              });
              Navigator.pop(context);
            },
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: Text('EXCLUIR'),
          ),
        ],
      ),
    );
  }
} 