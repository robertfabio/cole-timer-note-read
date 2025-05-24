import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import '../providers/timer_provider.dart';
import '../models/study_session.dart';

class StatsScreen extends StatefulWidget {
  const StatsScreen({Key? key}) : super(key: key);

  @override
  _StatsScreenState createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: Text('Estatísticas'),
        centerTitle: false,
        bottom: TabBar(
          controller: _tabController,
          labelColor: theme.colorScheme.primary,
          unselectedLabelColor: theme.colorScheme.onSurfaceVariant,
          indicatorColor: theme.colorScheme.primary,
          tabs: [
            Tab(text: 'Diário'),
            Tab(text: 'Semanal'),
            Tab(text: 'Mensal'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildDailyStats(),
          _buildWeeklyStats(),
          _buildMonthlyStats(),
        ],
      ),
    );
  }
  
  Widget _buildDailyStats() {
    final timerProvider = Provider.of<TimerProvider>(context);
    final theme = Theme.of(context);
    
    final today = DateTime.now();
    final todayString = DateFormat('yyyy-MM-dd').format(today);
    
    // Filter sessions for today
    final todaySessions = timerProvider.studySessions.where((session) {
      final sessionDate = DateFormat('yyyy-MM-dd').format(session.date);
      return sessionDate == todayString;
    }).toList();
    
    // Calculate total study time for today
    final totalStudyTimeToday = todaySessions.fold<int>(
      0, (sum, session) => sum + session.duration);
    
    final hours = (totalStudyTimeToday / (1000 * 60 * 60)).floorToDouble();
    final minutes = ((totalStudyTimeToday % (1000 * 60 * 60)) / (1000 * 60)).floorToDouble();
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSummaryCard(
            icon: Icons.timer,
            title: 'Tempo Total de Estudo Hoje',
            value: '${hours.toInt()}h ${minutes.toInt()}min',
            subtitle: 'Total de ${todaySessions.length} sessões',
          ),
          
          const SizedBox(height: 24),
          
          Text(
            'Distribuição por Hora',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          
          const SizedBox(height: 16),
          
          if (todaySessions.isEmpty)
            _buildEmptyChart('Nenhuma sessão de estudo hoje')
          else
            SizedBox(
              height: 300,
              child: _buildHourlyBarChart(todaySessions),
            ),
            
          const SizedBox(height: 24),
          
          if (todaySessions.isNotEmpty) ...[
            Text(
              'Sessões de Hoje',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            
            const SizedBox(height: 16),
            
            ...todaySessions.map((session) => _buildSessionSummary(session)),
          ],
        ],
      ),
    );
  }
  
  Widget _buildWeeklyStats() {
    final timerProvider = Provider.of<TimerProvider>(context);
    final theme = Theme.of(context);
    
    final today = DateTime.now();
    final weekStart = today.subtract(Duration(days: today.weekday - 1));
    
    // Filter sessions for this week
    final thisWeekSessions = timerProvider.studySessions.where((session) {
      return session.date.isAfter(weekStart.subtract(const Duration(days: 1)));
    }).toList();
    
    // Calculate total study time for this week
    final totalStudyTimeThisWeek = thisWeekSessions.fold<int>(
      0, (sum, session) => sum + session.duration);
    
    final hours = (totalStudyTimeThisWeek / (1000 * 60 * 60)).floorToDouble();
    final minutes = ((totalStudyTimeThisWeek % (1000 * 60 * 60)) / (1000 * 60)).floorToDouble();
    
    // Average daily time
    final avgDailyMinutes = thisWeekSessions.isEmpty 
        ? 0.0 
        : (totalStudyTimeThisWeek / (1000 * 60)) / 7;
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSummaryCard(
            icon: Icons.calendar_today,
            title: 'Tempo Total Esta Semana',
            value: '${hours.toInt()}h ${minutes.toInt()}min',
            subtitle: 'Média de ${avgDailyMinutes.toStringAsFixed(0)} minutos por dia',
          ),
          
          const SizedBox(height: 24),
          
          Text(
            'Distribuição por Dia da Semana',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          
          const SizedBox(height: 16),
          
          if (thisWeekSessions.isEmpty)
            _buildEmptyChart('Nenhuma sessão de estudo esta semana')
          else
            SizedBox(
              height: 300,
              child: _buildWeeklyBarChart(thisWeekSessions),
            ),
        ],
      ),
    );
  }
  
  Widget _buildMonthlyStats() {
    final timerProvider = Provider.of<TimerProvider>(context);
    final theme = Theme.of(context);
    
    final today = DateTime.now();
    final monthStart = DateTime(today.year, today.month, 1);
    
    // Filter sessions for this month
    final thisMonthSessions = timerProvider.studySessions.where((session) {
      return session.date.isAfter(monthStart.subtract(const Duration(days: 1)));
    }).toList();
    
    // Calculate total study time for this month
    final totalStudyTimeThisMonth = thisMonthSessions.fold<int>(
      0, (sum, session) => sum + session.duration);
    
    final hours = (totalStudyTimeThisMonth / (1000 * 60 * 60)).floorToDouble();
    final minutes = ((totalStudyTimeThisMonth % (1000 * 60 * 60)) / (1000 * 60)).floorToDouble();
    
    // Days in month
    final daysInMonth = DateTime(today.year, today.month + 1, 0).day;
    
    // Average daily time
    final avgDailyMinutes = thisMonthSessions.isEmpty 
        ? 0.0 
        : (totalStudyTimeThisMonth / (1000 * 60)) / daysInMonth;
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSummaryCard(
            icon: Icons.event_note,
            title: 'Tempo Total Este Mês',
            value: '${hours.toInt()}h ${minutes.toInt()}min',
            subtitle: 'Média de ${avgDailyMinutes.toStringAsFixed(0)} minutos por dia',
          ),
          
          const SizedBox(height: 24),
          
          Text(
            'Distribuição por Semana',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          
          const SizedBox(height: 16),
          
          if (thisMonthSessions.isEmpty)
            _buildEmptyChart('Nenhuma sessão de estudo este mês')
          else
            SizedBox(
              height: 300,
              child: _buildMonthlyBarChart(thisMonthSessions),
            ),
        ],
      ),
    );
  }
  
  Widget _buildSummaryCard({
    required IconData icon,
    required String title,
    required String value,
    required String subtitle,
  }) {
    final theme = Theme.of(context);
    
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                size: 30,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.titleMedium,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onBackground.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildEmptyChart(String message) {
    final theme = Theme.of(context);
    
    return Container(
      height: 200,
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.bar_chart,
            size: 60,
            color: theme.colorScheme.onBackground.withOpacity(0.2),
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onBackground.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildHourlyBarChart(List<dynamic> sessions) {
    final theme = Theme.of(context);
    
    // Group sessions by hour
    final Map<int, num> hourlyData = {};
    
    // Initialize all hours with 0
    for (int i = 0; i < 24; i++) {
      hourlyData[i] = 0;
    }
    
    // Sum up durations for each hour
    for (final session in sessions) {
      final hour = session.date.hour;
      hourlyData[hour] = (hourlyData[hour] ?? 0) + session.duration;
    }
    
    // Convert to minutes
    hourlyData.forEach((hour, duration) {
      hourlyData[hour] = (duration / (1000 * 60)).round();
    });
    
    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: hourlyData.values.isEmpty ? 60 : (hourlyData.values.reduce((a, b) => a > b ? a : b) * 1.2),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              getTitlesWidget: (value, meta) {
                return Text(
                  '${value.toInt()}m',
                  style: TextStyle(
                    color: theme.colorScheme.onBackground.withOpacity(0.6),
                    fontSize: 10,
                  ),
                );
              },
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                return Text(
                  '${value.toInt()}h',
                  style: TextStyle(
                    color: theme.colorScheme.onBackground.withOpacity(0.6),
                    fontSize: 10,
                  ),
                );
              },
            ),
          ),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(show: false),
        gridData: FlGridData(
          drawHorizontalLine: true,
          horizontalInterval: 15,
          drawVerticalLine: false,
          getDrawingHorizontalLine: (value) {
            return FlLine(
              color: theme.colorScheme.onBackground.withOpacity(0.1),
              strokeWidth: 1,
            );
          },
        ),
        barGroups: hourlyData.entries.map((entry) {
          return BarChartGroupData(
            x: entry.key,
            barRods: [
              BarChartRodData(
                toY: entry.value.toDouble(),
                width: 16,
                color: theme.colorScheme.primary,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(4),
                  topRight: Radius.circular(4),
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }
  
  Widget _buildWeeklyBarChart(List<dynamic> sessions) {
    final theme = Theme.of(context);
    
    // Group sessions by day of week
    final Map<int, num> dailyData = {};
    
    // Initialize all days with 0 (1 = Monday, 7 = Sunday)
    for (int i = 1; i <= 7; i++) {
      dailyData[i] = 0;
    }
    
    // Sum up durations for each day
    for (final session in sessions) {
      final day = session.date.weekday;
      dailyData[day] = (dailyData[day] ?? 0) + session.duration;
    }
    
    // Convert to minutes
    dailyData.forEach((day, duration) {
      dailyData[day] = (duration / (1000 * 60)).round();
    });
    
    // Day names
    final dayNames = ['', 'Seg', 'Ter', 'Qua', 'Qui', 'Sex', 'Sáb', 'Dom'];
    
    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: dailyData.values.isEmpty ? 60 : (dailyData.values.reduce((a, b) => a > b ? a : b) * 1.2),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              getTitlesWidget: (value, meta) {
                return Text(
                  '${value.toInt()}m',
                  style: TextStyle(
                    color: theme.colorScheme.onBackground.withOpacity(0.6),
                    fontSize: 10,
                  ),
                );
              },
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                final day = value.toInt();
                return Text(
                  dayNames[day],
                  style: TextStyle(
                    color: theme.colorScheme.onBackground.withOpacity(0.6),
                    fontSize: 10,
                  ),
                );
              },
            ),
          ),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(show: false),
        gridData: FlGridData(
          drawHorizontalLine: true,
          horizontalInterval: 15,
          drawVerticalLine: false,
          getDrawingHorizontalLine: (value) {
            return FlLine(
              color: theme.colorScheme.onBackground.withOpacity(0.1),
              strokeWidth: 1,
            );
          },
        ),
        barGroups: dailyData.entries.map((entry) {
          return BarChartGroupData(
            x: entry.key,
            barRods: [
              BarChartRodData(
                toY: entry.value.toDouble(),
                width: 16,
                color: theme.colorScheme.primary,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(4),
                  topRight: Radius.circular(4),
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }
  
  Widget _buildMonthlyBarChart(List<dynamic> sessions) {
    final theme = Theme.of(context);
    
    // Group sessions by week of month
    final Map<int, num> weeklyData = {};
    
    // Initialize all weeks with 0
    for (int i = 1; i <= 5; i++) {
      weeklyData[i] = 0;
    }
    
    // Sum up durations for each week
    for (final session in sessions) {
      final day = session.date.day;
      final week = ((day - 1) ~/ 7) + 1;
      weeklyData[week] = (weeklyData[week] ?? 0) + session.duration;
    }
    
    // Convert to minutes
    weeklyData.forEach((week, duration) {
      weeklyData[week] = (duration / (1000 * 60)).round();
    });
    
    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: weeklyData.values.isEmpty ? 60 : (weeklyData.values.reduce((a, b) => a > b ? a : b) * 1.2),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              getTitlesWidget: (value, meta) {
                return Text(
                  '${value.toInt()}m',
                  style: TextStyle(
                    color: theme.colorScheme.onBackground.withOpacity(0.6),
                    fontSize: 10,
                  ),
                );
              },
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                final week = value.toInt();
                return Text(
                  'Sem $week',
                  style: TextStyle(
                    color: theme.colorScheme.onBackground.withOpacity(0.6),
                    fontSize: 10,
                  ),
                );
              },
            ),
          ),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(show: false),
        gridData: FlGridData(
          drawHorizontalLine: true,
          horizontalInterval: 15,
          drawVerticalLine: false,
          getDrawingHorizontalLine: (value) {
            return FlLine(
              color: theme.colorScheme.onBackground.withOpacity(0.1),
              strokeWidth: 1,
            );
          },
        ),
        barGroups: weeklyData.entries.map((entry) {
          return BarChartGroupData(
            x: entry.key,
            barRods: [
              BarChartRodData(
                toY: entry.value.toDouble(),
                width: 16,
                color: theme.colorScheme.primary,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(4),
                  topRight: Radius.circular(4),
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }
  
  Widget _buildSessionSummary(dynamic session) {
    final timerProvider = Provider.of<TimerProvider>(context, listen: false);
    final theme = Theme.of(context);
    
    final formattedTime = DateFormat('HH:mm').format(session.date);
    final formattedDuration = timerProvider.formatTime(session.duration);
    
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: theme.colorScheme.secondary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.access_time,
                color: theme.colorScheme.secondary,
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    session.name,
                    style: theme.textTheme.titleMedium,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 2),
                  Text(
                    formattedTime,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onBackground.withOpacity(0.6),
                    ),
                  ),
                ],
              ),
            ),
            Text(
              formattedDuration,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.secondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showGoalAchieved(BuildContext context, String meta) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.emoji_events_rounded, color: Theme.of(context).colorScheme.secondary, size: 28),
            SizedBox(width: 12),
            Expanded(child: Text('Meta $meta batida! Continue assim!')),
          ],
        ),
        backgroundColor: Theme.of(context).colorScheme.tertiary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        duration: Duration(seconds: 3),
      ),
    );
  }
} 