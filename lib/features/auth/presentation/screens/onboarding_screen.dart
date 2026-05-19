import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/wb_theme_exports.dart';
import '../../../../core/utils/wb_actions.dart';
import '../../../../core/widgets/wb_widgets.dart';

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

  void _next() {
    if (_step < 2) {
      setState(() => _step++);
    } else {
      context.go(AppRoutes.home);
    }
  }

  void _skipAll() => context.go(AppRoutes.home);

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
                      'Skip',
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
          'A couple of quick\npermissions',
          style: WBTypography.hero.copyWith(fontSize: 30, height: 1.15),
        ),
        const SizedBox(height: WBSpacing.sm + 2),
        Text(
          'They make the basket work better for you. You can change these anytime.',
          style: WBTypography.body.copyWith(
            color: WBColors.fgSecondary,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: WBSpacing.xl),
        _PermissionCard(
          icon: WBIconName.pin,
          title: 'Where are you cooking today?',
          sub: 'We need your location to show restaurants and markets near you. We never share your exact location with anyone.',
          primary: 'While using app',
          secondary: 'Allow once',
          tertiary: 'Not now',
        ),
        const SizedBox(height: WBSpacing.md),
        _PermissionCard(
          icon: WBIconName.bell,
          title: "Don't miss the good stuff",
          sub: "We'll tell you when your order is on its way, when your meat is freshly cut, and when there's a surprise waiting.",
          primary: 'Yes, tell me',
          secondary: 'Maybe later',
        ),
        const SizedBox(height: WBSpacing.xl),
        WBButton(
          label: 'Continue',
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
  });
  final WBIconName icon;
  final String title;
  final String sub;
  final String primary;
  final String secondary;
  final String? tertiary;

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
                  onPressed: () =>
                      wbShowSnack(context, '$primary — thanks!'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: WBButton(
                  label: secondary,
                  size: WBButtonSize.sm,
                  fullWidth: true,
                  variant: WBButtonVariant.secondary,
                  onPressed: () {},
                ),
              ),
            ],
          ),
          if (tertiary != null) ...[
            const SizedBox(height: 6),
            Center(
              child: GestureDetector(
                onTap: () {},
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

  static const _wantOptions = [
    'Cooked meals from restaurants',
    'Fresh fruits and vegetables',
    'Meat, chicken, and fish',
    'Pots, pans, and pantry stuff',
  ];
  static const _speedOptions = [
    "Right now, I'm hungry",
    'Today sometime',
    "I'm planning ahead",
  ];

  @override
  void dispose() {
    _avoid.dispose();
    super.dispose();
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
          "Let's build your basket",
          style: WBTypography.hero.copyWith(fontSize: 30, height: 1.15),
        ),
        const SizedBox(height: WBSpacing.sm + 2),
        Text(
          "Tell us what you love, and we'll make sure you see it first.",
          style: WBTypography.body.copyWith(
            color: WBColors.fgSecondary,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: WBSpacing.xl),
        _QuizLabel('What do you usually want?'),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final o in _wantOptions)
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
        _QuizLabel('How fast do you need things?'),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final o in _speedOptions)
              WBTag(
                label: o,
                active: _speed == o,
                onTap: () => setState(() => _speed = o),
              ),
          ],
        ),
        const SizedBox(height: WBSpacing.lg),
        _QuizLabel('Any foods we should avoid?'),
        const SizedBox(height: 10),
        WBInput(
          controller: _avoid,
          placeholder: 'e.g. no shellfish, no beef',
        ),
        const SizedBox(height: WBSpacing.xl),
        WBButton(
          label: 'Build my basket',
          size: WBButtonSize.lg,
          fullWidth: true,
          trailingIcon: WBIconName.arrowRight,
          onPressed: widget.onNext,
        ),
        const SizedBox(height: WBSpacing.sm + 4),
        Center(
          child: GestureDetector(
            onTap: widget.onNext,
            child: Text(
              "I'll figure it out later",
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
            'A little welcome gift',
            textAlign: TextAlign.center,
            style: WBTypography.hero.copyWith(fontSize: 28),
          ),
          const SizedBox(height: WBSpacing.sm),
          Text(
            'Your first order comes with something extra. Just because you deserve it.',
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
            label: "Let's see what's inside",
            size: WBButtonSize.lg,
            fullWidth: true,
            trailingIcon: WBIconName.arrowRight,
            onPressed: onNext,
          ),
          const SizedBox(height: WBSpacing.sm + 4),
          Text(
            'Valid for first order only. Minimum order applies.',
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
