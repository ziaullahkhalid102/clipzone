import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/video.dart';
import '../providers/feed_provider.dart';
import '../config/theme.dart';
import '../screens/comments/comments_sheet.dart';

class ActionBar extends StatefulWidget {
  final Video video;

  const ActionBar({super.key, required this.video});

  @override
  State<ActionBar> createState() => _ActionBarState();
}

class _ActionBarState extends State<ActionBar> {
  late bool _isLiked;
  late int _likesCount;

  @override
  void initState() {
    super.initState();
    _isLiked = widget.video.isLiked;
    _likesCount = widget.video.likesCount;
  }

  void _toggleLike() async {
    setState(() {
      _isLiked = !_isLiked;
      _likesCount += _isLiked ? 1 : -1;
    });
    await context.read<FeedProvider>().likeVideo(widget.video.id);
  }

  void _openComments() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => CommentsSheet(videoId: widget.video.id),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Profile
        _buildProfileAvatar(),
        const SizedBox(height: 20),
        // Like
        _buildActionButton(
          icon: _isLiked ? Icons.favorite : Icons.favorite_border,
          label: _formatCount(_likesCount),
          color: _isLiked ? AppTheme.primaryColor : Colors.white,
          onTap: _toggleLike,
        ),
        const SizedBox(height: 20),
        // Comment
        _buildActionButton(
          icon: Icons.chat_bubble_outline,
          label: _formatCount(widget.video.commentsCount),
          onTap: _openComments,
        ),
        const SizedBox(height: 20),
        // Share
        _buildActionButton(
          icon: Icons.reply,
          label: _formatCount(widget.video.sharesCount),
          onTap: () {},
        ),
      ],
    );
  }

  Widget _buildProfileAvatar() {
    return Column(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 2),
          ),
          child: CircleAvatar(
            backgroundImage: widget.video.userPicture != null
                ? NetworkImage(widget.video.userPicture!)
                : null,
            backgroundColor: AppTheme.darkCard,
            child: widget.video.userPicture == null
                ? Text(
                    widget.video.userName.isNotEmpty
                        ? widget.video.userName[0].toUpperCase()
                        : '?',
                    style: const TextStyle(color: Colors.white, fontSize: 18),
                  )
                : null,
          ),
        ),
        const SizedBox(height: 2),
        Container(
          width: 20,
          height: 20,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: AppTheme.primaryColor,
          ),
          child: const Icon(Icons.add, color: Colors.white, size: 14),
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    Color color = Colors.white,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(color: Colors.white, fontSize: 12),
          ),
        ],
      ),
    );
  }

  String _formatCount(int count) {
    if (count >= 1000000) return '${(count / 1000000).toStringAsFixed(1)}M';
    if (count >= 1000) return '${(count / 1000).toStringAsFixed(1)}K';
    return count.toString();
  }
}
