import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import '../providers/timer_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final timerProvider = Provider.of<TimerProvider>(context);
    final theme = Theme.of(context);
    
    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      appBar: AppBar(
        title: Text('Configurações', style: TextStyle(fontFamily: 'Segoe UI Light', fontWeight: FontWeight.w300)),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        backgroundColor: theme.colorScheme.primary.withOpacity(0.95),
        elevation: 0,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(22.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Aparência cartoon
              _buildSectionHeader(context, 'Aparência'),
              Card(
                margin: const EdgeInsets.symmetric(vertical: 10),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                elevation: 2,
                color: theme.colorScheme.surface,
                child: Column(
                  children: [
                    SwitchListTile(
                      title: Text('Tema Escuro', style: TextStyle(fontFamily: 'Segoe UI Light', fontWeight: FontWeight.w300)),
                      subtitle: Text('Mudar para o tema escuro', style: TextStyle(fontFamily: 'Segoe UI Light')),
                      value: themeProvider.isDarkMode,
                      onChanged: (value) {
                        themeProvider.setThemeMode(
                          value ? ThemeMode.dark : ThemeMode.light
                        );
                      },
                      secondary: Icon(
                        themeProvider.isDarkMode 
                            ? Icons.dark_mode_rounded 
                            : Icons.light_mode_rounded,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    const Divider(),
                    ListTile(
                      title: Text('Usar tema do sistema', style: TextStyle(fontFamily: 'Segoe UI Light', fontWeight: FontWeight.w300)),
                      subtitle: Text('Segue o tema do seu dispositivo', style: TextStyle(fontFamily: 'Segoe UI Light')),
                      leading: Icon(
                        Icons.settings_suggest_rounded,
                        color: theme.colorScheme.primary,
                      ),
                      trailing: Radio<ThemeMode>(
                        value: ThemeMode.system,
                        groupValue: themeProvider.themeMode,
                        onChanged: (value) {
                          if (value != null) {
                            themeProvider.setThemeMode(value);
                          }
                        },
                      ),
                      onTap: () {
                        themeProvider.setThemeMode(ThemeMode.system);
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              // Timer cartoon
              _buildSectionHeader(context, 'Temporizador'),
              Card(
                margin: const EdgeInsets.symmetric(vertical: 10),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                elevation: 2,
                color: theme.colorScheme.surface,
                child: Column(
                  children: [
                    ListTile(
                      title: Text('Duração do Pomodoro', style: TextStyle(fontFamily: 'Segoe UI Light', fontWeight: FontWeight.w300)),
                      subtitle: Text('25 minutos (padrão)', style: TextStyle(fontFamily: 'Segoe UI Light')),
                      leading: Icon(
                        Icons.timer_rounded,
                        color: theme.colorScheme.primary,
                      ),
                      trailing: Icon(Icons.chevron_right_rounded),
                      onTap: () {
                        _showDurationPicker(
                          context, 
                          'Duração do Pomodoro',
                          TimerMode.focus,
                          timerProvider
                        );
                      },
                    ),
                    const Divider(),
                    ListTile(
                      title: Text('Pausa Curta', style: TextStyle(fontFamily: 'Segoe UI Light', fontWeight: FontWeight.w300)),
                      subtitle: Text('5 minutos (padrão)', style: TextStyle(fontFamily: 'Segoe UI Light')),
                      leading: Icon(
                        Icons.coffee_rounded,
                        color: theme.colorScheme.primary,
                      ),
                      trailing: Icon(Icons.chevron_right_rounded),
                      onTap: () {
                        _showDurationPicker(
                          context, 
                          'Duração da Pausa Curta',
                          TimerMode.shortBreak,
                          timerProvider
                        );
                      },
                    ),
                    const Divider(),
                    ListTile(
                      title: Text('Pausa Longa', style: TextStyle(fontFamily: 'Segoe UI Light', fontWeight: FontWeight.w300)),
                      subtitle: Text('15 minutos (padrão)', style: TextStyle(fontFamily: 'Segoe UI Light')),
                      leading: Icon(
                        Icons.self_improvement_rounded,
                        color: theme.colorScheme.primary,
                      ),
                      trailing: Icon(Icons.chevron_right_rounded),
                      onTap: () {
                        _showDurationPicker(
                          context, 
                          'Duração da Pausa Longa',
                          TimerMode.longBreak,
                          timerProvider
                        );
                      },
                    ),
                    const Divider(),
                    SwitchListTile(
                      title: Text('Som ao finalizar', style: TextStyle(fontFamily: 'Segoe UI Light', fontWeight: FontWeight.w300)),
                      subtitle: Text('Tocar som quando o timer terminar', style: TextStyle(fontFamily: 'Segoe UI Light')),
                      value: false, // TODO: Implement sound feature
                      onChanged: (value) {},
                      secondary: Icon(
                        Icons.volume_up_rounded,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              // Notificações cartoon
              _buildSectionHeader(context, 'Notificações'),
              Card(
                margin: const EdgeInsets.symmetric(vertical: 10),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                elevation: 2,
                color: theme.colorScheme.surface,
                child: Column(
                  children: [
                    SwitchListTile(
                      title: Text('Ativar Notificações', style: TextStyle(fontFamily: 'Segoe UI Light', fontWeight: FontWeight.w300)),
                      subtitle: Text('Receber lembretes e notificações', style: TextStyle(fontFamily: 'Segoe UI Light')),
                      value: false, // TODO: Implement notifications
                      onChanged: (value) {},
                      secondary: Icon(
                        Icons.notifications_active_rounded,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    const Divider(),
                    ListTile(
                      title: Text('Lembrete Diário', style: TextStyle(fontFamily: 'Segoe UI Light', fontWeight: FontWeight.w300)),
                      subtitle: Text('Desativado', style: TextStyle(fontFamily: 'Segoe UI Light')),
                      leading: Icon(
                        Icons.access_time_rounded,
                        color: theme.colorScheme.primary,
                      ),
                      trailing: Icon(Icons.chevron_right_rounded),
                      onTap: () {},
                      enabled: false, // TODO: Link to notification toggle
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildSectionHeader(BuildContext context, String title) {
    final theme = Theme.of(context);
    
    return Padding(
      padding: const EdgeInsets.only(left: 8, bottom: 8),
      child: Text(
        title,
        style: theme.textTheme.titleMedium?.copyWith(
          color: theme.colorScheme.primary,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
  
  void _showDurationPicker(
    BuildContext context, 
    String title, 
    TimerMode mode,
    TimerProvider provider
  ) {
    final theme = Theme.of(context);
    int minutes = 25; // Default
    
    if (mode == TimerMode.shortBreak) {
      minutes = 5;
    } else if (mode == TimerMode.longBreak) {
      minutes = 15;
    }
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        content: StatefulBuilder(
          builder: (context, setState) {
            IconData modeIcon;
            Color modeColor;
            
            switch (mode) {
              case TimerMode.focus:
                modeIcon = Icons.timer_outlined;
                modeColor = theme.colorScheme.primary;
                break;
              case TimerMode.shortBreak:
                modeIcon = Icons.coffee_outlined;
                modeColor = theme.colorScheme.secondary;
                break;
              case TimerMode.longBreak:
                modeIcon = Icons.self_improvement_outlined;
                modeColor = theme.colorScheme.tertiary;
                break;
              default:
                modeIcon = Icons.timer_outlined;
                modeColor = theme.colorScheme.primary;
            }
            
            return ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: 400,
                minWidth: 300,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: modeColor.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      modeIcon,
                      color: modeColor,
                      size: 32,
                    ),
                  ),
                  SizedBox(height: 24),
                  Text(
                    '$minutes minutos',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Slider(
                    value: minutes.toDouble(),
                    min: 1,
                    max: mode == TimerMode.focus ? 60 : 30,
                    divisions: mode == TimerMode.focus ? 59 : 29,
                    activeColor: modeColor,
                    label: '$minutes min',
                    onChanged: (value) {
                      setState(() {
                        minutes = value.round();
                      });
                    },
                  ),
                  SizedBox(height: 8),
                  // Quick select buttons
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildQuickSelectButton(
                          context, 
                          minutes, 
                          mode == TimerMode.focus ? 25 : (mode == TimerMode.shortBreak ? 5 : 15), 
                          'Padrão', 
                          modeColor,
                          () {
                            setState(() {
                              minutes = mode == TimerMode.focus ? 25 : (mode == TimerMode.shortBreak ? 5 : 15);
                            });
                          }
                        ),
                        _buildQuickSelectButton(
                          context, 
                          minutes, 
                          mode == TimerMode.focus ? 30 : 10, 
                          mode == TimerMode.focus ? '30 min' : '10 min', 
                          modeColor,
                          () {
                            setState(() {
                              minutes = mode == TimerMode.focus ? 30 : 10;
                            });
                          }
                        ),
                        _buildQuickSelectButton(
                          context, 
                          minutes, 
                          mode == TimerMode.focus ? 45 : 20, 
                          mode == TimerMode.focus ? '45 min' : '20 min', 
                          modeColor,
                          () {
                            setState(() {
                              minutes = mode == TimerMode.focus ? 45 : 20;
                            });
                          }
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
        actionsPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        actions: [
          OutlinedButton(
            onPressed: () => Navigator.pop(context),
            child: Text('CANCELAR'),
          ),
          FilledButton(
            onPressed: () {
              // Convert minutes to milliseconds
              final durationMs = minutes * 60 * 1000;
              // Save to provider
              provider.updateTimeDuration(durationMs);
              Navigator.pop(context);
              
              // Show confirmation
              _showSettingsSaved(context);
            },
            child: Text('SALVAR'),
          ),
        ],
      ),
    );
  }
  
  Widget _buildQuickSelectButton(
    BuildContext context, 
    int currentValue, 
    int value, 
    String label, 
    Color color,
    VoidCallback onTap
  ) {
    final theme = Theme.of(context);
    final isSelected = currentValue == value;
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? color.withOpacity(0.2) : theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isSelected ? color : theme.colorScheme.outline.withOpacity(0.3),
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? color : theme.colorScheme.onSurface,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }
  
  void _showResetConfirmation(BuildContext context) {
    final theme = Theme.of(context);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Redefinir dados'),
        icon: Icon(
          Icons.warning_amber_rounded,
          color: Colors.orangeAccent,
          size: 36,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        content: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: 400,
            minWidth: 280,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Isso apagará todas as suas sessões de estudo e redefinirá todas as configurações.',
                style: theme.textTheme.bodyMedium,
              ),
              SizedBox(height: 12),
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.errorContainer.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: theme.colorScheme.error,
                      size: 20,
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Esta ação não pode ser desfeita.',
                        style: TextStyle(
                          color: theme.colorScheme.error,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        actionsPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        actions: [
          OutlinedButton(
            onPressed: () => Navigator.pop(context),
            child: Text('CANCELAR'),
          ),
          FilledButton(
            onPressed: () {
              // TODO: Implement data reset
              
              // Show success snackbar
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Dados redefinidos com sucesso'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
              
              Navigator.pop(context);
            },
            style: FilledButton.styleFrom(
              backgroundColor: theme.colorScheme.error,
            ),
            child: Text('REDEFINIR'),
          ),
        ],
      ),
    );
  }

  void _showSettingsSaved(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle_rounded, color: Theme.of(context).colorScheme.tertiary, size: 28),
            SizedBox(width: 12),
            Expanded(child: Text('Configuração salva!')),
          ],
        ),
        backgroundColor: Theme.of(context).colorScheme.tertiary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        duration: Duration(seconds: 2),
      ),
    );
  }
} 