import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/user_provider.dart';
import '../../config/theme.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late TextEditingController _nameController;
  late TextEditingController _usernameController;
  late TextEditingController _bioController;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final user = context.read<AuthProvider>().user;
    _nameController = TextEditingController(text: user?.name ?? '');
    _usernameController = TextEditingController(text: user?.username ?? '');
    _bioController = TextEditingController(text: user?.bio ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _usernameController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    setState(() => _isSaving = true);

    final userProvider = context.read<UserProvider>();
    final updated = await userProvider.updateProfile(
      name: _nameController.text.trim(),
      username: _usernameController.text.trim(),
      bio: _bioController.text.trim(),
    );

    if (mounted) {
      setState(() => _isSaving = false);
      if (updated != null) {
        // Refresh auth user data
        await context.read<AuthProvider>().refreshUser();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Profile updated!'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context);
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to update profile. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = context.read<AuthProvider>().user;

    return Scaffold(
      backgroundColor: AppTheme.darkBg,
      appBar: AppBar(
        backgroundColor: AppTheme.darkBg,
        title: const Text('Edit Profile'),
        actions: [
          TextButton(
            onPressed: _isSaving ? null : _save,
            child: _isSaving
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppTheme.primaryColor,
                    ),
                  )
                : const Text(
                    'Save',
                    style: TextStyle(
                      color: AppTheme.primaryColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Avatar
            Center(
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: AppTheme.darkCard,
                    backgroundImage: user?.picture != null
                        ? NetworkImage(user!.picture!)
                        : null,
                    child: user?.picture == null
                        ? Text(
                            user?.name.isNotEmpty == true
                                ? user!.name[0].toUpperCase()
                                : '?',
                            style: const TextStyle(
                                fontSize: 40, color: Colors.white),
                          )
                        : null,
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppTheme.primaryColor,
                      ),
                      child: const Icon(Icons.camera_alt,
                          color: Colors.white, size: 16),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            // Name
            _buildField('Name', _nameController, Icons.person),
            const SizedBox(height: 20),
            // Username
            _buildField('Username', _usernameController, Icons.alternate_email),
            const SizedBox(height: 20),
            // Bio
            _buildField('Bio', _bioController, Icons.info_outline,
                maxLines: 3, maxLength: 150),
            const SizedBox(height: 16),
            // Email (read-only)
            ListTile(
              leading:
                  const Icon(Icons.email, color: Colors.white38, size: 22),
              title: const Text('Email',
                  style: TextStyle(color: Colors.white38, fontSize: 13)),
              subtitle: Text(
                user?.email ?? '',
                style: const TextStyle(color: Colors.white54, fontSize: 15),
              ),
              contentPadding: EdgeInsets.zero,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildField(
    String label,
    TextEditingController controller,
    IconData icon, {
    int maxLines = 1,
    int? maxLength,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      maxLength: maxLength,
      style: const TextStyle(color: Colors.white, fontSize: 16),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.white.withValues(alpha: 0.5)),
        prefixIcon: Icon(icon, color: Colors.white38, size: 22),
        counterStyle: TextStyle(color: Colors.white.withValues(alpha: 0.3)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppTheme.dividerColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppTheme.primaryColor),
        ),
        filled: true,
        fillColor: AppTheme.darkCard,
      ),
    );
  }
}
