import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
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

  Future<void> _markDoneAndGo() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboardingDone', true);
    if (!mounted) return;
    context.go(AppRoutes.home);
  }

  void _next() {
    if (_step < 2) {
      setState(() => _step++);
    } else {
      _markDoneAndGo();
    }
  }

  void _skipAll() => _markDoneAndGo();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: WBColors.bgPrimary,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                WBSpacing.screenPadding,
                12,
                WBSpacing.screenPadding,
                0,
              ),
              child: Row(
                children: [
                  for (var i = 0; i < 3; i++) ...[
                    Expanded(
                      child: AnimatedContainer(
                        duration: WBMotion.base,
                        height: 4,
                        decoration: BoxDecoration(
                          color: i <= _step
                              ? WBColors.surfaceDark
                              : WBColors.bgSoft,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    if (i != 2) const SizedBox(width: 6),
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
                child: switch (_step) {
                  0 => _PermissionsStep(key: const ValueKey(0), onNext: _next),
                  1 => _QuizStep(key: const ValueKey(1), onNext: _next),
                  _ => _GiftStep(key: const ValueKey(2), onNext: _next),
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ───────────────────────── Step 1 · Permissions ─────────────────────────

class _PermissionsStep extends StatelessWidget {
  const _PermissionsStep({super.key, required this.onNext});
  final VoidCallback onNext;

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
          context.l10n.onboardingPermissionsTitle,
          style: WBTypography.hero.copyWith(fontSize: 30, height: 1.15),
        ),
        const SizedBox(height: WBSpacing.sm + 2),
        Text(
          context.l10n.onboardingPermissionsSubtitle,
          style: WBTypography.body.copyWith(
            color: WBColors.fgSecondary,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: WBSpacing.xl),
        _PermissionCard(
          icon: WBIconName.pin,
          title: context.l10n.onboardingLocationTitle,
          sub: context.l10n.onboardingLocationBody,
          primary: context.l10n.onboardingLocationPrimary,
          secondary: context.l10n.onboardingLocationSecondary,
          tertiary: context.l10n.onboardingLocationTertiary,
          onPrimary: WBPermissions.requestLocation,
          onSecondary: WBPermissions.requestLocation,
          onTertiary: onNext,
        ),
        const SizedBox(height: WBSpacing.md),
        _PermissionCard(
          icon: WBIconName.bell,
          title: context.l10n.onboardingNotificationsTitle,
          sub: context.l10n.onboardingNotificationsBody,
          primary: context.l10n.onboardingNotificationsPrimary,
          secondary: context.l10n.onboardingNotificationsSecondary,
          onPrimary: WBPermissions.requestNotifications,
        ),
        const SizedBox(height: WBSpacing.xl),
        WBButton(
          label: context.l10n.actionContinue,
          size: WBButtonSize.lg,
          fullWidth: true,
          trailingIcon: WBIconName.arrowRight,
          onPressed: onNext,
        ),
      ],
    );
  }
}

class _PermissionCard extends StatelessWidget {
  const _PermissionCard({
    required this.icon,
    required this.title,
    required this.sub,
    required this.primary,
    required this.secondary,
    this.tertiary,
    this.onPrimary,
    this.onSecondary,
    this.onTertiary,
  });
  final WBIconName icon;
  final String title;
  final String sub;
  final String primary;
  final String secondary;
  final String? tertiary;

  /// Real permission-handler callbacks. Returning `true` means the OS
  /// granted the permission. The card surfaces a snackbar either way.
  final Future<bool> Function()? onPrimary;
  final Future<bool> Function()? onSecondary;

  /// Called when the user taps the tertiary ("Not now") link.
  final VoidCallback? onTertiary;

  @override
  Widget build(BuildContext context) {
    return WBCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
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
                child: Text(
                  title,
                  style: WBTypography.body.copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            sub,
            style: WBTypography.caption.copyWith(
              color: WBColors.fgSecondary,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: WBButton(
                  label: primary,
                  size: WBButtonSize.sm,
                  fullWidth: true,
                  onPressed: () async {
                    final granted = await onPrimary?.call() ?? true;
                    if (!context.mounted) return;
                    wbShowSnack(
                      context,
                      granted
                          ? '$primary, thanks!'
                          : 'Permission denied. You can enable it later in settings.',
                    );
                  },
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: WBButton(
                  label: secondary,
                  size: WBButtonSize.sm,
                  fullWidth: true,
                  variant: WBButtonVariant.secondary,
                  onPressed: () async {
                    final granted = await onSecondary?.call() ?? true;
                    if (!context.mounted || onSecondary == null) return;
                    wbShowSnack(
                      context,
                      granted
                          ? '$secondary, thanks!'
                          : 'No problem, ask me later.',
                    );
                  },
                ),
              ),
            ],
          ),
          if (tertiary != null) ...[
            const SizedBox(height: 6),
            Center(
              child: GestureDetector(
                onTap: onTertiary,
                child: Text(
                  tertiary!,
                  style: WBTypography.caption.copyWith(
                    color: WBColors.fgPlaceholder,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
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

class _GiftStep extends StatelessWidget {
  const _GiftStep({super.key, required this.onNext});
  final VoidCallback onNext;

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
          Container(
            padding: const EdgeInsets.all(WBSpacing.md),
            decoration: BoxDecoration(
              color: WBColors.bgSoft,
              borderRadius: BorderRadius.circular(WBRadius.card),
            ),
            child: Row(
              children: [
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
              ],
            ),
          ),
          const Spacer(),
          WBButton(
            label: context.l10n.onboardingGiftButton,
            size: WBButtonSize.lg,
            fullWidth: true,
            trailingIcon: WBIconName.arrowRight,
            onPressed: onNext,
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
