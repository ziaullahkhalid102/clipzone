import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/theme.dart';
import '../providers/notification_provider.dart';
import 'feed/video_feed_screen.dart';
import 'discover/discover_screen.dart';
import 'upload/upload_screen.dart';
import 'notifications/notifications_screen.dart';
import 'profile/profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    VideoFeedScreen(),
    DiscoverScreen(),
    SizedBox(), // Placeholder for upload button
    NotificationsScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _getStackIndex(),
        children: [
          _screens[0],
          _screens[1],
          _screens[3],
          _screens[4],
        ],
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          border: Border(
            top: BorderSide(color: AppTheme.dividerColor, width: 0.5),
          ),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            if (index == 2) {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const UploadScreen()),
              );
            } else {
              setState(() => _currentIndex = index);
            }
          },
          items: [
            const BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Home',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.search),
              label: 'Discover',
            ),
            BottomNavigationBarItem(
              icon: Container(
                width: 44,
                height: 30,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppTheme.accentColor, AppTheme.primaryColor],
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.add, color: Colors.white, size: 22),
              ),
              label: '',
            ),
            BottomNavigationBarItem(
              icon: Consumer<NotificationProvider>(
                builder: (context, provider, child) {
                  return Badge(
                    isLabelVisible: provider.unreadCount > 0,
                    label: Text(
                      provider.unreadCount.toString(),
                      style: const TextStyle(fontSize: 10),
                    ),
                    child: const Icon(Icons.notifications_outlined),
                  );
                },
              ),
              label: 'Inbox',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }

  int _getStackIndex() {
    if (_currentIndex < 2) return _currentIndex;
    if (_currentIndex == 2) return 0; // Upload uses push, fallback to feed
    return _currentIndex - 1; // 3 -> 2, 4 -> 3
  }
}
