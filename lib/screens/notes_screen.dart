import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/notes_provider.dart';
import '../models/note_item.dart';

class NotesScreen extends StatefulWidget {
  const NotesScreen({Key? key}) : super(key: key);

  @override
  _NotesScreenState createState() => _NotesScreenState();
}

class _NotesScreenState extends State<NotesScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  
  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final notesProvider = Provider.of<NotesProvider>(context);
    final theme = Theme.of(context);
    
    return Scaffold(
      body: notesProvider.notes.isEmpty 
          ? _buildEmptyState(theme)
          : _buildNotesList(notesProvider),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddNoteDialog(context),
        child: Icon(Icons.add),
        tooltip: 'Adicionar Nota',
      ),
    );
  }
  
  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.note_alt_outlined,
            size: 80,
            color: theme.colorScheme.primary.withOpacity(0.3),
          ),
          const SizedBox(height: 24),
          Text(
            'Nenhuma nota adicionada',
            style: theme.textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          Text(
            'Crie uma nota tocando no botão abaixo',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => _showAddNoteDialog(context),
            icon: Icon(Icons.add),
            label: Text('Nova Nota'),
          ),
        ],
      ),
    );
  }
  
  Widget _buildNotesList(NotesProvider notesProvider) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: notesProvider.notes.length,
      itemBuilder: (context, index) {
        final note = notesProvider.notes[index];
        return _buildNoteCard(note, notesProvider);
      },
    );
  }
  
  Widget _buildNoteCard(NoteItem note, NotesProvider notesProvider) {
    final theme = Theme.of(context);
    
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    note.title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.edit_outlined, size: 20),
                      constraints: BoxConstraints.tightFor(width: 36, height: 36),
                      padding: EdgeInsets.zero,
                      onPressed: () => _showEditNoteDialog(context, note),
                    ),
                    IconButton(
                      icon: Icon(Icons.delete_outline, size: 20),
                      constraints: BoxConstraints.tightFor(width: 36, height: 36),
                      padding: EdgeInsets.zero,
                      onPressed: () => _confirmDeleteNote(context, note, notesProvider),
                    ),
                  ],
                ),
              ],
            ),
            if (note.hasCheckboxes)
              ...note.checkItems.map((item) => _buildCheckItem(item, note, notesProvider)),
            if (!note.hasCheckboxes && note.content.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  note.content,
                  style: theme.textTheme.bodyMedium,
                  maxLines: 5,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: Text(
                _formatDate(note.dateCreated),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildCheckItem(CheckItemState item, NoteItem note, NotesProvider notesProvider) {
    final theme = Theme.of(context);
    
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Row(
        children: [
          Checkbox(
            value: item.isCompleted,
            onChanged: (value) {
              notesProvider.toggleCheckItem(note.id, item.id);
            },
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          Expanded(
            child: Text(
              item.text,
              style: theme.textTheme.bodyMedium?.copyWith(
                decoration: item.isCompleted 
                    ? TextDecoration.lineThrough 
                    : TextDecoration.none,
                color: item.isCompleted 
                    ? theme.colorScheme.onSurfaceVariant 
                    : theme.colorScheme.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  void _showAddNoteDialog(BuildContext context) {
    bool isTaskList = false;
    List<String> checkItems = [''];
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (BuildContext context) {
        final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
        final screenHeight = MediaQuery.of(context).size.height;
        
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return Container(
              constraints: BoxConstraints(
                maxHeight: screenHeight * 0.85,
              ),
              padding: EdgeInsets.only(
                bottom: keyboardHeight > 0 ? keyboardHeight : 16.0,
                left: 16,
                right: 16,
                top: 16,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header with close button
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Nova Nota',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      IconButton(
                        icon: Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                        padding: EdgeInsets.zero,
                        constraints: BoxConstraints(),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  // Content area with scrolling
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TextField(
                            controller: _titleController,
                            decoration: InputDecoration(
                              hintText: 'Título',
                              border: OutlineInputBorder(),
                            ),
                            textCapitalization: TextCapitalization.sentences,
                          ),
                          SizedBox(height: 16),
                          Row(
                            children: [
                              Text('Lista de Tarefas:', style: TextStyle(fontWeight: FontWeight.w500)),
                              SizedBox(width: 8),
                              Switch(
                                value: isTaskList,
                                onChanged: (value) {
                                  setState(() {
                                    isTaskList = value;
                                  });
                                },
                              ),
                            ],
                          ),
                          SizedBox(height: 16),
                          
                          !isTaskList
                            ? TextField(
                                controller: _contentController,
                                decoration: InputDecoration(
                                  hintText: 'Conteúdo da nota',
                                  border: OutlineInputBorder(),
                                ),
                                maxLines: 6,
                                textCapitalization: TextCapitalization.sentences,
                              )
                            : Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  for (int i = 0; i < checkItems.length; i++)
                                    Padding(
                                      padding: const EdgeInsets.only(bottom: 8),
                                      child: Row(
                                        children: [
                                          Expanded(
                                            child: TextField(
                                              decoration: InputDecoration(
                                                hintText: 'Item ${i + 1}',
                                                border: OutlineInputBorder(),
                                              ),
                                              controller: TextEditingController(text: checkItems[i]),
                                              onChanged: (value) {
                                                checkItems[i] = value;
                                              },
                                              textCapitalization: TextCapitalization.sentences,
                                            ),
                                          ),
                                          IconButton(
                                            icon: Icon(Icons.remove_circle_outline),
                                            onPressed: checkItems.length > 1
                                                ? () {
                                                    setState(() {
                                                      checkItems.removeAt(i);
                                                    });
                                                  }
                                                : null,
                                          ),
                                        ],
                                      ),
                                    ),
                                  SizedBox(height: 8),
                                  OutlinedButton.icon(
                                    icon: Icon(Icons.add),
                                    label: Text('Adicionar Item'),
                                    onPressed: () {
                                      setState(() {
                                        checkItems.add('');
                                      });
                                    },
                                  ),
                                ],
                              ),
                          SizedBox(height: 24),
                        ],
                      ),
                    ),
                  ),
                  // Action buttons fixed at bottom
                  Padding(
                    padding: EdgeInsets.only(top: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                            _titleController.clear();
                            _contentController.clear();
                          },
                          child: Text('CANCELAR'),
                        ),
                        SizedBox(width: 16),
                        FilledButton(
                          onPressed: () {
                            _addNote(isTaskList, checkItems);
                            Navigator.pop(context);
                          },
                          child: Text('SALVAR'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
  
  void _showEditNoteDialog(BuildContext context, NoteItem note) {
    _titleController.text = note.title;
    _contentController.text = note.content;
    bool isTaskList = note.hasCheckboxes;
    List<String> checkItems = note.checkItems.map((item) => item.text).toList();
    if (checkItems.isEmpty) checkItems.add('');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (BuildContext context) {
        final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
        final screenHeight = MediaQuery.of(context).size.height;
        
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return Container(
              constraints: BoxConstraints(
                maxHeight: screenHeight * 0.85,
              ),
              padding: EdgeInsets.only(
                bottom: keyboardHeight > 0 ? keyboardHeight : 16.0,
                left: 16,
                right: 16,
                top: 16,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header with close button
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Editar Nota',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      IconButton(
                        icon: Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                        padding: EdgeInsets.zero,
                        constraints: BoxConstraints(),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  // Content area with scrolling
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TextField(
                            controller: _titleController,
                            decoration: InputDecoration(
                              hintText: 'Título',
                              border: OutlineInputBorder(),
                            ),
                            textCapitalization: TextCapitalization.sentences,
                          ),
                          SizedBox(height: 16),
                          Row(
                            children: [
                              Text('Lista de Tarefas:', style: TextStyle(fontWeight: FontWeight.w500)),
                              SizedBox(width: 8),
                              Switch(
                                value: isTaskList,
                                onChanged: (value) {
                                  setState(() {
                                    isTaskList = value;
                                    if (value && checkItems.isEmpty) {
                                      checkItems.add('');
                                    }
                                  });
                                },
                              ),
                            ],
                          ),
                          SizedBox(height: 16),
                          
                          !isTaskList
                            ? TextField(
                                controller: _contentController,
                                decoration: InputDecoration(
                                  hintText: 'Conteúdo da nota',
                                  border: OutlineInputBorder(),
                                ),
                                maxLines: 6,
                                textCapitalization: TextCapitalization.sentences,
                              )
                            : Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  for (int i = 0; i < checkItems.length; i++)
                                    Padding(
                                      padding: const EdgeInsets.only(bottom: 8),
                                      child: Row(
                                        children: [
                                          Expanded(
                                            child: TextField(
                                              decoration: InputDecoration(
                                                hintText: 'Item ${i + 1}',
                                                border: OutlineInputBorder(),
                                              ),
                                              controller: TextEditingController(text: checkItems[i]),
                                              onChanged: (value) {
                                                checkItems[i] = value;
                                              },
                                              textCapitalization: TextCapitalization.sentences,
                                            ),
                                          ),
                                          IconButton(
                                            icon: Icon(Icons.remove_circle_outline),
                                            onPressed: checkItems.length > 1
                                                ? () {
                                                    setState(() {
                                                      checkItems.removeAt(i);
                                                    });
                                                  }
                                                : null,
                                          ),
                                        ],
                                      ),
                                    ),
                                  SizedBox(height: 8),
                                  OutlinedButton.icon(
                                    icon: Icon(Icons.add),
                                    label: Text('Adicionar Item'),
                                    onPressed: () {
                                      setState(() {
                                        checkItems.add('');
                                      });
                                    },
                                  ),
                                ],
                              ),
                          SizedBox(height: 24),
                        ],
                      ),
                    ),
                  ),
                  // Action buttons fixed at bottom
                  Padding(
                    padding: EdgeInsets.only(top: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: Text('CANCELAR'),
                        ),
                        SizedBox(width: 16),
                        FilledButton(
                          onPressed: () {
                            _saveEditedNote(note, isTaskList, checkItems);
                            Navigator.pop(context);
                          },
                          child: Text('SALVAR'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
  
  void _confirmDeleteNote(BuildContext context, NoteItem note, NotesProvider notesProvider) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Excluir Nota'),
          content: Text('Tem certeza que deseja excluir esta nota?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                notesProvider.deleteNote(note.id);
                Navigator.pop(context);
              },
              child: Text('Excluir'),
              style: TextButton.styleFrom(
                foregroundColor: Theme.of(context).colorScheme.error,
              ),
            ),
          ],
        );
      },
    );
  }
  
  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inDays == 0) {
      return 'Hoje';
    } else if (difference.inDays == 1) {
      return 'Ontem';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} dias atrás';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
  
  void _addNote(bool isTaskList, List<String> checkItems) {
    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('O título não pode ser vazio')),
      );
      return;
    }
    
    if (isTaskList) {
      checkItems.removeWhere((item) => item.trim().isEmpty);
      
      if (checkItems.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Adicione pelo menos um item')),
        );
        return;
      }
      
      final newCheckItems = checkItems.map((text) => 
        CheckItemState(
          id: UniqueKey().toString(),
          text: text,
          isCompleted: false,
        )
      ).toList();
      
      Provider.of<NotesProvider>(context, listen: false).addNote(
        title: _titleController.text,
        content: '',
        checkItems: newCheckItems,
      );
    } else {
      Provider.of<NotesProvider>(context, listen: false).addNote(
        title: _titleController.text,
        content: _contentController.text,
      );
    }
    
    _titleController.clear();
    _contentController.clear();
  }
  
  void _saveEditedNote(NoteItem note, bool isTaskList, List<String> checkItems) {
    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('O título não pode ser vazio')),
      );
      return;
    }
    
    if (isTaskList) {
      checkItems.removeWhere((item) => item.trim().isEmpty);
      
      if (checkItems.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Adicione pelo menos um item')),
        );
        return;
      }
      
      List<CheckItemState> newCheckItems = [];
      for (int i = 0; i < checkItems.length; i++) {
        final existingItemIndex = i < note.checkItems.length ? i : -1;
        if (existingItemIndex != -1 && note.checkItems[existingItemIndex].text == checkItems[i]) {
          newCheckItems.add(note.checkItems[existingItemIndex]);
        } else {
          newCheckItems.add(CheckItemState(
            id: UniqueKey().toString(),
            text: checkItems[i],
            isCompleted: false,
          ));
        }
      }
      
      Provider.of<NotesProvider>(context, listen: false).updateNote(
        noteId: note.id,
        title: _titleController.text,
        content: '',
        checkItems: newCheckItems,
      );
    } else {
      Provider.of<NotesProvider>(context, listen: false).updateNote(
        noteId: note.id,
        title: _titleController.text,
        content: _contentController.text,
        checkItems: [],
      );
    }
    
    _titleController.clear();
    _contentController.clear();
  }
} 