import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/user_provider.dart';
import '../../models/video.dart';
import '../../config/theme.dart';
import '../login_screen.dart';
import '../settings/settings_screen.dart';
import 'edit_profile_screen.dart';

class ProfileScreen extends StatefulWidget {
  final String? userId;

  const ProfileScreen({super.key, this.userId});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  List<Video> _myVideos = [];
  bool _isLoadingVideos = false;

  @override
  void initState() {
    super.initState();
    _loadMyVideos();
  }

  Future<void> _loadMyVideos() async {
    final auth = context.read<AuthProvider>();
    if (auth.isLoggedIn && auth.user != null) {
      setState(() => _isLoadingVideos = true);
      final videos =
          await context.read<UserProvider>().loadMyVideos(auth.user!.id);
      if (mounted) {
        setState(() {
          _myVideos = videos;
          _isLoadingVideos = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, auth, _) {
        final user = auth.user;

        return Scaffold(
          backgroundColor: AppTheme.darkBg,
          appBar: AppBar(
            backgroundColor: AppTheme.darkBg,
            title: Text(
              user?.username ?? user?.name ?? 'Profile',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.settings),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const SettingsScreen()),
                  );
                },
              ),
            ],
          ),
          body: user == null
              ? _buildNotLoggedIn(context)
              : _buildProfile(context, auth),
        );
      },
    );
  }

  Widget _buildNotLoggedIn(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.person_outline,
            size: 80,
            color: Colors.white.withValues(alpha: 0.3),
          ),
          const SizedBox(height: 16),
          const Text(
            'Sign in to see your profile',
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
    );
  }

  Widget _buildProfile(BuildContext context, AuthProvider auth) {
    final user = auth.user!;

    return RefreshIndicator(
      onRefresh: _loadMyVideos,
      color: AppTheme.primaryColor,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          children: [
            const SizedBox(height: 20),
            // Avatar
            CircleAvatar(
              radius: 50,
              backgroundColor: AppTheme.darkCard,
              backgroundImage:
                  user.picture != null ? NetworkImage(user.picture!) : null,
              child: user.picture == null
                  ? Text(
                      user.name.isNotEmpty ? user.name[0].toUpperCase() : '?',
                      style: const TextStyle(fontSize: 40, color: Colors.white),
                    )
                  : null,
            ),
            const SizedBox(height: 12),
            Text(
              user.name,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (user.username != null) ...[
              const SizedBox(height: 4),
              Text(
                '@${user.username}',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.6),
                  fontSize: 14,
                ),
              ),
            ],
            const SizedBox(height: 4),
            Text(
              user.email,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.4),
                fontSize: 13,
              ),
            ),
            if (user.bio != null && user.bio!.isNotEmpty) ...[
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: Text(
                  user.bio!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                ),
              ),
            ],
            const SizedBox(height: 20),
            // Stats Row
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildStat(user.followingCount.toString(), 'Following'),
                Container(
                  width: 1,
                  height: 30,
                  color: AppTheme.dividerColor,
                  margin: const EdgeInsets.symmetric(horizontal: 24),
                ),
                _buildStat(user.followersCount.toString(), 'Followers'),
                Container(
                  width: 1,
                  height: 30,
                  color: AppTheme.dividerColor,
                  margin: const EdgeInsets.symmetric(horizontal: 24),
                ),
                _buildStat(_myVideos.length.toString(), 'Clips'),
              ],
            ),
            const SizedBox(height: 20),
            // Edit Profile Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: OutlinedButton(
                onPressed: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const EditProfileScreen()),
                  );
                  if (mounted) _loadMyVideos();
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  side: const BorderSide(color: AppTheme.dividerColor),
                  minimumSize: const Size(double.infinity, 44),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                child: const Text('Edit Profile'),
              ),
            ),
            const SizedBox(height: 24),
            // Video Grid
            const Divider(color: AppTheme.dividerColor, height: 1),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.grid_view, color: Colors.white, size: 22),
                  SizedBox(width: 8),
                  Text(
                    'My Clips',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const Divider(color: AppTheme.dividerColor, height: 1),
            if (_isLoadingVideos)
              const Padding(
                padding: EdgeInsets.all(40),
                child: CircularProgressIndicator(color: AppTheme.primaryColor),
              )
            else if (_myVideos.isEmpty)
              Padding(
                padding: const EdgeInsets.all(40),
                child: Column(
                  children: [
                    Icon(
                      Icons.video_library_outlined,
                      size: 60,
                      color: Colors.white.withValues(alpha: 0.2),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'No clips yet',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Your clips will appear here',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.5),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              )
            else
              _buildVideoGrid(),
          ],
        ),
      ),
    );
  }

  Widget _buildVideoGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(2),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 2,
        mainAxisSpacing: 2,
        childAspectRatio: 9 / 16,
      ),
      itemCount: _myVideos.length,
      itemBuilder: (context, index) {
        final video = _myVideos[index];
        return _buildVideoTile(video);
      },
    );
  }

  Widget _buildVideoTile(Video video) {
    return Container(
      color: AppTheme.darkCard,
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (video.thumbnailUrl != null)
            Image.network(
              video.thumbnailUrl!,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => _buildVideoPlaceholder(video),
            )
          else
            _buildVideoPlaceholder(video),
          // Views count overlay
          Positioned(
            bottom: 4,
            left: 4,
            child: Row(
              children: [
                const Icon(Icons.play_arrow, color: Colors.white, size: 16),
                const SizedBox(width: 2),
                Text(
                  _formatCount(video.views),
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVideoPlaceholder(Video video) {
    return Container(
      color: AppTheme.darkCard,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.videocam, color: Colors.white38, size: 32),
            const SizedBox(height: 4),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                video.caption,
                style: const TextStyle(color: Colors.white38, fontSize: 10),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStat(String count, String label) {
    return Column(
      children: [
        Text(
          count,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.6),
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  String _formatCount(int count) {
    if (count >= 1000000) return '${(count / 1000000).toStringAsFixed(1)}M';
    if (count >= 1000) return '${(count / 1000).toStringAsFixed(1)}K';
    return count.toString();
  }
}
