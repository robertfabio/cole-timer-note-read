import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/notifications_provider.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final notificationsProvider = Provider.of<NotificationsProvider>(context);
    final notifications = notificationsProvider.notifications;

    return Scaffold(
      appBar: AppBar(
        title: Text('Notificações'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          if (notifications.isNotEmpty)
            IconButton(
              icon: Icon(Icons.check_circle_outline),
              tooltip: 'Marcar todas como lidas',
              onPressed: () {
                notificationsProvider.markAllAsRead();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Todas as notificações marcadas como lidas')),
                );
              },
            ),
          IconButton(
            icon: Icon(Icons.add_alert),
            tooltip: 'Testar notificação',
            onPressed: () => _testNotification(context, notificationsProvider),
          ),
          IconButton(
            icon: Icon(Icons.settings_outlined),
            tooltip: 'Configurações de notificação',
            onPressed: () {
              _showNotificationSettings(context, notificationsProvider);
            },
          ),
        ],
      ),
      body: notifications.isEmpty
          ? _buildEmptyState(context)
          : _buildNotificationsList(context, notificationsProvider),
      floatingActionButton: notifications.isNotEmpty
          ? FloatingActionButton(
              mini: true,
              onPressed: () {
                _showClearConfirmation(context, notificationsProvider);
              },
              backgroundColor: theme.colorScheme.error,
              child: Icon(Icons.delete_sweep),
              tooltip: 'Limpar todas',
            )
          : null,
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);
    
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.notifications_outlined,
              size: 60,
              color: theme.colorScheme.primary.withOpacity(0.7),
            ),
          ),
          SizedBox(height: 24),
          Text(
            'Nenhuma notificação',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onBackground.withOpacity(0.8),
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              'As notificações sobre seu progresso e lembretes aparecerão aqui',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onBackground.withOpacity(0.6),
              ),
              textAlign: TextAlign.center,
            ),
          ),
          SizedBox(height: 32),
          ElevatedButton.icon(
            icon: Icon(Icons.add_alert),
            label: Text('Criar notificação de teste'),
            onPressed: () => _testNotification(context, Provider.of<NotificationsProvider>(context, listen: false)),
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationsList(BuildContext context, NotificationsProvider provider) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      itemCount: provider.notifications.length,
      itemBuilder: (context, index) {
        final notification = provider.notifications[index];
        return _buildNotificationCard(context, notification, provider);
      },
    );
  }

  Widget _buildNotificationCard(
      BuildContext context, NotificationItem notification, NotificationsProvider provider) {
    final theme = Theme.of(context);
    final timeAgo = _getTimeAgo(notification.time);
    
    IconData icon;
    Color iconColor;
    
    switch (notification.type) {
      case 'streak':
        icon = Icons.local_fire_department_rounded;
        iconColor = Colors.deepOrange;
        break;
      case 'reminder':
        icon = Icons.access_time_rounded;
        iconColor = theme.colorScheme.primary;
        break;
      case 'achievement':
        icon = Icons.emoji_events_rounded;
        iconColor = Colors.amber;
        break;
      case 'system':
        icon = Icons.info_rounded;
        iconColor = theme.colorScheme.tertiary;
        break;
      default:
        icon = Icons.notifications_rounded;
        iconColor = theme.colorScheme.primary;
    }
    
    return Dismissible(
      key: Key(notification.id),
      background: Container(
        color: theme.colorScheme.error.withOpacity(0.7),
        alignment: Alignment.centerRight,
        padding: EdgeInsets.only(right: 20),
        margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Icon(
          Icons.delete_rounded,
          color: Colors.white,
          size: 28,
        ),
      ),
      direction: DismissDirection.endToStart,
      onDismissed: (direction) {
        provider.deleteNotification(notification.id);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            behavior: SnackBarBehavior.floating,
            margin: EdgeInsets.only(bottom: 10, left: 10, right: 10),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            content: Text('Notificação removida'),
            action: SnackBarAction(
              label: 'DESFAZER',
              onPressed: () {
                // Functionality to undo would go here
              },
            ),
          ),
        );
      },
      child: AnimatedContainer(
        duration: Duration(milliseconds: 300),
        margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: notification.read 
              ? theme.colorScheme.surface 
              : theme.colorScheme.primary.withOpacity(0.05),
          borderRadius: BorderRadius.circular(16),
          boxShadow: notification.read 
              ? [] 
              : [
                  BoxShadow(
                    color: theme.colorScheme.primary.withOpacity(0.1),
                    blurRadius: 10,
                    offset: Offset(0, 2),
                  ),
                ],
          border: Border.all(
            color: notification.read 
                ? theme.colorScheme.outline.withOpacity(0.1) 
                : theme.colorScheme.primary.withOpacity(0.2),
            width: 1,
          ),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () {
              if (!notification.read) {
                provider.markAsRead(notification.id);
              }
            },
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: iconColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(
                      icon,
                      color: iconColor,
                      size: 28,
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                notification.title,
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: notification.read ? FontWeight.normal : FontWeight.bold,
                                ),
                              ),
                            ),
                            if (!notification.read)
                              Container(
                                width: 10,
                                height: 10,
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.primary,
                                  shape: BoxShape.circle,
                                ),
                              ),
                          ],
                        ),
                        SizedBox(height: 4),
                        Text(
                          notification.message,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onBackground.withOpacity(0.8),
                          ),
                        ),
                        SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(
                              Icons.access_time_filled_rounded,
                              size: 12,
                              color: theme.colorScheme.onBackground.withOpacity(0.5),
                            ),
                            SizedBox(width: 4),
                            Text(
                              timeAgo,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onBackground.withOpacity(0.5),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Material(
                    color: Colors.transparent,
                    shape: CircleBorder(),
                    child: InkWell(
                      customBorder: CircleBorder(),
                      onTap: () {
                        _showNotificationOptions(context, notification, provider);
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Icon(
                          Icons.more_vert,
                          color: theme.colorScheme.onBackground.withOpacity(0.5),
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
  
  String _getTimeAgo(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);
    
    if (difference.inMinutes < 1) {
      return 'Agora';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} min atrás';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} h atrás';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} dias atrás';
    } else {
      return '${time.day}/${time.month}/${time.year}';
    }
  }
  
  void _showNotificationOptions(
      BuildContext context, NotificationItem notification, NotificationsProvider provider) {
    final theme = Theme.of(context);
    
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(notification.read 
                    ? Icons.mark_email_unread_outlined 
                    : Icons.mark_email_read_outlined),
                title: Text(notification.read 
                    ? 'Marcar como não lida' 
                    : 'Marcar como lida'),
                onTap: () {
                  Navigator.pop(context);
                  if (notification.read) {
                    // This would require adding a new method to toggle read state
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Esta funcionalidade será implementada em breve')),
                    );
                  } else {
                    provider.markAsRead(notification.id);
                  }
                },
              ),
              ListTile(
                leading: Icon(Icons.delete_outline),
                title: Text('Excluir notificação'),
                onTap: () {
                  Navigator.pop(context);
                  provider.deleteNotification(notification.id);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Notificação excluída')),
                  );
                },
              ),
              ListTile(
                leading: Icon(Icons.block),
                title: Text('Desativar este tipo de notificação'),
                onTap: () {
                  Navigator.pop(context);
                  provider.toggleNotificationType(notification.type, false);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Notificações do tipo "${notification.type}" desativadas')),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }
  
  void _showClearConfirmation(BuildContext context, NotificationsProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Limpar todas as notificações'),
        content: Text('Tem certeza que deseja excluir todas as notificações? Esta ação não pode ser desfeita.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('CANCELAR'),
          ),
          FilledButton(
            onPressed: () {
              provider.clearAllNotifications();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Todas as notificações foram excluídas')),
              );
            },
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: Text('LIMPAR'),
          ),
        ],
      ),
    );
  }
  
  void _showNotificationSettings(BuildContext context, NotificationsProvider provider) {
    final theme = Theme.of(context);
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Configurações de Notificação',
                      style: theme.textTheme.titleLarge,
                    ),
                    SizedBox(height: 16),
                    SwitchListTile(
                      title: Text('Ativar Notificações'),
                      subtitle: Text('Receber notificações do app'),
                      value: provider.areNotificationsEnabled,
                      onChanged: (value) {
                        setState(() {
                          provider.toggleNotificationsEnabled();
                        });
                      },
                      secondary: Icon(
                        provider.areNotificationsEnabled 
                            ? Icons.notifications_active 
                            : Icons.notifications_off,
                        color: provider.areNotificationsEnabled 
                            ? theme.colorScheme.primary 
                            : theme.colorScheme.outline,
                      ),
                    ),
                    Divider(),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Text(
                        'Tipos de Notificação',
                        style: theme.textTheme.titleMedium,
                      ),
                    ),
                    CheckboxListTile(
                      title: Text('Sequências de Estudo'),
                      subtitle: Text('Notificações sobre seu progresso diário'),
                      value: provider.notificationTypeSettings['streak'] ?? true,
                      onChanged: provider.areNotificationsEnabled
                          ? (value) {
                              setState(() {
                                provider.toggleNotificationType('streak', value ?? true);
                              });
                            }
                          : null,
                      secondary: Icon(
                        Icons.local_fire_department,
                        color: theme.colorScheme.secondary,
                      ),
                    ),
                    CheckboxListTile(
                      title: Text('Lembretes'),
                      subtitle: Text('Lembretes para manter sua rotina de estudos'),
                      value: provider.notificationTypeSettings['reminder'] ?? true,
                      onChanged: provider.areNotificationsEnabled
                          ? (value) {
                              setState(() {
                                provider.toggleNotificationType('reminder', value ?? true);
                              });
                            }
                          : null,
                      secondary: Icon(
                        Icons.access_time,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    CheckboxListTile(
                      title: Text('Conquistas'),
                      subtitle: Text('Notificações sobre recordes e conquistas'),
                      value: provider.notificationTypeSettings['achievement'] ?? true,
                      onChanged: provider.areNotificationsEnabled
                          ? (value) {
                              setState(() {
                                provider.toggleNotificationType('achievement', value ?? true);
                              });
                            }
                          : null,
                      secondary: Icon(
                        Icons.emoji_events,
                        color: Colors.amber,
                      ),
                    ),
                    CheckboxListTile(
                      title: Text('Sistema'),
                      subtitle: Text('Notificações importantes do sistema'),
                      value: provider.notificationTypeSettings['system'] ?? true,
                      onChanged: provider.areNotificationsEnabled
                          ? (value) {
                              setState(() {
                                provider.toggleNotificationType('system', value ?? true);
                              });
                            }
                          : null,
                      secondary: Icon(
                        Icons.info_outline,
                        color: theme.colorScheme.tertiary,
                      ),
                    ),
                    SizedBox(height: 16),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text('FECHAR'),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _testNotification(BuildContext context, NotificationsProvider provider) {
    final notificationTypes = ['streak', 'reminder', 'achievement', 'system'];
    final notificationType = notificationTypes[DateTime.now().second % 4];
    
    String title;
    String message;
    
    switch (notificationType) {
      case 'streak':
        title = 'Teste de sequência';
        message = 'Este é um teste de notificação de sequência de estudos.';
        break;
      case 'reminder':
        title = 'Teste de lembrete';
        message = 'Este é um teste de notificação de lembrete de estudo.';
        break;
      case 'achievement':
        title = 'Teste de conquista';
        message = 'Este é um teste de notificação de conquista.';
        break;
      case 'system':
        title = 'Teste de sistema';
        message = 'Este é um teste de notificação do sistema.';
        break;
      default:
        title = 'Teste de notificação';
        message = 'Este é um teste de notificação.';
    }
    
    provider.addNotification(
      title: title,
      message: message,
      type: notificationType,
    );
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Notificação de teste "$notificationType" criada'),
        duration: Duration(seconds: 2),
      ),
    );
  }
} 