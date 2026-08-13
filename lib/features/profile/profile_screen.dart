import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/config/app_theme.dart';
import '../../core/errors/app_failure.dart';
import '../../core/services/profile_service.dart';
import '../../core/widgets/app_widgets.dart';
import '../../core/widgets/role_guard.dart';
import '../../models/profile.dart';
import '../auth/auth_service.dart';
import 'firm_settings_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _phoneController = TextEditingController();

  Profile? _profile;
  String? _avatarUrl;

  bool _loading = true;
  bool _saving = false;
  bool _uploadingImage = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final profile = await ProfileService.instance.getCurrentProfile();
      final avatarUrl = await ProfileService.instance.getProfileImageSignedUrl(
        profile.profileImage,
      );
      if (!mounted) return;
      setState(() {
        _profile = profile;
        _avatarUrl = avatarUrl;
        _fullNameController.text = profile.fullName ?? '';
        _phoneController.text = profile.phone ?? '';
        _loading = false;
      });
    } on AppFailure catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.message;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _error = 'Unable to load your profile. Please try again.';
        _loading = false;
      });
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      final updated = await ProfileService.instance.updateProfile(
        fullName: _fullNameController.text.trim(),
        phone: _phoneController.text.trim(),
      );
      if (!mounted) return;
      setState(() {
        _profile = updated;
        _saving = false;
      });
      _showSnack('Profile updated successfully.', success: true);
    } on AppFailure catch (e) {
      if (!mounted) return;
      setState(() => _saving = false);
      _showSnack(e.message);
    } catch (_) {
      if (!mounted) return;
      setState(() => _saving = false);
      _showSnack('Unable to update your profile. Please try again.');
    }
  }

  Future<void> _pickAndUploadAvatar() async {
    final picker = ImagePicker();
    final XFile? file = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );
    if (file == null) return;

    setState(() => _uploadingImage = true);
    try {
      final bytes = await file.readAsBytes();
      final updated = await ProfileService.instance.uploadProfileImage(
        bytes: bytes,
        fileName: file.name,
      );
      final avatarUrl = await ProfileService.instance.getProfileImageSignedUrl(
        updated.profileImage,
      );
      if (!mounted) return;
      setState(() {
        _profile = updated;
        _avatarUrl = avatarUrl;
        _uploadingImage = false;
      });
      _showSnack('Profile photo updated.', success: true);
    } on AppFailure catch (e) {
      if (!mounted) return;
      setState(() => _uploadingImage = false);
      _showSnack(e.message);
    } catch (_) {
      if (!mounted) return;
      setState(() => _uploadingImage = false);
      _showSnack('Image upload failed. Please try again.');
    }
  }

  void _showSnack(String message, {bool success = false}) {
    final colors = context.appColors;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              success ? Icons.check_circle_rounded : Icons.error_outline,
              color: success ? colors.secondary : colors.error,
              size: 16,
            ),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
      ),
    );
  }

  Future<void> _showChangePasswordDialog() async {
    final colors = context.appColors;
    final controller = TextEditingController();
    final formKey = GlobalKey<FormState>();
    bool submitting = false;

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text('Change Password'),
              content: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Enter your new password below.',
                      style: TextStyle(
                        color: colors.textSecondary,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: controller,
                      obscureText: true,
                      style: TextStyle(color: colors.textPrimary),
                      decoration: const InputDecoration(
                        labelText: 'New password',
                        prefixIcon: Icon(Icons.lock_outline_rounded, size: 18),
                      ),
                      validator: (v) {
                        if (v == null || v.length < 6) {
                          return 'Password must be at least 6 characters.';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed:
                      submitting ? null : () => Navigator.of(dialogContext).pop(),
                  child: Text('Cancel'),
                ),
                FilledButton(
                  onPressed: submitting
                      ? null
                      : () async {
                          if (!formKey.currentState!.validate()) return;
                          setDialogState(() => submitting = true);
                          try {
                            await AuthService.instance
                                .changePassword(controller.text);
                            if (dialogContext.mounted) {
                              Navigator.of(dialogContext).pop();
                            }
                            if (mounted) {
                              _showSnack('Password updated successfully.',
                                  success: true);
                            }
                          } on AuthFailure catch (e) {
                            setDialogState(() => submitting = false);
                            if (mounted) _showSnack(e.message);
                          } catch (_) {
                            setDialogState(() => submitting = false);
                            if (mounted) {
                              _showSnack(
                                  'Unable to update your password. Please try again.');
                            }
                          }
                        },
                  child: submitting
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text('Update'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Scaffold(
      backgroundColor: colors.bg1,
      body: Column(
        children: [
          _buildAppBar(),
          Expanded(
            child: _loading
                ? Center(
                    child: CircularProgressIndicator(color: colors.primary))
                : _error != null
                    ? AppErrorState(message: _error!, onRetry: _load)
                    : _buildContent(),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar() {
    final colors = context.appColors;
    return Container(
      decoration: BoxDecoration(
        color: colors.bg1,
        border: Border(bottom: BorderSide(color: colors.glassBorderDim)),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Row(
            children: [
              IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: Icon(Icons.arrow_back_ios_new_rounded, color: colors.textSecondary,
                  size: 18,
                ),
              ),
              Expanded(
                child: Text(
                  'My Profile',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: colors.textPrimary,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(width: 48), // balance the back button
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContent() {
    final colors = context.appColors;
    final profile = _profile!;
    return RefreshIndicator(
      color: colors.primary,
      backgroundColor: colors.bg2,
      onRefresh: _load,
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Avatar section
          _buildAvatarSection(profile),
          const SizedBox(height: 28),
          // Edit form
          GlassCard(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Personal Information',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: colors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Email (readonly)
                  _ReadOnlyField(
                    label: 'Email address',
                    value: profile.email ?? '—',
                    icon: Icons.email_outlined,
                  ),
                  const SizedBox(height: 14),
                  AppTextField(
                    controller: _fullNameController,
                    label: 'Full Name',
                    prefixIcon: Icons.person_outline_rounded,
                    validator: (v) => (v == null || v.trim().isEmpty)
                        ? 'Full name is required.'
                        : null,
                  ),
                  const SizedBox(height: 14),
                  AppTextField(
                    controller: _phoneController,
                    label: 'Phone',
                    prefixIcon: Icons.phone_outlined,
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 14),
                  _ReadOnlyField(
                    label: 'Role',
                    value: _roleLabel(profile.role),
                    icon: Icons.badge_rounded,
                    badge: true,
                    badgeColor: _roleColor(profile.role),
                  ),
                  const SizedBox(height: 24),
                  AppPrimaryButton(
                    label: 'Save Changes',
                    onPressed: _saving ? null : _save,
                    loading: _saving,
                    icon: Icons.check_rounded,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Security section
          GlassCard(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Security',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: colors.textPrimary,
                  ),
                ),
                const SizedBox(height: 16),
                _ActionTile(
                  icon: Icons.lock_outline_rounded,
                  label: 'Change Password',
                  color: colors.primary,
                  onTap: _showChangePasswordDialog,
                ),
              ],
            ),
          ),
          // Firm settings (ca_owner / super_admin only)
          RoleGuard(
            role: profile.role,
            allow: const [UserRole.ca, UserRole.superAdmin],
            child: Padding(
              padding: const EdgeInsets.only(top: 16),
              child: GlassCard(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Firm',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: colors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _ActionTile(
                      icon: Icons.business_rounded,
                      label: 'Firm Settings',
                      color: colors.secondary,
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const FirmSettingsScreen(),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildAvatarSection(Profile profile) {
    final colors = context.appColors;
    final initials = (profile.fullName?.isNotEmpty == true
            ? profile.fullName![0]
            : profile.email?[0] ?? '?')
        .toUpperCase();

    return Center(
      child: Column(
        children: [
          Stack(
            children: [
              Container(
                width: 88,
                height: 88,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [colors.primaryDark, colors.tertiary],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [BoxShadow(color: colors.primary.withValues(alpha: 0.35), blurRadius: 24, offset: const Offset(0, 8))],
                  image: _avatarUrl != null
                      ? DecorationImage(
                          image: NetworkImage(_avatarUrl!),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: _avatarUrl == null
                    ? Center(
                        child: Text(
                          initials,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 30,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      )
                    : null,
              ),
              // Camera button
              Positioned(
                bottom: 2,
                right: 2,
                child: GestureDetector(
                  onTap: _uploadingImage ? null : _pickAndUploadAvatar,
                  child: Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [colors.primaryDark, colors.primary],
                      ),
                      shape: BoxShape.circle,
                      border: Border.all(color: colors.bg1, width: 2),
                    ),
                    child: _uploadingImage
                        ? const Padding(
                            padding: EdgeInsets.all(6),
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Icon(
                            Icons.camera_alt_rounded,
                            size: 14,
                            color: Colors.white,
                          ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            profile.fullName ?? profile.email ?? '—',
            style: TextStyle(color: colors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          AppBadge(
            label: _roleLabel(profile.role),
            color: _roleColor(profile.role),
          ),
        ],
      ),
    );
  }

  String _roleLabel(UserRole role) {
    switch (role) {
      case UserRole.superAdmin:
        return 'Super Admin';
      case UserRole.ca:
        return 'CA Owner';
      case UserRole.staff:
        return 'Staff';
      case UserRole.client:
        return 'Client';
    }
  }

  Color _roleColor(UserRole role) {
    final colors = context.appColors;
    switch (role) {
      case UserRole.superAdmin:
        return colors.tertiary;
      case UserRole.ca:
        return colors.primary;
      case UserRole.staff:
        return colors.secondary;
      case UserRole.client:
        return colors.warning;
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  Small helper widgets
// ─────────────────────────────────────────────────────────────────────────────

class _ReadOnlyField extends StatelessWidget {
  const _ReadOnlyField({
    required this.label,
    required this.value,
    required this.icon,
    this.badge = false,
    this.badgeColor,
  });

  final String label;
  final String value;
  final IconData icon;
  final bool badge;
  final Color? badgeColor;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: colors.bg3,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: colors.glassBorderDim),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: colors.textMuted),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(color: colors.textMuted,
                  ),
                ),
                const SizedBox(height: 2),
                badge
                    ? AppBadge(label: value, color: badgeColor ?? colors.primary)
                    : Text(
                        value,
                        style: TextStyle(color: colors.textSecondary,
                        ),
                      ),
              ],
            ),
          ),
          Icon(Icons.lock_outline, size: 14, color: colors.textDisabled),
        ],
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  const _ActionTile({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: colors.bg3,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(color: colors.glassBorderDim),
        ),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(AppRadius.sm),
              ),
              child: Icon(icon, size: 16, color: color),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: TextStyle(color: colors.textPrimary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Icon(Icons.info_outline, color: colors.textMuted,
              size: 18,
            ),
          ],
        ),
      ),
    );
  }
}
