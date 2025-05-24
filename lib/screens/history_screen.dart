import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/timer_provider.dart';
import '../models/study_session.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final timerProvider = Provider.of<TimerProvider>(context);
    final theme = Theme.of(context);
    
    // Group sessions by date
    final Map<String, List<StudySession>> groupedSessions = {};
    
    for (final session in timerProvider.studySessions) {
      final date = DateFormat('yyyy-MM-dd').format(session.date);
      if (!groupedSessions.containsKey(date)) {
        groupedSessions[date] = [];
      }
      groupedSessions[date]!.add(session);
    }
    
    // Sort dates in descending order
    final sortedDates = groupedSessions.keys.toList()
      ..sort((a, b) => b.compareTo(a));
    
    return Scaffold(
      appBar: AppBar(
        title: Text('Histórico'),
        centerTitle: false,
      ),
      body: timerProvider.studySessions.isEmpty
          ? _buildEmptyState(context)
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: sortedDates.length,
              itemBuilder: (context, index) {
                final date = sortedDates[index];
                final sessions = groupedSessions[date]!;
                
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildDateHeader(context, date),
                    const SizedBox(height: 8),
                    ...sessions.map((session) => _buildSessionCard(context, session)),
                    const SizedBox(height: 16),
                  ],
                );
              },
            ),
    );
  }
  
  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);
    
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.history,
            size: 80,
            color: theme.colorScheme.primary.withOpacity(0.3),
          ),
          const SizedBox(height: 16),
          Text(
            'Sem histórico de sessões',
            style: theme.textTheme.titleLarge?.copyWith(
              color: theme.colorScheme.onBackground,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Suas sessões de estudo aparecerão aqui',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onBackground.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: Icon(Icons.timer),
            label: Text('Iniciar Cronômetro'),
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.primary,
              foregroundColor: theme.colorScheme.onPrimary,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildDateHeader(BuildContext context, String dateString) {
    final theme = Theme.of(context);
    
    final date = DateTime.parse(dateString);
    final now = DateTime.now();
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    
    String formattedDate;
    if (DateFormat('yyyy-MM-dd').format(now) == dateString) {
      formattedDate = 'Hoje';
    } else if (DateFormat('yyyy-MM-dd').format(yesterday) == dateString) {
      formattedDate = 'Ontem';
    } else {
      formattedDate = DateFormat('dd/MM/yyyy').format(date);
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceVariant,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        formattedDate,
        style: theme.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.bold,
          color: theme.colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
  
  Widget _buildSessionCard(BuildContext context, StudySession session) {
    final theme = Theme.of(context);
    final timerProvider = Provider.of<TimerProvider>(context, listen: false);
    
    final formattedTime = DateFormat('HH:mm').format(session.date);
    final formattedDuration = timerProvider.formatTime(session.duration);
    
    return Card(
      margin: const EdgeInsets.only(top: 8),
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    session.name,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Text(
                  formattedTime,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onBackground.withOpacity(0.6),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  Icons.timer,
                  size: 18,
                  color: theme.colorScheme.secondary,
                ),
                const SizedBox(width: 4),
                Text(
                  formattedDuration,
                  style: TextStyle(
                    color: theme.colorScheme.secondary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                if (session.category != null) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      session.category!,
                      style: TextStyle(
                        fontSize: 12,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ),
                ],
              ],
            ),
            if (session.tags != null && session.tags!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Wrap(
                spacing: 4,
                runSpacing: 4,
                children: session.tags!.map((tag) {
                  return Chip(
                    label: Text(
                      tag,
                      style: TextStyle(
                        fontSize: 12,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    padding: EdgeInsets.zero,
                    backgroundColor: theme.colorScheme.surfaceVariant,
                    visualDensity: VisualDensity.compact,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  );
                }).toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _showSessionDeleted(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.delete_rounded, color: Theme.of(context).colorScheme.error, size: 28),
            SizedBox(width: 12),
            Expanded(child: Text('Sessão excluída!')),
          ],
        ),
        backgroundColor: Theme.of(context).colorScheme.surface,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        duration: Duration(seconds: 2),
      ),
    );
  }
} 