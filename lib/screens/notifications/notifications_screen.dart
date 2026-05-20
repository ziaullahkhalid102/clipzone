import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../../providers/notification_provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/notification.dart';
import '../../config/theme.dart';
import '../login_screen.dart';
import '../profile/user_profile_screen.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (mounted) {
        context.read<NotificationProvider>().loadNotifications();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    if (!auth.isLoggedIn) {
      return Scaffold(
        backgroundColor: AppTheme.darkBg,
        appBar: AppBar(
          backgroundColor: AppTheme.darkBg,
          title: const Text('Notifications'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.notifications_off_outlined,
                size: 80,
                color: Colors.white.withValues(alpha: 0.3),
              ),
              const SizedBox(height: 16),
              const Text(
                'Sign in to see notifications',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                  );
                },
                child: const Text('Sign In'),
              ),
            ],
          ),
        ),
      );
    }

    return Consumer<NotificationProvider>(
      builder: (context, provider, _) {
        return Scaffold(
          backgroundColor: AppTheme.darkBg,
          appBar: AppBar(
            backgroundColor: AppTheme.darkBg,
            title: const Text('Notifications'),
            actions: [
              if (provider.unreadCount > 0)
                TextButton(
                  onPressed: () => provider.markAllAsRead(),
                  child: const Text(
                    'Read all',
                    style: TextStyle(color: AppTheme.accentColor, fontSize: 13),
                  ),
                ),
            ],
          ),
          body: provider.isLoading
              ? const Center(
                  child:
                      CircularProgressIndicator(color: AppTheme.primaryColor),
                )
              : provider.notifications.isEmpty
                  ? _buildEmpty()
                  : RefreshIndicator(
                      onRefresh: () =>
                          provider.loadNotifications(refresh: true),
                      color: AppTheme.primaryColor,
                      child: ListView.builder(
                        itemCount: provider.notifications.length,
                        itemBuilder: (context, index) {
                          return _buildNotificationTile(
                            provider.notifications[index],
                            provider,
                          );
                        },
                      ),
                    ),
        );
      },
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.notifications_none,
            size: 80,
            color: Colors.white.withValues(alpha: 0.2),
          ),
          const SizedBox(height: 16),
          const Text(
            'No notifications yet',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'When someone interacts with your content,\nyou\'ll see it here',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.5),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationTile(
      AppNotification notification, NotificationProvider provider) {
    final icon = _getIcon(notification.type);
    final iconColor = _getIconColor(notification.type);

    return Container(
      color: notification.isRead
          ? Colors.transparent
          : AppTheme.primaryColor.withValues(alpha: 0.05),
      child: ListTile(
        leading: GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => UserProfileScreen(
                  userId: notification.fromUserId,
                  userName: notification.fromUserName,
                ),
              ),
            );
          },
          child: CircleAvatar(
            backgroundColor: AppTheme.darkCard,
            backgroundImage: notification.fromUserPicture != null
                ? NetworkImage(notification.fromUserPicture!)
                : null,
            child: notification.fromUserPicture == null
                ? Text(
                    notification.fromUserName.isNotEmpty
                        ? notification.fromUserName[0].toUpperCase()
                        : '?',
                    style: const TextStyle(color: Colors.white),
                  )
                : null,
          ),
        ),
        title: RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: notification.fromUserName,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              TextSpan(
                text: ' ${notification.message}',
                style: const TextStyle(color: Colors.white, fontSize: 14),
              ),
            ],
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          timeago.format(notification.createdAt),
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.4),
            fontSize: 12,
          ),
        ),
        trailing: Icon(icon, color: iconColor, size: 20),
        onTap: () {
          if (!notification.isRead) {
            provider.markAsRead(notification.id);
          }
        },
      ),
    );
  }

  IconData _getIcon(String type) {
    switch (type) {
      case 'like':
        return Icons.favorite;
      case 'comment':
        return Icons.chat_bubble;
      case 'follow':
        return Icons.person_add;
      case 'mention':
        return Icons.alternate_email;
      default:
        return Icons.notifications;
    }
  }

  Color _getIconColor(String type) {
    switch (type) {
      case 'like':
        return AppTheme.primaryColor;
      case 'comment':
        return AppTheme.accentColor;
      case 'follow':
        return Colors.blue;
      case 'mention':
        return Colors.orange;
      default:
        return Colors.white54;
    }
  }
}
