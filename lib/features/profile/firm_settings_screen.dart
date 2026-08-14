import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/config/app_theme.dart';
import '../../core/errors/app_failure.dart';
import '../../core/services/firm_service.dart';
import '../../core/services/profile_service.dart';
import '../../core/widgets/app_widgets.dart';
import '../../core/widgets/role_guard.dart';
import '../../models/firm.dart';
import '../../models/profile.dart';

/// Only visible via nav for ca/super_admin (see ProfileScreen's
/// RoleGuard). Also handles the case where a staff/client user reaches
/// this screen directly (deep link, stale nav) by showing
/// [PermissionDeniedView] instead of a blank or broken form.
class FirmSettingsScreen extends StatefulWidget {
  const FirmSettingsScreen({super.key});

  @override
  State<FirmSettingsScreen> createState() => _FirmSettingsScreenState();
}

class _FirmSettingsScreenState extends State<FirmSettingsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firmNameController = TextEditingController();
  final _registrationNumberController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  final _pincodeController = TextEditingController();

  Profile? _profile;
  Firm? _firm;
  String? _logoUrl;

  bool _loading = true;
  bool _saving = false;
  bool _uploadingLogo = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _firmNameController.dispose();
    _registrationNumberController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _pincodeController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final profile = await ProfileService.instance.getCurrentProfile();

      if (!RoleGuard.isAllowed(
          profile.role, const [UserRole.ca, UserRole.superAdmin])) {
        if (!mounted) return;
        setState(() {
          _profile = profile;
          _loading = false;
        });
        return;
      }

      final firm = await FirmService.instance.getCurrentFirm();
      final logoUrl =
          await FirmService.instance.getLogoSignedUrl(firm?.logoUrl);

      if (!mounted) return;
      setState(() {
        _profile = profile;
        _firm = firm;
        _logoUrl = logoUrl;
        _firmNameController.text = firm?.firmName ?? '';
        _registrationNumberController.text = firm?.registrationNumber ?? '';
        _emailController.text = firm?.email ?? '';
        _phoneController.text = firm?.phone ?? '';
        _addressController.text = firm?.address ?? '';
        _cityController.text = firm?.city ?? '';
        _stateController.text = firm?.state ?? '';
        _pincodeController.text = firm?.pincode ?? '';
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
        _error = 'Unable to load firm details. Please try again.';
        _loading = false;
      });
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final firm = _firm;
    if (firm == null) return;

    setState(() => _saving = true);
    try {
      final updated = await FirmService.instance.updateFirm(
        firmId: firm.id,
        firmName: _firmNameController.text.trim(),
        registrationNumber: _registrationNumberController.text.trim(),
        email: _emailController.text.trim(),
        phone: _phoneController.text.trim(),
        address: _addressController.text.trim(),
        city: _cityController.text.trim(),
        state: _stateController.text.trim(),
        pincode: _pincodeController.text.trim(),
      );
      if (!mounted) return;
      setState(() {
        _firm = updated;
        _saving = false;
      });
      _showSnack('Firm details updated successfully.', success: true);
    } on AppFailure catch (e) {
      if (!mounted) return;
      setState(() => _saving = false);
      _showSnack(e.message);
    } catch (_) {
      if (!mounted) return;
      setState(() => _saving = false);
      _showSnack('Unable to update firm details. Please try again.');
    }
  }

  Future<void> _pickAndUploadLogo() async {
    final firm = _firm;
    if (firm == null) return;

    final picker = ImagePicker();
    final XFile? file = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 90,
    );
    if (file == null) return;

    setState(() => _uploadingLogo = true);
    try {
      final bytes = await file.readAsBytes();
      final updated = await FirmService.instance.uploadFirmLogo(
        firmId: firm.id,
        bytes: bytes,
        fileName: file.name,
      );
      final logoUrl =
          await FirmService.instance.getLogoSignedUrl(updated.logoUrl);
      if (!mounted) return;
      setState(() {
        _firm = updated;
        _logoUrl = logoUrl;
        _uploadingLogo = false;
      });
      _showSnack('Firm logo updated.', success: true);
    } on AppFailure catch (e) {
      if (!mounted) return;
      setState(() => _uploadingLogo = false);
      _showSnack(e.message);
    } catch (_) {
      if (!mounted) return;
      setState(() => _uploadingLogo = false);
      _showSnack('Logo upload failed. Please try again.');
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

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Scaffold(
      backgroundColor: colors.bg1,
      body: Column(
        children: [
          _buildAppBar(),
          Expanded(child: _buildBody()),
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
                  'Firm Settings',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: colors.textPrimary,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(width: 48),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBody() {
    final colors = context.appColors;
    if (_loading) {
      return Center(
        child: CircularProgressIndicator(color: colors.primary),
      );
    }

    if (_error != null) {
      return AppErrorState(message: _error!, onRetry: _load);
    }

    final profile = _profile!;
    if (!RoleGuard.isAllowed(
        profile.role, const [UserRole.ca, UserRole.superAdmin])) {
      return const PermissionDeniedView();
    }

    if (_firm == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: colors.warning.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppRadius.xl),
                ),
                child: Icon(Icons.warning, color: colors.warning,
                  size: 32,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'No Firm Linked',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: colors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'No firm is linked to your account yet.\nContact your administrator.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: colors.textSecondary,
                  fontSize: 14,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      color: colors.primary,
      backgroundColor: colors.bg2,
      onRefresh: _load,
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Logo section
          _buildLogoSection(),
          const SizedBox(height: 24),
          // Plan badge
          _buildPlanBadge(),
          const SizedBox(height: 20),
          // Firm details form
          AppCard(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Firm Details',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: colors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  AppTextField(
                    controller: _firmNameController,
                    label: 'Firm Name',
                    prefixIcon: Icons.business_rounded,
                    validator: (v) => (v == null || v.trim().isEmpty)
                        ? 'Firm name is required.'
                        : null,
                  ),
                  const SizedBox(height: 14),
                  AppTextField(
                    controller: _registrationNumberController,
                    label: 'Registration Number',
                    prefixIcon: Icons.badge_rounded,
                  ),
                  const SizedBox(height: 14),
                  AppTextField(
                    controller: _emailController,
                    label: 'Firm Email',
                    prefixIcon: Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 14),
                  AppTextField(
                    controller: _phoneController,
                    label: 'Firm Phone',
                    prefixIcon: Icons.phone_outlined,
                    keyboardType: TextInputType.phone,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Address section
          AppCard(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Address',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: colors.textPrimary,
                  ),
                ),
                const SizedBox(height: 16),
                AppTextField(
                  controller: _addressController,
                  label: 'Street Address',
                  prefixIcon: Icons.location_on_outlined,
                  maxLines: 2,
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: AppTextField(
                        controller: _cityController,
                        label: 'City',
                        prefixIcon: Icons.location_city_rounded,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: AppTextField(
                        controller: _stateController,
                        label: 'State',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                AppTextField(
                  controller: _pincodeController,
                  label: 'Pincode',
                  prefixIcon: Icons.pin_drop_rounded,
                  keyboardType: TextInputType.number,
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          AppPrimaryButton(
            label: 'Save Changes',
            onPressed: _saving ? null : _save,
            loading: _saving,
            icon: Icons.check_rounded,
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildLogoSection() {
    final colors = context.appColors;
    final firm = _firm!;
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
                    colors: [colors.primaryDark, colors.secondary],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(AppRadius.xl),
                  boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 24, offset: const Offset(0, 8))],
                  image: _logoUrl != null
                      ? DecorationImage(
                          image: NetworkImage(_logoUrl!),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: _logoUrl == null
                    ? Icon(
                        Icons.business_rounded,
                        size: 38,
                        color: Colors.white,
                      )
                    : null,
              ),
              Positioned(
                bottom: 2,
                right: 2,
                child: GestureDetector(
                  onTap: _uploadingLogo ? null : _pickAndUploadLogo,
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
                    child: _uploadingLogo
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
            firm.firmName.isNotEmpty ? firm.firmName : 'Your Firm',
            style: TextStyle(color: colors.textPrimary,
            ),
          ),
          if (firm.registrationNumber?.isNotEmpty == true)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                firm.registrationNumber!,
                style: TextStyle(color: colors.textMuted,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPlanBadge() {
    final colors = context.appColors;
    final firm = _firm!;
    final plan = firm.subscriptionPlan ?? 'free';
    final status = firm.subscriptionStatus ?? 'active';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: colors.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: colors.primary.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Icon(Icons.info, color: colors.primary, size: 18),
          const SizedBox(width: 10),
          Text(
            'Plan: ${plan.toUpperCase()}',
            style: TextStyle(color: colors.textPrimary,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
          const Spacer(),
          AppBadge(
            label: status.toUpperCase(),
            color: status == 'active' ? colors.secondary : colors.warning,
          ),
        ],
      ),
    );
  }
}
