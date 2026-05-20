import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import '../../providers/auth_provider.dart';
import '../../providers/feed_provider.dart';
import '../../config/theme.dart';
import '../login_screen.dart';

class UploadScreen extends StatefulWidget {
  const UploadScreen({super.key});

  @override
  State<UploadScreen> createState() => _UploadScreenState();
}

class _UploadScreenState extends State<UploadScreen> {
  File? _selectedVideo;
  final TextEditingController _captionController = TextEditingController();
  final TextEditingController _hashtagController = TextEditingController();
  final List<String> _hashtags = [];
  bool _isUploading = false;
  double _uploadProgress = 0;
  VideoPlayerController? _videoController;
  ChewieController? _chewieController;

  @override
  void dispose() {
    _captionController.dispose();
    _hashtagController.dispose();
    _chewieController?.dispose();
    _videoController?.dispose();
    super.dispose();
  }

  Future<void> _pickVideo(ImageSource source) async {
    final picker = ImagePicker();
    final video = await picker.pickVideo(
      source: source,
      maxDuration: const Duration(seconds: 60),
    );

    if (video != null) {
      final file = File(video.path);
      _chewieController?.dispose();
      _videoController?.dispose();

      final vc = VideoPlayerController.file(file);
      await vc.initialize();

      setState(() {
        _selectedVideo = file;
        _videoController = vc;
        _chewieController = ChewieController(
          videoPlayerController: vc,
          autoPlay: false,
          looping: false,
          aspectRatio: vc.value.aspectRatio,
          showControls: true,
          materialProgressColors: ChewieProgressColors(
            playedColor: AppTheme.primaryColor,
            handleColor: AppTheme.primaryColor,
            bufferedColor: Colors.white24,
            backgroundColor: Colors.white12,
          ),
        );
      });
    }
  }

  void _addHashtag() {
    final tag = _hashtagController.text.trim().replaceAll('#', '');
    if (tag.isNotEmpty && !_hashtags.contains(tag)) {
      setState(() {
        _hashtags.add(tag);
        _hashtagController.clear();
      });
    }
  }

