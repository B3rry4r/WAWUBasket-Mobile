import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/network/api_exception.dart';
import '../../../../core/network/upload_service.dart';
import '../../../../core/theme/wb_theme_exports.dart';
import '../../../../core/utils/wb_actions.dart';
import '../../../../core/widgets/wb_widgets.dart';
import '../../../shopping/application/wb_images.dart';
import '../../application/profile_controller.dart';
import '../../data/profile_api.dart';

class PersonalInfoScreen extends StatefulWidget {
  const PersonalInfoScreen({super.key});

  @override
  State<PersonalInfoScreen> createState() => _PersonalInfoScreenState();
}

const _months = [
  'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
  'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
];

class _PersonalInfoScreenState extends State<PersonalInfoScreen> {
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _phone = TextEditingController();
  final _dob = TextEditingController();
  bool _busy = false;
  bool _uploadingAvatar = false;
  String? _avatarUrl;

  Future<void> _pickAvatar() async {
    setState(() => _uploadingAvatar = true);
    try {
      final res = await UploadService.instance
          .pickAndUpload(folder: UploadFolder.avatars);
      if (res == null) {
        if (mounted) setState(() => _uploadingAvatar = false);
        return;
      }
      await ProfileApi.instance.updateAvatar(res.key);
      if (!mounted) return;
      setState(() {
        _avatarUrl = res.publicUrl;
        _uploadingAvatar = false;
      });
      wbShowSnack(context, 'Photo updated');
    } on ApiException catch (e) {
      if (mounted) {
        setState(() => _uploadingAvatar = false);
        wbShowSnack(context, e.message);
      }
    } catch (_) {
      if (mounted) {
        setState(() => _uploadingAvatar = false);
        wbShowSnack(context, "Couldn't upload that photo.");
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _phone.dispose();
    _dob.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final cached = ProfileController.instance.profile.value;
    if (cached != null) _apply(cached);
    await ProfileController.instance.load();
    final fresh = ProfileController.instance.profile.value;
    if (fresh != null && mounted) setState(() => _apply(fresh));
  }

  void _apply(UserProfile p) {
    _name.text = p.fullName;
    _email.text = p.email;
    _phone.text = p.phone;
    final d = p.dateOfBirth;
    _dob.text =
        d == null ? '' : '${d.day} ${_months[d.month - 1]} ${d.year}';
  }

  Future<void> _save() async {
    if (_name.text.trim().isEmpty) {
      wbShowSnack(context, 'Enter your full name.');
      return;
    }
    setState(() => _busy = true);
    try {
      await ProfileController.instance.update(
        fullName: _name.text.trim(),
        email: _email.text.trim(),
      );
      if (!mounted) return;
      wbShowSnack(context, 'Changes saved');
      context.pop();
    } on ApiException catch (e) {
      if (mounted) wbShowSnack(context, e.message);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: WBColors.bgPrimary,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            WBSpacing.screenPadding,
            12,
            WBSpacing.screenPadding,
            40,
          ),
          children: [
            Row(
              children: [
                WBBackChip(onPressed: () => context.pop()),
                const SizedBox(width: 14),
                Text('Personal information', style: WBTypography.page),
              ],
            ),
            const SizedBox(height: WBSpacing.lg),
            // Profile photo picker
            Center(
              child: GestureDetector(
                onTap: _uploadingAvatar ? null : _pickAvatar,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      width: 108,
                      height: 108,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: WBColors.bgDivider,
                          width: 2,
                        ),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: WBNetworkImage(
                        url: _avatarUrl ?? WBImages.avatar,
                      ),
                    ),
                    if (_uploadingAvatar)
                      Positioned.fill(
                        child: Container(
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Color(0x66000000),
                          ),
                          alignment: Alignment.center,
                          child: const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.4,
                              valueColor:
                                  AlwaysStoppedAnimation(Colors.white),
                            ),
                          ),
                        ),
                      ),
                    Positioned(
                      right: 2,
                      bottom: 2,
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: WBColors.surfaceDark,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: WBColors.bgPrimary,
                            width: 2,
                          ),
                        ),
                        alignment: Alignment.center,
                        child: const WBIcon(
                          WBIconName.plus,
                          size: 14,
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10),
            Center(
              child: Text(
                'Tap to change photo',
                style: WBTypography.caption.copyWith(
                  color: WBColors.fgSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(height: WBSpacing.lg),
            WBInput(
              label: 'Full name',
              controller: _name,
              leadingIcon: WBIconName.user,
            ),
            const SizedBox(height: WBSpacing.md),
            WBInput(
              label: 'Email',
              controller: _email,
              leadingIcon: WBIconName.message,
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: WBSpacing.md),
            WBInput(
              label: 'Phone number',
              controller: _phone,
              leadingIcon: WBIconName.phone,
              enabled: false,
            ),
            const SizedBox(height: WBSpacing.md),
            WBInput(
              label: 'Date of birth',
              controller: _dob,
              leadingIcon: WBIconName.clock,
              enabled: false,
            ),
            const SizedBox(height: WBSpacing.xl),
            WBButton(
              label: 'Save changes',
              size: WBButtonSize.lg,
              fullWidth: true,
              loading: _busy,
              onPressed: _save,
            ),
          ],
        ),
      ),
    );
  }
}
