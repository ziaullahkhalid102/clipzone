import '../config/api_config.dart';
import '../models/notification.dart';
import 'api_service.dart';

class NotificationService {
  final ApiService _api;

  NotificationService(this._api);

  Future<List<AppNotification>> getNotifications({int page = 1}) async {
    try {
      final response = await _api.get(
        '${ApiConfig.apiBase}/notifications?page=$page',
      );
      final List<dynamic> items = response['notifications'] ?? [];
      return items.map((n) => AppNotification.fromJson(n)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<void> markAsRead(String notificationId) async {
    try {
      await _api.post('${ApiConfig.apiBase}/notifications/$notificationId/read');
    } catch (_) {}
  }

  Future<void> markAllAsRead() async {
    try {
      await _api.post('${ApiConfig.apiBase}/notifications/read-all');
    } catch (_) {}
  }

  Future<int> getUnreadCount() async {
    try {
      final response = await _api.get(
        '${ApiConfig.apiBase}/notifications/unread-count',
      );
      return response['count'] ?? 0;
    } catch (e) {
      return 0;
    }
  }
}
