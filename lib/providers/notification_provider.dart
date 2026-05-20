import 'package:flutter/material.dart';
import '../models/notification.dart';
import '../services/notification_service.dart';

class NotificationProvider extends ChangeNotifier {
  final NotificationService _service;
  List<AppNotification> _notifications = [];
  int _unreadCount = 0;
  bool _isLoading = false;

  NotificationProvider(this._service);

  List<AppNotification> get notifications => _notifications;
  int get unreadCount => _unreadCount;
  bool get isLoading => _isLoading;

  Future<void> loadNotifications({bool refresh = false}) async {
    if (_isLoading) return;
    _isLoading = true;
    notifyListeners();

    _notifications = await _service.getNotifications();
    _unreadCount = _notifications.where((n) => !n.isRead).length;

    _isLoading = false;
    notifyListeners();
  }

  Future<void> refreshUnreadCount() async {
    _unreadCount = await _service.getUnreadCount();
    notifyListeners();
  }

  Future<void> markAsRead(String notificationId) async {
    await _service.markAsRead(notificationId);
    final index = _notifications.indexWhere((n) => n.id == notificationId);
    if (index != -1 && !_notifications[index].isRead) {
      _unreadCount = (_unreadCount - 1).clamp(0, _unreadCount);
      notifyListeners();
    }
  }

  Future<void> markAllAsRead() async {
    await _service.markAllAsRead();
    _unreadCount = 0;
    notifyListeners();
  }
}
