import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/config/app_theme.dart';
import '../../core/errors/app_failure.dart';
import '../../core/services/firm_service.dart';
import '../../core/services/profile_service.dart';
import '../../core/widgets/app_widgets.dart';
import '../../models/profile.dart';
import '../auth/auth_service.dart';

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
  String? _firmPlan;

  bool _loading = true;
  bool _saving = false;
  bool _uploadingImage = false;
  String? _error;

  final List<String> _tabs = [
    'Personal Info',
    'Firm Details',
    'Bank Details',
    'Preferences',
    'Security',
    'Notifications',
  ];

  int _selectedTab = 0;

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

      String? firmPlan;
      try {
        final firm = await FirmService.instance.getCurrentFirm();
        firmPlan = firm?.subscriptionPlan;
      } catch (_) {}

      if (!mounted) return;

      setState(() {
        _profile = profile;
        _avatarUrl = avatarUrl;
        _firmPlan = firmPlan;
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
              title: const Text('Change Password'),
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
                  onPressed: submitting ? null : () => Navigator.of(dialogContext).pop(),
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  onPressed: submitting
                      ? null
                      : () async {
                          if (!formKey.currentState!.validate()) return;
                          setDialogState(() => submitting = true);
                          try {
                            await AuthService.instance.changePassword(controller.text);
                            if (dialogContext.mounted) Navigator.of(dialogContext).pop();
                            if (mounted) {
                              _showSnack('Password updated successfully.', success: true);
                            }
                          } on AuthFailure catch (e) {
                            setDialogState(() => submitting = false);
                            if (mounted) _showSnack(e.message);
                          } catch (_) {
                            setDialogState(() => submitting = false);
                            if (mounted) {
                              _showSnack('Unable to update your password. Please try again.');
                            }
                          }
                        },
                  child: submitting
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Update'),
                ),
              ],
            );
          },
        );
      },
    );
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

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    if (_loading) {
      return Center(
        child: CircularProgressIndicator(color: colors.primary),
      );
    }

    if (_error != null) {
      return Center(
        child: AppErrorState(message: _error!, onRetry: _load),
      );
    }

    final profile = _profile!;

    return RefreshIndicator(
      color: colors.primary,
      onRefresh: _load,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildPageHeader(colors),
            const SizedBox(height: 20),
            _buildProfileSummaryCard(colors, profile),
            const SizedBox(height: 18),
            _buildStatCards(colors),
            const SizedBox(height: 18),
            _buildTabs(colors),
            const SizedBox(height: 18),
            _buildMainContent(colors, profile),
            const SizedBox(height: 20),
            _buildRecentActivity(colors),
          ],
        ),
      ),
    );
  }

  Widget _buildPageHeader(AppThemeExtension colors) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Profile',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w800,
                color: colors.textPrimary,
                letterSpacing: -0.8,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Manage your personal information and preferences.',
              style: TextStyle(
                color: colors.textSecondary,
                fontSize: 14,
              ),
            ),
          ],
        ),
        AppPrimaryButton(
          label: 'Edit Profile',
          onPressed: () {},
          width: 150,
          icon: Icons.edit_note_rounded,
        ),
      ],
    );
  }

  Widget _buildProfileSummaryCard(AppThemeExtension colors, Profile profile) {
    final initials = (profile.fullName?.isNotEmpty == true
            ? profile.fullName![0]
            : profile.email?[0] ?? '?')
        .toUpperCase();
    final planLabel = (_firmPlan ?? 'Premium').replaceAll('_', ' ');

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: colors.bg2,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colors.glassBorderDim),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Stack(
            children: [
              Container(
                width: 96,
                height: 96,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [colors.primary, colors.primaryDark],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 4),
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
                            fontSize: 36,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      )
                    : null,
              ),
              Positioned(
                right: 0,
                bottom: 0,
                child: GestureDetector(
                  onTap: _uploadingImage ? null : _pickAndUploadAvatar,
                  child: Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: colors.bg3,
                      shape: BoxShape.circle,
                      border: Border.all(color: colors.glassBorderDim, width: 2),
                    ),
                    child: _uploadingImage
                        ? Padding(
                            padding: const EdgeInsets.all(5),
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: colors.primary,
                            ),
                          )
                        : Icon(Icons.camera_alt_rounded, size: 14, color: colors.textSecondary),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          profile.fullName ?? 'Full Name',
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.w700,
                            color: colors.textPrimary,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: colors.primary.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            _roleLabel(profile.role),
                            style: TextStyle(
                              color: colors.primary,
                              fontWeight: FontWeight.w700,
                              fontSize: 10,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    _detailText(Icons.mail_outline_rounded, profile.email ?? 'email@example.com', colors),
                    const SizedBox(height: 6),
                    _detailText(Icons.phone_rounded, profile.phone ?? '+91 98765 43210', colors),
                    const SizedBox(height: 6),
                    _detailText(Icons.location_on_outlined, 'Bengaluru, Karnataka, India', colors),
                  ],
                ),
                Container(
                  width: 220,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: colors.bg1,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: colors.glassBorderDim),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _profileMetaLine('Membership No.', '234567', colors),
                      const SizedBox(height: 10),
                      _profileMetaLine('Plan', planLabel, colors),
                      const SizedBox(height: 10),
                      _profileMetaLine('Established On', '15 Jan 2021', colors),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _detailText(IconData icon, String value, AppThemeExtension colors) {
    return Row(
      children: [
        Icon(icon, size: 15, color: colors.textMuted),
        const SizedBox(width: 8),
        Text(
          value,
          style: TextStyle(
            color: colors.textSecondary,
            fontSize: 13,
          ),
        ),
      ],
    );
  }

  Widget _profileMetaLine(String label, String value, AppThemeExtension colors) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(color: colors.textSecondary, fontSize: 12),
        ),
        Text(
          value,
          style: TextStyle(
            color: colors.textPrimary,
            fontWeight: FontWeight.w600,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCards(AppThemeExtension colors) {
    final stats = [
      _StatCard(label: 'Clients', value: '0', subtitle: 'Total Clients', icon: Icons.people_alt_rounded, color: colors.primary),
      _StatCard(label: 'Active Tasks', value: '0', subtitle: 'In Progress', icon: Icons.task_alt_rounded, color: colors.secondary),
      _StatCard(label: 'Invoices', value: '0', subtitle: 'Total Invoices', icon: Icons.receipt_long_rounded, color: colors.tertiary),
      _StatCard(label: 'Revenue', value: '₹0.00', subtitle: 'This Month', icon: Icons.currency_rupee_rounded, color: colors.success),
      _StatCard(label: 'Experience', value: '4+', subtitle: 'Years', icon: Icons.workspace_premium_rounded, color: colors.warning),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: stats.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 5,
        crossAxisSpacing: 14,
        mainAxisSpacing: 14,
        childAspectRatio: 1.5,
      ),
      itemBuilder: (context, index) => stats[index],
    );
  }

  Widget _buildTabs(AppThemeExtension colors) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: colors.bg2,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: colors.glassBorderDim),
      ),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: List.generate(_tabs.length, (index) {
          final selected = _selectedTab == index;
          return GestureDetector(
            onTap: () => setState(() => _selectedTab = index),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: selected ? colors.primary.withValues(alpha: 0.12) : Colors.transparent,
                borderRadius: BorderRadius.circular(10),
                border: selected ? Border.all(color: colors.primary.withValues(alpha: 0.2)) : null,
              ),
              child: Text(
                _tabs[index],
                style: TextStyle(
                  color: selected ? colors.primary : colors.textSecondary,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
                  fontSize: 12,
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildMainContent(AppThemeExtension colors, Profile profile) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth > 880;
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _buildInfoCard(colors, profile),
            ),
            if (isWide) const SizedBox(width: 18),
            if (isWide)
              SizedBox(
                width: 300,
                child: _buildPhotoCard(colors),
              ),
          ],
        );
      },
    );
  }

  Widget _buildInfoCard(AppThemeExtension colors, Profile profile) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: colors.bg2,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colors.glassBorderDim),
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Personal Information',
              style: TextStyle(
                color: colors.textPrimary,
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 18),
            GridView(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 14,
                childAspectRatio: 4.2,
              ),
              children: [
                _readOnlyField('Full Name', profile.fullName ?? '—', colors, Icons.person_outline_rounded),
                _readOnlyField('Email Address', profile.email ?? '—', colors, Icons.email_outlined),
                _readOnlyField('Phone Number', profile.phone ?? '—', colors, Icons.phone_outlined),
                _readOnlyField('Date of Birth', '12 Mar 1995', colors, Icons.cake_rounded),
                _readOnlyField('Gender', 'Female', colors, Icons.person_2_outlined),
                _readOnlyField('Address', '123, 4th Cross, 2nd Main, Bengaluru', colors, Icons.home_outlined),
              ],
            ),
            const SizedBox(height: 18),
            AppTextField(
              controller: _fullNameController,
              label: 'Full Name',
              prefixIcon: Icons.person_outline_rounded,
              validator: (value) => value == null || value.trim().isEmpty ? 'Full name is required.' : null,
            ),
            const SizedBox(height: 14),
            AppTextField(
              controller: _phoneController,
              label: 'Phone',
              prefixIcon: Icons.phone_outlined,
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                Expanded(
                  child: AppPrimaryButton(
                    label: 'Save Changes',
                    onPressed: _saving ? null : _save,
                    loading: _saving,
                    icon: Icons.check_rounded,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _showChangePasswordDialog,
                    icon: const Icon(Icons.lock_outline_rounded),
                    label: const Text('Change Password'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: colors.textPrimary,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      side: BorderSide(color: colors.glassBorderDim),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPhotoCard(AppThemeExtension colors) {
    final initials = (_profile?.fullName?.isNotEmpty == true ? _profile!.fullName![0] : _profile?.email?[0] ?? '?').toUpperCase();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colors.bg2,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colors.glassBorderDim),
      ),
      child: Column(
        children: [
          Text(
            'Profile Picture',
            style: TextStyle(
              color: colors.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 20),
          Container(
            width: 150,
            height: 150,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [colors.primary, colors.primaryDark],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 5),
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
                        fontSize: 52,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  )
                : null,
          ),
          const SizedBox(height: 14),
          Text(
            'JPG, GIF or PNG, Max size of 2MB.',
            style: TextStyle(color: colors.textSecondary, fontSize: 12),
          ),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            child: AppPrimaryButton(
              label: 'Change Picture',
              onPressed: _uploadingImage ? null : _pickAndUploadAvatar,
              loading: _uploadingImage,
              icon: Icons.upload_file_rounded,
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.delete_outline_rounded),
              label: const Text('Remove'),
              style: OutlinedButton.styleFrom(
                foregroundColor: colors.textPrimary,
                padding: const EdgeInsets.symmetric(vertical: 15),
                side: BorderSide(color: colors.glassBorderDim),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentActivity(AppThemeExtension colors) {
    const items = [
      _ActivityItem(title: 'Profile updated', subtitle: 'You updated your profile number', time: '2 May 2024, 10:30 AM'),
      _ActivityItem(title: 'Profile picture changed', subtitle: 'You changed your profile picture', time: '20 Apr 2024, 04:15 PM'),
      _ActivityItem(title: 'Login', subtitle: 'You logged in from Bengaluru, India', time: '20 Apr 2024, 09:10 AM'),
    ];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: colors.bg2,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colors.glassBorderDim),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Recent Activity',
            style: TextStyle(
              color: colors.textPrimary,
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 18),
          ...items.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 26,
                    height: 26,
                    decoration: BoxDecoration(
                      color: colors.primary.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(Icons.circle, size: 8, color: colors.primary),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.title,
                              style: TextStyle(
                                color: colors.textPrimary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              item.subtitle,
                              style: TextStyle(
                                color: colors.textSecondary,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                        Text(
                          item.time,
                          style: TextStyle(
                            color: colors.textMuted,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () {},
              child: Text(
                'View All Activity',
                style: TextStyle(
                  color: colors.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _readOnlyField(String label, String value, AppThemeExtension colors, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: colors.bg1,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colors.glassBorderDim),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: colors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 14, color: colors.primary),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: colors.textSecondary,
                    fontSize: 11,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    color: colors.textPrimary,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
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
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.label,
    required this.value,
    required this.subtitle,
    required this.icon,
    required this.color,
  });

  final String label;
  final String value;
  final String subtitle;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colors.bg2,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.glassBorderDim),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 18, color: color),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: colors.textSecondary,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    color: colors.textPrimary,
                    fontWeight: FontWeight.w700,
                    fontSize: 20,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: colors.textMuted,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ActivityItem {
  const _ActivityItem({
    required this.title,
    required this.subtitle,
    required this.time,
  });

  final String title;
  final String subtitle;
  final String time;
}
