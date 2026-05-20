import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/feed_provider.dart';
import '../../config/theme.dart';
import '../../widgets/video_player_widget.dart';
import '../../widgets/action_bar.dart';

class VideoFeedScreen extends StatefulWidget {
  const VideoFeedScreen({super.key});

  @override
  State<VideoFeedScreen> createState() => _VideoFeedScreenState();
}

class _VideoFeedScreenState extends State<VideoFeedScreen> {
  final PageController _pageController = PageController();
  bool _showHeart = false;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (mounted) {
        context.read<FeedProvider>().loadFeed(refresh: true);
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onDoubleTap(String videoId) {
    context.read<FeedProvider>().likeVideo(videoId);
    setState(() => _showHeart = true);
    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) setState(() => _showHeart = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<FeedProvider>(
      builder: (context, feed, _) {
        if (feed.isLoading && feed.feedVideos.isEmpty) {
          return Scaffold(
            backgroundColor: AppTheme.darkBg,
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppTheme.primaryColor, AppTheme.accentColor],
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Icon(
                      Icons.play_arrow_rounded,
                      size: 50,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Loading ClipZone...',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                  const SizedBox(height: 16),
                  const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        if (feed.feedVideos.isEmpty) {
          return Scaffold(
            backgroundColor: AppTheme.darkBg,
            body: RefreshIndicator(
              onRefresh: () => feed.loadFeed(refresh: true),
              color: AppTheme.primaryColor,
              child: ListView(
                children: [
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.8,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.video_library_outlined,
                          size: 80,
                          color: Colors.white.withValues(alpha: 0.3),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'No videos yet',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Be the first to share a clip!',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.6),
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton.icon(
                          onPressed: () => feed.loadFeed(refresh: true),
                          icon: const Icon(Icons.refresh),
                          label: const Text('Refresh'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        return Scaffold(
          backgroundColor: AppTheme.darkBg,
          extendBodyBehindAppBar: true,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            title: const Text(
              'ClipZone',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
          ),
          body: PageView.builder(
            controller: _pageController,
            scrollDirection: Axis.vertical,
            itemCount: feed.feedVideos.length,
            onPageChanged: (index) {
              feed.recordView(feed.feedVideos[index].id);
              if (index >= feed.feedVideos.length - 2) {
                feed.loadFeed();
              }
            },
            itemBuilder: (context, index) {
              final video = feed.feedVideos[index];
              return GestureDetector(
                onDoubleTap: () => _onDoubleTap(video.id),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    VideoPlayerWidget(video: video),
                    // Double-tap heart animation
                    if (_showHeart)
                      Center(
                        child: TweenAnimationBuilder<double>(
                          tween: Tween(begin: 0.5, end: 1.0),
                          duration: const Duration(milliseconds: 400),
                          curve: Curves.elasticOut,
                          builder: (context, value, child) {
                            return Transform.scale(
                              scale: value,
                              child: child,
                            );
                          },
                          child: const Icon(
                            Icons.favorite,
                            color: AppTheme.primaryColor,
                            size: 100,
                          ),
                        ),
                      ),
                    // Video Info Overlay
                    Positioned(
                      left: 16,
                      bottom: 100,
                      right: 80,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '@${video.userName}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            video.caption,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (video.hashtags.isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Text(
                              video.hashtags.map((h) => '#$h').join(' '),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    // Action Bar (right side)
                    Positioned(
                      right: 8,
                      bottom: 100,
                      child: ActionBar(video: video),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }
}
