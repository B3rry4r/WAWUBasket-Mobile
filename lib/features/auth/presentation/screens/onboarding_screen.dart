import 'dart:typed_data';
import 'dart:io';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:go_router/go_router.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/wb_theme_exports.dart';
import '../../../../core/utils/wb_actions.dart';
import '../../../../core/utils/wb_l10n.dart';
import '../../../../core/utils/wb_permissions.dart';
import '../../../../core/widgets/wb_widgets.dart';
import '../../../account/data/profile_api.dart';

/// Post-OTP customer onboarding. Three steps in one screen:
/// permissions → preference quiz → first-order gift. Lands on /home.
/// Content copy follows the brand guide (Part 1).
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  int _step = 0;
  bool _quizAlreadyDone = false;
  bool _loadingQuizCheck = true;

  @override
  void initState() {
    super.initState();
    _checkQuizStatus();
  }

  Future<void> _checkQuizStatus() async {
    try {
      final prefs = await ProfileApi.instance.getQuizPreferences();
      if (mounted) setState(() => _quizAlreadyDone = prefs != null && prefs.isNotEmpty);
    } catch (_) {
      // On failure assume not done — safer to show the quiz than skip it.
    } finally {
      if (mounted) setState(() => _loadingQuizCheck = false);
    }
  }

  List<Widget> _computeSteps() => [
    if (!kIsWeb) _PermissionsStep(key: const ValueKey('perms'), onNext: _next),
    if (!_quizAlreadyDone) _QuizStep(key: const ValueKey('quiz'), onNext: _next),
    _GiftStep(key: const ValueKey('gift'), onNext: _next),
  ];

  Future<void> _markDoneAndGo() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboardingDone', true);
    if (!mounted) return;
    context.go(AppRoutes.home);
  }

  void _next() {
    final steps = _computeSteps();
    if (_step < steps.length - 1) {
      setState(() => _step++);
    } else {
      _markDoneAndGo();
    }
  }

  void _skipAll() => _markDoneAndGo();

  @override
  Widget build(BuildContext context) {
    if (_loadingQuizCheck) {
      return const Scaffold(
        backgroundColor: WBColors.bgPrimary,
        body: Center(
          child: SizedBox(
            width: 28,
            height: 28,
            child: CircularProgressIndicator(
              strokeWidth: 2.6,
              valueColor: AlwaysStoppedAnimation(WBColors.surfaceDark),
            ),
          ),
        ),
      );
    }

    final steps = _computeSteps();
    final total = steps.length;

    return Scaffold(
      backgroundColor: WBColors.bgPrimary,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                WBSpacing.screenPadding, 12, WBSpacing.screenPadding, 0),
              child: Row(
                children: [
                  for (var i = 0; i < total; i++) ...[
                    Expanded(
                      child: AnimatedContainer(
                        duration: WBMotion.base,
                        height: 4,
                        decoration: BoxDecoration(
                          color: i <= _step ? WBColors.surfaceDark : WBColors.bgSoft,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    if (i != total - 1) const SizedBox(width: 6),
                  ],
                  const SizedBox(width: 14),
                  GestureDetector(
                    onTap: _skipAll,
                    child: Text(
                      context.l10n.onboardingSkip,
                      style: WBTypography.secondary.copyWith(
                        color: WBColors.fgSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: AnimatedSwitcher(
                duration: WBMotion.base,
                child: _step < steps.length ? steps[_step] : steps.last,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ───────────────────────── Step 1 · Permissions (mobile only) ───────────

class _PermissionsStep extends StatefulWidget {
  const _PermissionsStep({super.key, required this.onNext});
  final VoidCallback onNext;

  @override
  State<_PermissionsStep> createState() => _PermissionsStepState();
}

class _PermissionsStepState extends State<_PermissionsStep> {
  bool _requesting = false;

  Future<void> _grantAndNext() async {
    setState(() => _requesting = true);
    // Only request each permission if not already granted.
    if (!await WBPermissions.hasLocation()) {
      await WBPermissions.requestLocation();
    }
    if (!await WBPermissions.hasNotifications()) {
      await WBPermissions.requestNotifications();
    }
    if (mounted) widget.onNext();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
          WBSpacing.screenPadding, WBSpacing.xl,
          WBSpacing.screenPadding, WBSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Spacer(),
          Text(
            context.l10n.onboardingPermissionsTitle,
            style: WBTypography.hero.copyWith(fontSize: 30, height: 1.15),
          ),
          const SizedBox(height: WBSpacing.sm + 2),
          Text(
            context.l10n.onboardingPermissionsSubtitle,
            style: WBTypography.body.copyWith(
                color: WBColors.fgSecondary, fontSize: 14, height: 1.5),
          ),
          const SizedBox(height: WBSpacing.xl),
          _PermItem(
            icon: WBIconName.pin,
            label: context.l10n.onboardingLocationTitle,
            sub: context.l10n.onboardingLocationBody,
          ),
          const SizedBox(height: WBSpacing.md),
          _PermItem(
            icon: WBIconName.bell,
            label: context.l10n.onboardingNotificationsTitle,
            sub: context.l10n.onboardingNotificationsBody,
          ),
          const Spacer(),
          WBButton(
            label: context.l10n.actionContinue,
            size: WBButtonSize.lg,
            fullWidth: true,
            trailingIcon: WBIconName.arrowRight,
            loading: _requesting,
            onPressed: _requesting ? null : _grantAndNext,
          ),
        ],
      ),
    );
  }
}

class _PermItem extends StatelessWidget {
  const _PermItem({required this.icon, required this.label, required this.sub});
  final WBIconName icon;
  final String label;
  final String sub;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: WBColors.bgSoft,
            borderRadius: BorderRadius.circular(12),
          ),
          alignment: Alignment.center,
          child: WBIcon(icon, size: 18),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: WBTypography.body
                      .copyWith(fontWeight: FontWeight.w600, fontSize: 14)),
              const SizedBox(height: 3),
              Text(sub,
                  style: WBTypography.caption.copyWith(
                      color: WBColors.fgSecondary, height: 1.45)),
            ],
          ),
        ),
      ],
    );
  }
}

