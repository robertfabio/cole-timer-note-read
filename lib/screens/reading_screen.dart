import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart' as path;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

class ReadingScreen extends StatefulWidget {
  const ReadingScreen({Key? key}) : super(key: key);

  @override
  State<ReadingScreen> createState() => _ReadingScreenState();
}

class _ReadingScreenState extends State<ReadingScreen> {
  List<ReadingItem> _readingItems = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadReadingItems();
  }

  Future<void> _loadReadingItems() async {
    setState(() => _isLoading = true);
    final prefs = await SharedPreferences.getInstance();
    final itemsJson = prefs.getStringList('reading_items') ?? [];
    _readingItems = itemsJson.map((item) => ReadingItem.fromJson(item)).toList();
    setState(() => _isLoading = false);
  }

  Future<void> _saveReadingItems() async {
    final prefs = await SharedPreferences.getInstance();
    final itemsJson = _readingItems.map((item) => item.toJson()).toList();
    await prefs.setStringList('reading_items', itemsJson);
  }

  Future<void> _pickFile() async {
    try {
      setState(() => _isLoading = true);

      // Pedir permissão de storage antes de abrir arquivo
      final status = await Permission.storage.request();
      if (!status.isGranted) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Permissão de armazenamento negada. Não é possível abrir arquivos.'),
              duration: Duration(seconds: 3),
            ),
          );
        }
        setState(() => _isLoading = false);
        return;
      }

      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'epub', 'mobi'],
        allowMultiple: false,
        withData: false,
      );

      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;
        if (file.path == null) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Não foi possível acessar o arquivo selecionado'),
                duration: Duration(seconds: 3),
              ),
            );
          }
          setState(() => _isLoading = false);
          return;
        }

        final filePath = file.path!;
        final fileName = file.name;
        final fileExtension = path.extension(filePath).toLowerCase();

        final item = ReadingItem(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          title: path.basenameWithoutExtension(fileName),
          filePath: filePath,
          extension: fileExtension,
          lastReadDate: DateTime.now(),
        );

        setState(() {
          _readingItems.insert(0, item);
        });
        await _saveReadingItems();

        if (mounted) {
          _showBookAdded(context, item.title);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao adicionar arquivo: $e'),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showBookAdded(BuildContext context, String title) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.menu_book_rounded, color: Theme.of(context).colorScheme.secondary, size: 28),
            SizedBox(width: 12),
            Expanded(child: Text('Livro "$title" adicionado!')),
          ],
        ),
        backgroundColor: Theme.of(context).colorScheme.secondary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        duration: Duration(seconds: 2),
      ),
    );
  }

  Future<Directory> _getAppDocumentsDirectory() async {
    final appDir = Directory('${Platform.environment['HOME']}/.cole/documents');
    if (!await appDir.exists()) {
      await appDir.create(recursive: true);
    }
    return appDir;
  }

  void _openReader(ReadingItem item) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ReaderScreen(item: item),
      ),
    );
  }

  Future<void> _deleteItem(ReadingItem item) async {
    try {
      final file = File(item.filePath);
      if (await file.exists()) {
        await file.delete();
      }
      setState(() {
        _readingItems.removeWhere((i) => i.id == item.id);
      });
      await _saveReadingItems();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao excluir arquivo: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        heroTag: 'fab_reading',
        onPressed: _pickFile,
        child: Icon(Icons.add),
        tooltip: 'Adicionar livro',
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _readingItems.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.menu_book,
                        size: 64,
                        color: theme.colorScheme.primary.withOpacity(0.5),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Nenhum livro adicionado',
                        style: theme.textTheme.titleLarge,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Toque no + para adicionar um livro',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _readingItems.length,
                  itemBuilder: (context, index) {
                    final item = _readingItems[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 16),
                      child: ListTile(
                        leading: Icon(
                          item.extension == '.pdf'
                              ? Icons.picture_as_pdf
                              : Icons.book,
                          color: theme.colorScheme.primary,
                        ),
                        title: Text(item.title),
                        subtitle: Text(
                          'Última leitura: ${_formatDate(item.lastReadDate)}',
                        ),
                        trailing: PopupMenuButton(
                          itemBuilder: (context) => [
                            PopupMenuItem(
                              child: const Text('Excluir'),
                              onTap: () => _deleteItem(item),
                            ),
                          ],
                        ),
                        onTap: () => _openReader(item),
                      ),
                    );
                  },
                ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }
}

class ReaderScreen extends StatelessWidget {
  final ReadingItem item;
  const ReaderScreen({Key? key, required this.item}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    final file = File(item.filePath);
    if (!file.existsSync()) {
      // Arquivo não existe mais
      Future.microtask(() {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Arquivo não encontrado. Ele pode ter sido removido do dispositivo.'),
            duration: const Duration(seconds: 3),
          ),
        );
      });
      return const SizedBox.shrink();
    }
    if (item.extension == '.pdf') {
      return Scaffold(
        appBar: AppBar(title: Text(item.title)),
        body: SfPdfViewer.file(file),
      );
    } else {
      return Scaffold(
        appBar: AppBar(title: Text(item.title)),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Text(
              'Formato não suportado para leitura nativa. Por favor, converta para PDF.',
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );
    }
  }
}

class ReadingItem {
  final String id;
  final String title;
  final String filePath;
  final String extension;
  final DateTime lastReadDate;
  ReadingItem({
    required this.id,
    required this.title,
    required this.filePath,
    required this.extension,
    required this.lastReadDate,
  });
  String toJson() {
    return '$id|$title|$filePath|$extension|${lastReadDate.toIso8601String()}';
  }
  factory ReadingItem.fromJson(String json) {
    final parts = json.split('|');
    return ReadingItem(
      id: parts[0],
      title: parts[1],
      filePath: parts[2],
      extension: parts[3],
      lastReadDate: DateTime.parse(parts[4]),
    );
  }
} 