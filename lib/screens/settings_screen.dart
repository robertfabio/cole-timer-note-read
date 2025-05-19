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
      appBar: AppBar(
        title: Text('Configurações'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Appearance section
              _buildSectionHeader(context, 'Aparência'),
              
              Card(
                margin: EdgeInsets.symmetric(vertical: 8),
                child: Column(
                  children: [
                    // Theme toggle
                    SwitchListTile(
                      title: Text('Tema Escuro'),
                      subtitle: Text('Mudar para o tema escuro'),
                      value: themeProvider.isDarkMode,
                      onChanged: (value) {
                        themeProvider.setThemeMode(
                          value ? ThemeMode.dark : ThemeMode.light
                        );
                      },
                      secondary: Icon(
                        themeProvider.isDarkMode 
                            ? Icons.dark_mode 
                            : Icons.light_mode,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    Divider(),
                    // System theme option
                    ListTile(
                      title: Text('Usar tema do sistema'),
                      subtitle: Text('Segue o tema do seu dispositivo'),
                      leading: Icon(
                        Icons.settings_suggest,
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
              
              SizedBox(height: 16),
              
              // Timer settings
              _buildSectionHeader(context, 'Temporizador'),
              
              Card(
                margin: EdgeInsets.symmetric(vertical: 8),
                child: Column(
                  children: [
                    // Pomodoro duration
                    ListTile(
                      title: Text('Duração do Pomodoro'),
                      subtitle: Text('25 minutos (padrão)'),
                      leading: Icon(
                        Icons.timer_outlined,
                        color: theme.colorScheme.primary,
                      ),
                      trailing: Icon(Icons.chevron_right),
                      onTap: () {
                        _showDurationPicker(
                          context, 
                          'Duração do Pomodoro',
                          TimerMode.focus,
                          timerProvider
                        );
                      },
                    ),
                    Divider(),
                    // Short break duration
                    ListTile(
                      title: Text('Pausa Curta'),
                      subtitle: Text('5 minutos (padrão)'),
                      leading: Icon(
                        Icons.coffee_outlined,
                        color: theme.colorScheme.primary,
                      ),
                      trailing: Icon(Icons.chevron_right),
                      onTap: () {
                        _showDurationPicker(
                          context, 
                          'Duração da Pausa Curta',
                          TimerMode.shortBreak,
                          timerProvider
                        );
                      },
                    ),
                    Divider(),
                    // Long break duration
                    ListTile(
                      title: Text('Pausa Longa'),
                      subtitle: Text('15 minutos (padrão)'),
                      leading: Icon(
                        Icons.self_improvement_outlined,
                        color: theme.colorScheme.primary,
                      ),
                      trailing: Icon(Icons.chevron_right),
                      onTap: () {
                        _showDurationPicker(
                          context, 
                          'Duração da Pausa Longa',
                          TimerMode.longBreak,
                          timerProvider
                        );
                      },
                    ),
                    Divider(),
                    // Sound option
                    SwitchListTile(
                      title: Text('Som ao finalizar'),
                      subtitle: Text('Tocar som quando o timer terminar'),
                      value: false, // TODO: Implement sound feature
                      onChanged: (value) {
                        // TODO: Implement sound feature
                      },
                      secondary: Icon(
                        Icons.volume_up_outlined,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ],
                ),
              ),
              
              SizedBox(height: 16),
              
              // Notifications section
              _buildSectionHeader(context, 'Notificações'),
              
              Card(
                margin: EdgeInsets.symmetric(vertical: 8),
                child: Column(
                  children: [
                    // Enable notifications
                    SwitchListTile(
                      title: Text('Ativar Notificações'),
                      subtitle: Text('Receber lembretes e notificações'),
                      value: false, // TODO: Implement notifications
                      onChanged: (value) {
                        // TODO: Implement notifications
                      },
                      secondary: Icon(
                        Icons.notifications_outlined,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    Divider(),
                    // Daily reminders
                    ListTile(
                      title: Text('Lembrete Diário'),
                      subtitle: Text('Desativado'),
                      leading: Icon(
                        Icons.access_time,
                        color: theme.colorScheme.primary,
                      ),
                      trailing: Icon(Icons.chevron_right),
                      onTap: () {
                        // TODO: Implement time picker
                      },
                      enabled: false, // TODO: Link to notification toggle
                    ),
                  ],
                ),
              ),
              
              SizedBox(height: 16),
              
              // About section
              _buildSectionHeader(context, 'Sobre'),
              
              Card(
                margin: EdgeInsets.symmetric(vertical: 8),
                child: Column(
                  children: [
                    ListTile(
                      title: Text('Versão'),
                      subtitle: Text('0.3.2'),
                      leading: Icon(
                        Icons.info_outline,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    Divider(),
                    ListTile(
                      title: Text('Política de Privacidade'),
                      leading: Icon(
                        Icons.privacy_tip_outlined,
                        color: theme.colorScheme.primary,
                      ),
                      trailing: Icon(Icons.open_in_new),
                      onTap: () {
                        // TODO: Open privacy policy
                      },
                    ),
                    Divider(),
                    ListTile(
                      title: Text('Termos de Uso'),
                      leading: Icon(
                        Icons.article_outlined,
                        color: theme.colorScheme.primary,
                      ),
                      trailing: Icon(Icons.open_in_new),
                      onTap: () {
                        // TODO: Open terms of use
                      },
                    ),
                  ],
                ),
              ),
              
              SizedBox(height: 24),
              
              // Reset data option
              Center(
                child: OutlinedButton.icon(
                  onPressed: () {
                    _showResetConfirmation(context);
                  },
                  icon: Icon(Icons.restore),
                  label: Text('Redefinir Dados'),
                ),
              ),
              
              SizedBox(height: 24),
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
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Duração atualizada para $minutes minutos'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
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
} 