// ───────────────────────── Step 2 · Preference quiz ─────────────────────

class _QuizStep extends StatefulWidget {
  const _QuizStep({super.key, required this.onNext});
  final VoidCallback onNext;

  @override
  State<_QuizStep> createState() => _QuizStepState();
}

class _QuizStepState extends State<_QuizStep> {
  final Set<String> _wants = {};
  String _speed = '';
  final _avoid = TextEditingController();
  bool _saving = false;

  List<String> _wantOptions(BuildContext context) => [
    context.l10n.onboardingQuizWantOption1,
    context.l10n.onboardingQuizWantOption2,
    context.l10n.onboardingQuizWantOption3,
    context.l10n.onboardingQuizWantOption4,
  ];
  List<String> _speedOptions(BuildContext context) => [
    context.l10n.onboardingQuizSpeedOption1,
    context.l10n.onboardingQuizSpeedOption2,
    context.l10n.onboardingQuizSpeedOption3,
  ];

  @override
  void dispose() {
    _avoid.dispose();
    super.dispose();
  }

  Future<void> _saveAndNext() async {
    setState(() => _saving = true);
    try {
      await ProfileApi.instance.saveQuizPreferences(
        wantCategories: _wants.toList(),
        deliverySpeed: _speed.isNotEmpty ? _speed : null,
        avoidFoods: _avoid.text.trim().isNotEmpty ? _avoid.text.trim() : null,
      );
    } catch (_) {
      // Non-blocking — proceed to next step regardless.
    } finally {
      if (mounted) setState(() => _saving = false);
    }
    if (mounted) widget.onNext();
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(
        WBSpacing.screenPadding,
        WBSpacing.xl,
        WBSpacing.screenPadding,
        WBSpacing.xl,
      ),
      children: [
        Text(
          context.l10n.onboardingQuizTitle,
          style: WBTypography.hero.copyWith(fontSize: 30, height: 1.15),
        ),
        const SizedBox(height: WBSpacing.sm + 2),
        Text(
          context.l10n.onboardingQuizSubtitle,
          style: WBTypography.body.copyWith(
            color: WBColors.fgSecondary,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: WBSpacing.xl),
        _QuizLabel(context.l10n.onboardingQuizWantsLabel),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final o in _wantOptions(context))
              WBTag(
                label: o,
                active: _wants.contains(o),
                onTap: () => setState(() {
                  _wants.contains(o) ? _wants.remove(o) : _wants.add(o);
                }),
              ),
          ],
        ),
        const SizedBox(height: WBSpacing.lg),
        _QuizLabel(context.l10n.onboardingQuizSpeedLabel),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final o in _speedOptions(context))
              WBTag(
                label: o,
                active: _speed == o,
                onTap: () => setState(() => _speed = o),
              ),
          ],
        ),
        const SizedBox(height: WBSpacing.lg),
        _QuizLabel(context.l10n.onboardingQuizAvoidLabel),
        const SizedBox(height: 10),
        WBInput(
          controller: _avoid,
          placeholder: context.l10n.onboardingQuizAvoidPlaceholder,
        ),
        const SizedBox(height: WBSpacing.xl),
        WBButton(
          label: context.l10n.onboardingQuizBuildButton,
          size: WBButtonSize.lg,
          fullWidth: true,
          trailingIcon: WBIconName.arrowRight,
          loading: _saving,
          onPressed: _saving ? null : _saveAndNext,
        ),
        const SizedBox(height: WBSpacing.sm + 4),
        Center(
          child: GestureDetector(
            onTap: _saving ? null : widget.onNext,
            child: Text(
              context.l10n.onboardingQuizSkipLink,
              style: WBTypography.secondary.copyWith(
                color: WBColors.fgSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _QuizLabel extends StatelessWidget {
  const _QuizLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: WBTypography.cardTitle.copyWith(fontSize: 16),
    );
  }
}

// ───────────────────────── Step 3 · First-order gift ────────────────────

class _GiftStep extends StatefulWidget {
  const _GiftStep({super.key, required this.onNext});
  final VoidCallback onNext;

  @override
  State<_GiftStep> createState() => _GiftStepState();
}

class _GiftStepState extends State<_GiftStep> {
  bool _downloading = false;

  Future<void> _downloadPlaybook() async {
    if (_downloading) return;
    setState(() => _downloading = true);
    try {
      final ByteData data = await rootBundle.load('assets/docs/business_playbook.pdf');
      final dir = await getApplicationDocumentsDirectory();
      final file = File(p.join(dir.path, 'WAWUAfrica_Business_Playbook.pdf'));
      await file.writeAsBytes(data.buffer.asUint8List(), flush: true);
      await OpenFilex.open(file.path);
    } catch (e) {
      if (mounted) wbShowSnack(context, 'Could not open the playbook. Try again.');
    } finally {
      if (mounted) setState(() => _downloading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        WBSpacing.screenPadding,
        WBSpacing.xl,
        WBSpacing.screenPadding,
        WBSpacing.xl,
      ),
      child: Column(
        children: [
          const Spacer(),
          Container(
            width: 96,
            height: 96,
            decoration: BoxDecoration(
              color: WBColors.surfaceDark,
              borderRadius: BorderRadius.circular(28),
            ),
            alignment: Alignment.center,
            child: const WBIcon(
              WBIconName.basket,
              size: 40,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: WBSpacing.xl),
          Text(
            context.l10n.onboardingGiftTitle,
            textAlign: TextAlign.center,
            style: WBTypography.hero.copyWith(fontSize: 28),
          ),
          const SizedBox(height: WBSpacing.sm),
          Text(
            context.l10n.onboardingGiftBody,
            textAlign: TextAlign.center,
            style: WBTypography.body.copyWith(
              color: WBColors.fgSecondary,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: WBSpacing.lg),
          GestureDetector(
            onTap: _downloadPlaybook,
            child: Container(
              padding: const EdgeInsets.all(WBSpacing.md),
              decoration: BoxDecoration(
                color: WBColors.bgSoft,
                borderRadius: BorderRadius.circular(WBRadius.card),
              ),
              child: Row(
                children: [
                  if (_downloading)
                    const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  else
                    const WBIcon(WBIconName.star, size: 16),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Gift: Download The Business Playbook',
                      style: WBTypography.body.copyWith(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  const WBIcon(WBIconName.arrowRight, size: 14),
                ],
              ),
            ),
          ),
          const Spacer(),
          WBButton(
            label: context.l10n.onboardingGiftButton,
            size: WBButtonSize.lg,
            fullWidth: true,
            trailingIcon: WBIconName.arrowRight,
            onPressed: widget.onNext,
          ),
          const SizedBox(height: WBSpacing.sm + 4),
          Text(
            context.l10n.onboardingGiftFootnote,
            textAlign: TextAlign.center,
            style: WBTypography.caption.copyWith(
              color: WBColors.fgPlaceholder,
            ),
          ),
        ],
      ),
    );
  }
}