  Future<void> _upload() async {
    if (_selectedVideo == null) return;

    final auth = context.read<AuthProvider>();
    if (!auth.isLoggedIn) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please sign in to upload videos'),
          backgroundColor: Colors.orange,
          action: SnackBarAction(
            label: 'Sign In',
            textColor: Colors.white,
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const LoginScreen()),
              );
            },
          ),
        ),
      );
      return;
    }

    setState(() {
      _isUploading = true;
      _uploadProgress = 0;
    });

    // Simulate progress updates
    _simulateProgress();

    try {
      final feed = context.read<FeedProvider>();
      final video = await feed.uploadVideo(
        _selectedVideo!,
        caption: _captionController.text,
        hashtags: _hashtags,
      );

      if (mounted) {
        if (video != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Video uploaded successfully!'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Upload failed. Please try again.'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isUploading = false;
          _uploadProgress = 0;
        });
      }
    }
  }

  void _simulateProgress() {
    Future.doWhile(() async {
      await Future.delayed(const Duration(milliseconds: 300));
      if (!mounted || !_isUploading) return false;
      setState(() {
        _uploadProgress = (_uploadProgress + 0.05).clamp(0.0, 0.95);
      });
      return _isUploading && _uploadProgress < 0.95;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkBg,
      appBar: AppBar(
        backgroundColor: AppTheme.darkBg,
        title: const Text('New Clip'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          if (_selectedVideo != null)
            TextButton(
              onPressed: _isUploading ? null : _upload,
              child: _isUploading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppTheme.primaryColor,
                      ),
                    )
                  : const Text(
                      'Post',
                      style: TextStyle(
                        color: AppTheme.primaryColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
            ),
        ],
      ),
      body: _selectedVideo == null ? _buildPickerView() : _buildEditorView(),
    );
  }

  Widget _buildPickerView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.video_camera_back,
            size: 80,
            color: Colors.white.withValues(alpha: 0.3),
          ),
          const SizedBox(height: 24),
          const Text(
            'Create a Clip',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Record a video or select from gallery',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.6),
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 40),
          // Record Button
          GestureDetector(
            onTap: () => _pickVideo(ImageSource.camera),
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppTheme.primaryColor, width: 4),
              ),
              child: Container(
                margin: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppTheme.primaryColor,
                ),
                child: const Icon(Icons.videocam, color: Colors.white, size: 36),
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Record',
            style: TextStyle(color: Colors.white, fontSize: 14),
          ),
          const SizedBox(height: 32),
          // Gallery Button
          OutlinedButton.icon(
            onPressed: () => _pickVideo(ImageSource.gallery),
            icon: const Icon(Icons.photo_library),
            label: const Text('Choose from Gallery'),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.white,
              side: const BorderSide(color: AppTheme.dividerColor),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Max 60 seconds \u2022 100 MB',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.4),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEditorView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Video Preview with Chewie Player
          Container(
            width: double.infinity,
            height: 300,
            decoration: BoxDecoration(
              color: AppTheme.darkCard,
              borderRadius: BorderRadius.circular(16),
            ),
            clipBehavior: Clip.antiAlias,
            child: Stack(
              children: [
                if (_chewieController != null)
                  Center(child: Chewie(controller: _chewieController!))
                else
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.play_circle_filled, size: 64, color: Colors.white54),
                        const SizedBox(height: 8),
                        Text(
                          _selectedVideo!.path.split('/').last,
                          style: const TextStyle(color: Colors.white54, fontSize: 12),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: IconButton(
                    onPressed: () {
                      _chewieController?.dispose();
                      _videoController?.dispose();
                      setState(() {
                        _selectedVideo = null;
                        _chewieController = null;
                        _videoController = null;
                      });
                    },
                    icon: const Icon(Icons.close, color: Colors.white),
                    style: IconButton.styleFrom(backgroundColor: Colors.black54),
                  ),
                ),
              ],
            ),
          ),
          // Upload Progress
          if (_isUploading) ...[
            const SizedBox(height: 16),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: _uploadProgress,
                backgroundColor: AppTheme.darkCard,
                valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
                minHeight: 6,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Uploading... ${(_uploadProgress * 100).toInt()}%',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.6),
                fontSize: 13,
              ),
            ),
          ],
          const SizedBox(height: 24),
          // Caption
          const Text(
            'Caption',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _captionController,
            maxLines: 3,
            maxLength: 200,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: 'Write a caption...',
              counterStyle: TextStyle(
                color: Colors.white.withValues(alpha: 0.4),
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Hashtags
          const Text(
            'Hashtags',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _hashtagController,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    hintText: 'Add hashtag...',
                    prefixText: '# ',
                    prefixStyle: TextStyle(color: AppTheme.accentColor),
                  ),
                  onSubmitted: (_) => _addHashtag(),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                onPressed: _addHashtag,
                icon: const Icon(Icons.add_circle),
                color: AppTheme.primaryColor,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _hashtags.map((tag) {
              return Chip(
                label: Text('#$tag', style: const TextStyle(color: Colors.white, fontSize: 13)),
                backgroundColor: AppTheme.darkCard,
                deleteIcon: const Icon(Icons.close, size: 16, color: Colors.white54),
                onDeleted: () => setState(() => _hashtags.remove(tag)),
                side: const BorderSide(color: AppTheme.dividerColor),
              );
            }).toList(),
          ),
          const SizedBox(height: 32),
          // Post Button
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: _isUploading ? null : _upload,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                disabledBackgroundColor: AppTheme.primaryColor.withValues(alpha: 0.4),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: _isUploading
                  ? const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(width: 12),
                        Text('Uploading...', style: TextStyle(fontSize: 16)),
                      ],
                    )
                  : const Text(
                      'Post Clip',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}
