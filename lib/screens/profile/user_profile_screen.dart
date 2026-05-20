import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/user_provider.dart';
import '../../providers/auth_provider.dart';
import '../../config/theme.dart';

class UserProfileScreen extends StatefulWidget {
  final String userId;
  final String? userName;

  const UserProfileScreen({
    super.key,
    required this.userId,
    this.userName,
  });

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (mounted) {
        context.read<UserProvider>().loadProfile(widget.userId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<UserProvider>(
      builder: (context, userProvider, _) {
        final profile = userProvider.viewedProfile;
        final isLoading = userProvider.isLoading;

        return Scaffold(
          backgroundColor: AppTheme.darkBg,
          appBar: AppBar(
            backgroundColor: AppTheme.darkBg,
            title: Text(
              profile?.name ?? widget.userName ?? 'Profile',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          body: isLoading
              ? const Center(
                  child: CircularProgressIndicator(color: AppTheme.primaryColor),
                )
              : profile == null
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.person_off,
                            size: 60,
                            color: Colors.white.withValues(alpha: 0.3),
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'User not found',
                            style: TextStyle(color: Colors.white, fontSize: 16),
                          ),
                        ],
                      ),
                    )
                  : _buildProfile(context, userProvider),
        );
      },
    );
  }

  Widget _buildProfile(BuildContext context, UserProvider userProvider) {
    final profile = userProvider.viewedProfile!;
    final auth = context.watch<AuthProvider>();
    final isOwnProfile = auth.user?.id == widget.userId;

    return SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(height: 20),
          CircleAvatar(
            radius: 50,
            backgroundColor: AppTheme.darkCard,
            backgroundImage:
                profile.picture != null ? NetworkImage(profile.picture!) : null,
            child: profile.picture == null
                ? Text(
                    profile.name.isNotEmpty
                        ? profile.name[0].toUpperCase()
                        : '?',
                    style: const TextStyle(fontSize: 40, color: Colors.white),
                  )
                : null,
          ),
          const SizedBox(height: 12),
          Text(
            profile.name,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (profile.username != null) ...[
            const SizedBox(height: 4),
            Text(
              '@${profile.username}',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.6),
                fontSize: 14,
              ),
            ),
          ],
          if (profile.bio != null && profile.bio!.isNotEmpty) ...[
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Text(
                profile.bio!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white, fontSize: 14),
              ),
            ),
          ],
          const SizedBox(height: 20),
          // Stats
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildStat(profile.followingCount.toString(), 'Following'),
              Container(
                width: 1,
                height: 30,
                color: AppTheme.dividerColor,
                margin: const EdgeInsets.symmetric(horizontal: 24),
              ),
              _buildStat(profile.followersCount.toString(), 'Followers'),
              Container(
                width: 1,
                height: 30,
                color: AppTheme.dividerColor,
                margin: const EdgeInsets.symmetric(horizontal: 24),
              ),
              _buildStat(profile.videosCount.toString(), 'Clips'),
            ],
          ),
          const SizedBox(height: 20),
          // Follow / Unfollow Button
          if (!isOwnProfile && auth.isLoggedIn)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: SizedBox(
                width: double.infinity,
                height: 44,
                child: ElevatedButton(
                  onPressed: () =>
                      userProvider.toggleFollow(widget.userId),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: userProvider.isFollowing
                        ? AppTheme.darkCard
                        : AppTheme.primaryColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                      side: userProvider.isFollowing
                          ? const BorderSide(color: AppTheme.dividerColor)
                          : BorderSide.none,
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    userProvider.isFollowing ? 'Following' : 'Follow',
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),
                ),
              ),
            ),
          const SizedBox(height: 24),
          const Divider(color: AppTheme.dividerColor, height: 1),
          // User's video grid
          if (userProvider.userVideos.isEmpty)
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
                ],
              ),
            )
          else
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.all(2),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 2,
                mainAxisSpacing: 2,
                childAspectRatio: 9 / 16,
              ),
              itemCount: userProvider.userVideos.length,
              itemBuilder: (context, index) {
                final video = userProvider.userVideos[index];
                return Container(
                  color: AppTheme.darkCard,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.videocam,
                                color: Colors.white38, size: 32),
                            const SizedBox(height: 4),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 8),
                              child: Text(
                                video.caption,
                                style: const TextStyle(
                                    color: Colors.white38, fontSize: 10),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Positioned(
                        bottom: 4,
                        left: 4,
                        child: Row(
                          children: [
                            const Icon(Icons.play_arrow,
                                color: Colors.white, size: 16),
                            const SizedBox(width: 2),
                            Text(
                              _formatCount(video.views),
                              style: const TextStyle(
                                  color: Colors.white, fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
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
