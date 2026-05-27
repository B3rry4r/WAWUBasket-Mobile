import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/network/api_exception.dart';
import '../../../../core/network/upload_service.dart';
import '../../../../core/theme/wb_theme_exports.dart';
import '../../../../core/utils/wb_actions.dart';
import '../../../../core/utils/wb_l10n.dart';
import '../../../../core/widgets/wb_widgets.dart';
import '../../application/profile_controller.dart';
import '../../data/profile_api.dart';

class PersonalInfoScreen extends StatefulWidget {
  const PersonalInfoScreen({super.key});

  @override
  State<PersonalInfoScreen> createState() => _PersonalInfoScreenState();
}

class _PersonalInfoScreenState extends State<PersonalInfoScreen> {
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _phone = TextEditingController();
  bool _busy = false;
  bool _uploadingAvatar = false;
  String? _avatarUrl;

  String _nameInitials() {
    final parts = _name.text.trim().split(' ');
    if (parts.isEmpty || parts.first.isEmpty) return '?';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }

  Future<void> _pickAvatar() async {
    setState(() => _uploadingAvatar = true);
    try {
      final res = await UploadService.instance
          .pickAndUpload(folder: UploadFolder.avatars);
      if (res == null) {
        if (mounted) setState(() => _uploadingAvatar = false);
        return;
      }
      // Evict the previous avatar URL from the CachedNetworkImage disk cache so
      // the freshly uploaded photo is fetched on the next render instead of
      // serving the stale cached version:
      //   if (_avatarUrl != null) await CachedNetworkImage.evictFromCache(_avatarUrl!);
      await ProfileApi.instance.updateAvatar(res.key);
      if (!mounted) return;
      setState(() {
        _avatarUrl = res.publicUrl;
        _uploadingAvatar = false;
      });
      wbShowSnack(context, context.l10n.personalInfoPhotoUpdated);
    } on ApiException catch (e) {
      if (mounted) {
        setState(() => _uploadingAvatar = false);
        wbShowSnack(context, e.message);
      }
    } catch (_) {
      if (mounted) {
        setState(() => _uploadingAvatar = false);
        wbShowSnack(context, context.l10n.personalInfoPhotoFailed);
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
    _avatarUrl = p.avatarUrl;
  }

  Future<void> _save() async {
    if (_name.text.trim().isEmpty) {
      wbShowSnack(context, context.l10n.personalInfoNameRequired);
      return;
    }
    setState(() => _busy = true);
    try {
      await ProfileController.instance.update(
        fullName: _name.text.trim(),
        email: _email.text.trim(),
      );
      if (!mounted) return;
      wbShowSnack(context, context.l10n.personalInfoSaved);
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
                Text(context.l10n.personalInfoTitle, style: WBTypography.page),
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
                      child: _avatarUrl != null
                          ? WBNetworkImage(url: _avatarUrl!)
                          : Container(
                              color: WBColors.bgSoft,
                              alignment: Alignment.center,
                              child: Text(
                                _nameInitials(),
                                style: WBTypography.hero.copyWith(
                                  fontSize: 36,
                                  color: WBColors.fgHeader,
                                ),
                              ),
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
                context.l10n.personalInfoTapPhoto,
                style: WBTypography.caption.copyWith(
                  color: WBColors.fgSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(height: WBSpacing.lg),
            WBInput(
              label: context.l10n.personalInfoFullName,
              controller: _name,
              leadingIcon: WBIconName.user,
            ),
            const SizedBox(height: WBSpacing.md),
            WBInput(
              label: context.l10n.personalInfoEmail,
              controller: _email,
              leadingIcon: WBIconName.message,
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: WBSpacing.md),
            WBInput(
              label: context.l10n.personalInfoPhone,
              controller: _phone,
              leadingIcon: WBIconName.phone,
              enabled: false,
            ),
            const SizedBox(height: WBSpacing.xl),
            WBButton(
              label: context.l10n.personalInfoSave,
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
