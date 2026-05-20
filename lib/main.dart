import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'config/theme.dart';
import 'providers/auth_provider.dart';
import 'providers/feed_provider.dart';
import 'providers/user_provider.dart';
import 'services/api_service.dart';
import 'services/auth_service.dart';
import 'services/video_service.dart';
import 'services/user_service.dart';
import 'screens/splash_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );

  final apiService = ApiService();
  final authService = AuthService(apiService);
  final videoService = VideoService(apiService);
  final userService = UserService(apiService);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider(authService)),
        ChangeNotifierProvider(create: (_) => FeedProvider(videoService)),
        ChangeNotifierProvider(create: (_) => UserProvider(userService, videoService)),
      ],
      child: const ClipZoneApp(),
    ),
  );
}

class ClipZoneApp extends StatelessWidget {
  const ClipZoneApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ClipZone',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: const SplashScreen(),
    );
  }
}
