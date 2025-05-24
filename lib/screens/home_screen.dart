import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/timer_provider.dart';
import '../providers/navigation_provider.dart';
import '../models/study_session.dart';
import '../screens/history_screen.dart';
import 'settings_screen.dart';
import 'notifications_screen.dart';
import 'main_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final timerProvider = Provider.of<TimerProvider>(context);
    final navigationProvider = Provider.of<NavigationProvider>(context, listen: false);
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;
    
    // Get time of day to customize greeting
    final hour = DateTime.now().hour;
    String greeting = 'Boa noite';
    if (hour >= 5 && hour < 12) {
      greeting = 'Bom dia';
    } else if (hour >= 12 && hour < 18) {
      greeting = 'Boa tarde';
    }
    
    // Calculate total study time
    final totalDuration = timerProvider.studySessions.fold<int>(
        0, (prev, session) => prev + session.duration);
    final hours = (totalDuration / (1000 * 60 * 60)).floor();
    final minutes = ((totalDuration % (1000 * 60 * 60)) / (1000 * 60)).floor();
    
    final totalSessions = timerProvider.studySessions.length;
    
    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header cartoon ultra viciante
              Container(
                width: size.width,
                padding: const EdgeInsets.all(28),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      theme.colorScheme.primary.withOpacity(0.95),
                      theme.colorScheme.secondary.withOpacity(0.85),
                    ],
                  ),
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(40),
                    bottomRight: Radius.circular(40),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: theme.colorScheme.primary.withOpacity(0.08),
                      blurRadius: 24,
                      offset: Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Mascote cartoon animado
                        Stack(
                          alignment: Alignment.topRight,
                          children: [
                            CircleAvatar(
                              radius: 34,
                              backgroundColor: theme.colorScheme.secondary.withOpacity(0.25),
                              child: Icon(Icons.emoji_emotions_rounded, size: 48, color: theme.colorScheme.primary),
                            ),
                            // Balão de fala motivacional
                            Positioned(
                              right: -8,
                              top: 0,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.secondary,
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black12,
                                      blurRadius: 6,
                                      offset: Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Text(
                                  _motivationalMessage(),
                                  style: TextStyle(
                                    fontFamily: 'Segoe UI Light',
                                    color: Colors.black87,
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                greeting + ',',
                                style: TextStyle(
                                  fontFamily: 'Segoe UI Light',
                                  color: Colors.white,
                                  fontSize: 22,
                                  fontWeight: FontWeight.w300,
                                ),
                              ),
                              Text(
                                'Pronto para estudar?',
                                style: TextStyle(
                                  fontFamily: 'Segoe UI Light',
                                  color: Colors.white,
                                  fontSize: 28,
                                  fontWeight: FontWeight.w300,
                                  letterSpacing: 1.2,
                                ),
                              ),
                              const SizedBox(height: 10),
                              // Barra de XP cartoon
                              _buildXPBar(context, timerProvider),
                            ],
                          ),
                        ),
                        // Botão estatísticas
                        IconButton(
                          icon: Icon(Icons.bar_chart_rounded, color: Colors.white, size: 28),
                          tooltip: 'Estatísticas',
                          onPressed: () {
                            Navigator.pushNamed(context, '/stats');
                          },
                        ),
                        // Botão biblioteca
                        IconButton(
                          icon: Icon(Icons.menu_book_rounded, color: Colors.white, size: 28),
                          tooltip: 'Biblioteca',
                          onPressed: () {
                            navigationProvider.setIndex(3);
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    // Stats cartoon
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildStatItem(
                          icon: Icons.timer_rounded,
                          value: hours > 0 
                              ? '$hours h ${minutes > 0 ? "$minutes min" : ""}'
                              : '$minutes min',
                          label: 'Tempo Total',
                        ),
                        _buildStatItem(
                          icon: Icons.calendar_today_rounded,
                          value: '$totalSessions',
                          label: 'Sessões',
                        ),
                        _buildStatItem(
                          icon: Icons.local_fire_department_rounded,
                          value: '${timerProvider.currentStreak}',
                          label: 'Sequência',
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),
              // Botão cartoon de ação rápida
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 28),
                child: GestureDetector(
                  onTap: () => navigationProvider.setIndex(1),
                  child: Container(
                    decoration: BoxDecoration(
                      color: theme.colorScheme.secondary,
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: [
                        BoxShadow(
                          color: theme.colorScheme.secondary.withOpacity(0.18),
                          blurRadius: 12,
                          offset: Offset(0, 6),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 32),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.play_arrow_rounded, color: Colors.white, size: 32),
                        const SizedBox(width: 12),
                        Text(
                          'Iniciar Timer',
                          style: TextStyle(
                            fontFamily: 'Segoe UI Light',
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.w300,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 28),
              // Recentes cartoon
              Padding(
                padding: const EdgeInsets.all(28),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Sessões Recentes',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontFamily: 'Segoe UI Light',
                            fontWeight: FontWeight.w300,
                            fontSize: 22,
                          ),
                        ),
                        if (timerProvider.studySessions.isNotEmpty)
                          TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => HistoryScreen()),
                              );
                            },
                            child: Text('Ver todas'),
                            style: TextButton.styleFrom(
                              foregroundColor: theme.colorScheme.primary,
                              textStyle: TextStyle(
                                fontFamily: 'Segoe UI Light',
                                fontWeight: FontWeight.w300,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    if (timerProvider.studySessions.isEmpty)
                      _buildEmptySessionsState(context)
                    else
                      ...timerProvider.studySessions.take(3).map((session) {
                        return _buildSessionCard(context, session);
                      }),
                  ],
                ),
              ),
              // Streak cartoon
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 28),
                child: Container(
                  padding: const EdgeInsets.all(22),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.secondary.withOpacity(0.13),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.local_fire_department_rounded,
                        color: theme.colorScheme.secondary,
                        size: 32,
                      ),
                      const SizedBox(width: 16),
                      Text(
                        'Constância: ',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontFamily: 'Segoe UI Light',
                          fontWeight: FontWeight.w300,
                          color: theme.colorScheme.secondary,
                          fontSize: 18,
                        ),
                      ),
                      Text(
                        '${timerProvider.currentStreak} dias',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontFamily: 'Segoe UI Light',
                          fontWeight: FontWeight.w300,
                          color: theme.colorScheme.secondary,
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'fab_home',
        onPressed: () => navigationProvider.setIndex(1),
        child: Icon(Icons.play_arrow_rounded),
      ),
    );
  }
  
  Widget _buildStatItem({
    required IconData icon,
    required String value,
    required String label,
  }) {
    return Column(
      children: [
        Icon(
          icon,
          color: Colors.white,
          size: 24,
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.8),
            fontSize: 12,
          ),
        ),
      ],
    );
  }
  
  Widget _buildEmptySessionsState(BuildContext context) {
    final theme = Theme.of(context);
    final navigationProvider = Provider.of<NavigationProvider>(context, listen: false);
    
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 32),
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.hourglass_empty_outlined,
            size: 64,
            color: theme.colorScheme.primary.withOpacity(0.3),
          ),
          const SizedBox(height: 16),
          Text(
            'Nenhuma sessão de estudo',
            style: theme.textTheme.titleMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Inicie o cronômetro para começar a estudar',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.6),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () {
              // Navigate to Timer tab
              navigationProvider.setIndex(1);
            },
            icon: Icon(Icons.play_arrow_rounded),
            label: Text('Iniciar'),
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.primary,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildSessionCard(BuildContext context, StudySession session) {
    final theme = Theme.of(context);
    final timerProvider = Provider.of<TimerProvider>(context, listen: false);
    
    final formattedDuration = timerProvider.formatTime(session.duration);
    final formattedDate = _formatDate(session.date);
    
    return Card(
      margin: EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.access_time,
                color: theme.colorScheme.primary,
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    session.name,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 4),
                  Text(
                    formattedDate,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                formattedDuration,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inDays == 0) {
      // Format as "Hoje, 14:30"
      return 'Hoje, ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    } else if (difference.inDays == 1) {
      // Format as "Ontem, 14:30"
      return 'Ontem, ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    } else if (difference.inDays < 7) {
      // Format as "Terça, 14:30"
      final weekdays = ['Segunda', 'Terça', 'Quarta', 'Quinta', 'Sexta', 'Sábado', 'Domingo'];
      final weekday = weekdays[date.weekday - 1];
      return '$weekday, ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    } else {
      // Format as "12/05, 14:30"
      return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}, ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    }
  }
  
  Widget _buildStreakIndicator(BuildContext context, TimerProvider provider) {
    final theme = Theme.of(context);
    final daysOfWeek = ['S', 'T', 'Q', 'Q', 'S', 'S', 'D'];
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: List.generate(7, (index) {
        final isActive = index < provider.weeklyStudyDays.length ? provider.weeklyStudyDays[index] : false;
        return Column(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: isActive 
                    ? theme.colorScheme.secondary 
                    : theme.colorScheme.secondary.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.check,
                size: 16,
                color: isActive ? Colors.white : Colors.transparent,
              ),
            ),
            SizedBox(height: 4),
            Text(
              daysOfWeek[index],
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onBackground.withOpacity(0.7),
              ),
            ),
          ],
        );
      }),
    );
  }

  String _motivationalMessage() {
    final messages = [
      'Você é incrível! ✨',
      'Só mais uma sessão!',
      'Foco total! 🚀',
      'Estudar é poder!',
      'Continue assim!',
      'Orgulho de você!',
      'Meta do dia: bater recorde!',
      'Cada minuto conta!',
      'Você está evoluindo!',
      'Vamos juntos!',
    ];
    messages.shuffle();
    return messages.first;
  }

  Widget _buildXPBar(BuildContext context, dynamic timerProvider) {
    // Exemplo simples de barra de XP baseada em sessões
    final totalSessions = timerProvider.studySessions.length;
    final level = 1 + (totalSessions ~/ 10);
    final xp = totalSessions % 10;
    final percent = xp / 10.0;
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text('Nível $level', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
            const SizedBox(width: 8),
            Icon(Icons.star_rounded, color: theme.colorScheme.secondary, size: 18),
          ],
        ),
        const SizedBox(height: 4),
        Stack(
          children: [
            Container(
              height: 14,
              width: 120,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.18),
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            Container(
              height: 14,
              width: 120.0 * percent.toDouble(),
              decoration: BoxDecoration(
                color: theme.colorScheme.secondary,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: theme.colorScheme.secondary.withOpacity(0.4),
                    blurRadius: 6,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text('${(percent * 100).toInt()}% para o próximo nível', style: TextStyle(color: Colors.white, fontSize: 11)),
      ],
    );
  }
} 