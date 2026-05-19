import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/wb_theme_exports.dart';
import '../../../../core/utils/wb_actions.dart';
import '../../../../core/widgets/wb_widgets.dart';
import '../../../auth/application/role_controller.dart';

// ───────────────────── Rider login ─────────────────────

class RiderLoginScreen extends StatelessWidget {
  const RiderLoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: WBColors.bgPrimary,
      body: SafeArea(
        child: Padding(
          padding:
              const EdgeInsets.symmetric(horizontal: WBSpacing.screenPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 12),
              WBBackChip(onPressed: () => context.go(AppRoutes.welcome)),
              const SizedBox(height: WBSpacing.xl),
              Text('Rider login', style: WBTypography.hero),
              const SizedBox(height: WBSpacing.sm),
              Text(
                "Hop on. Today's deliveries are stacking up.",
                style:
                    WBTypography.body.copyWith(color: WBColors.fgSecondary),
              ),
              const SizedBox(height: WBSpacing.xl),
              const WBInput(
                label: 'Rider ID',
                initialValue: 'WAWU-RD-0821',
                leadingIcon: WBIconName.user,
              ),
              const SizedBox(height: WBSpacing.md),
              const WBInput(
                label: 'Password',
                initialValue: '••••••••',
                leadingIcon: WBIconName.card,
                obscureText: true,
              ),
              const Spacer(),
              WBButton(
                label: 'Sign in',
                size: WBButtonSize.lg,
                fullWidth: true,
                trailingIcon: WBIconName.arrowRight,
                onPressed: () {
                  RoleController.instance.completeKyc(AppRole.rider);
                  RoleController.instance.setRole(AppRole.rider);
                  context.go(AppRoutes.riderHome);
                },
              ),
              const SizedBox(height: WBSpacing.md),
              Center(
                child: GestureDetector(
                  onTap: () => context.push(AppRoutes.riderKyc),
                  child: RichText(
                    text: TextSpan(
                      style: WBTypography.secondary,
                      children: const [
                        TextSpan(text: 'New here? '),
                        TextSpan(
                          text: 'Apply to ride',
                          style: TextStyle(
                            color: WBColors.fgHeader,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: WBSpacing.xl),
            ],
          ),
        ),
      ),
    );
  }
}

// ───────────────────── Rider home (available deliveries) ─────────────────────

class RiderHomeScreen extends StatefulWidget {
  const RiderHomeScreen({super.key});

  @override
  State<RiderHomeScreen> createState() => _RiderHomeScreenState();
}

class _RiderHomeScreenState extends State<RiderHomeScreen> {
  bool _online = true;

  static const _deliveries = [
    (id: 'WAWU-8821', vendor: 'Mama Cass Kitchen', dropoff: 'V/I · 4.2 km', fee: 600, mins: 22),
    (id: 'WAWU-8822', vendor: 'Suya & Smoke', dropoff: 'Lekki · 6.1 km', fee: 800, mins: 28),
    (id: 'WAWU-8825', vendor: 'Iya Basira Buka', dropoff: 'Ikoyi · 2.8 km', fee: 500, mins: 16),
  ];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(
          WBSpacing.screenPadding,
          12,
          WBSpacing.screenPadding,
          140,
        ),
        children: [
          Container(
            padding: const EdgeInsets.all(WBSpacing.lg),
            decoration: BoxDecoration(
              color: WBColors.surfaceDark,
              borderRadius: BorderRadius.circular(WBRadius.card),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Hi, Tunde',
                            style: WBTypography.hero.copyWith(
                              color: Colors.white,
                              fontSize: 22,
                            ),
                          ),
                          Text(
                            'Today · ₦4,800 earned · 6 deliveries',
                            style: WBTypography.caption.copyWith(
                              color: Colors.white.withValues(alpha: 0.6),
                            ),
                          ),
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: () => setState(() => _online = !_online),
                      child: AnimatedContainer(
                        duration: WBMotion.base,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: _online
                              ? Colors.white
                              : Colors.white.withValues(alpha: 0.12),
                          borderRadius:
                              BorderRadius.circular(WBRadius.pill),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 7,
                              height: 7,
                              decoration: BoxDecoration(
                                color: _online
                                    ? const Color(0xFF10B981)
                                    : Colors.white.withValues(alpha: 0.5),
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              _online ? 'Online' : 'Offline',
                              style: WBTypography.caption.copyWith(
                                color: _online
                                    ? WBColors.fgHeader
                                    : Colors.white,
                                fontWeight: FontWeight.w600,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: WBSpacing.lg),
          Text(
            _online ? 'Deliveries near you' : "You're offline",
            style: WBTypography.cardTitle.copyWith(fontSize: 17),
          ),
          const SizedBox(height: 10),
          if (!_online)
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: WBColors.bgSoft,
                borderRadius: BorderRadius.circular(WBRadius.card),
              ),
              child: Text(
                'Go online to start receiving delivery offers.',
                style: WBTypography.body.copyWith(
                  color: WBColors.fgSecondary,
                  fontSize: 14,
                ),
              ),
            )
          else
            for (final d in _deliveries)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: WBCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              '#${d.id}',
                              style: WBTypography.caption.copyWith(
                                color: WBColors.fgSecondary,
                              ),
                            ),
                          ),
                          Text(
                            '${d.mins} min',
                            style: WBTypography.caption.copyWith(
                              color: WBColors.fgSecondary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        d.vendor,
                        style: WBTypography.body.copyWith(
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        d.dropoff,
                        style: WBTypography.caption.copyWith(
                          color: WBColors.fgSecondary,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Text(
                            '₦${d.fee}',
                            style: WBTypography.body.copyWith(
                              fontWeight: FontWeight.w700,
                              fontSize: 15,
                            ),
                          ),
                          const Spacer(),
                          WBButton(
                            label: 'Accept',
                            size: WBButtonSize.sm,
                            trailingIcon: WBIconName.arrowRight,
                            onPressed: () =>
                                context.push(AppRoutes.riderDelivery),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
        ],
      ),
    );
  }
}

// ───────────────────── Active delivery ─────────────────────

class RiderDeliveryScreen extends StatefulWidget {
  const RiderDeliveryScreen({super.key});

  @override
  State<RiderDeliveryScreen> createState() => _RiderDeliveryScreenState();
}

class _RiderDeliveryScreenState extends State<RiderDeliveryScreen> {
  int _step = 1;
  static const _steps = ['Picked up', 'En route', 'Delivered'];

  @override
  Widget build(BuildContext context) {
    final isFinal = _step == _steps.length - 1;
    return SafeArea(
      bottom: false,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(
          WBSpacing.screenPadding,
          12,
          WBSpacing.screenPadding,
          140,
        ),
        children: [
          Text('Active delivery', style: WBTypography.page),
          const SizedBox(height: 4),
          Text(
            '#WAWU-8821 · Mama Cass Kitchen',
            style: WBTypography.caption.copyWith(color: WBColors.fgSecondary),
          ),
          const SizedBox(height: WBSpacing.lg),
          Container(
            padding: const EdgeInsets.all(WBSpacing.lg),
            decoration: BoxDecoration(
              color: WBColors.surfaceDark,
              borderRadius: BorderRadius.circular(WBRadius.card),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'CURRENT',
                  style: WBTypography.label.copyWith(
                    color: Colors.white.withValues(alpha: 0.55),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _steps[_step],
                  style: WBTypography.hero.copyWith(
                    color: Colors.white,
                    fontSize: 26,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: WBSpacing.lg),
          for (var i = 0; i < _steps.length; i++)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: i <= _step
                          ? WBColors.surfaceDark
                          : WBColors.bgSoft,
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: i <= _step
                        ? const WBIcon(
                            WBIconName.check,
                            size: 11,
                            color: Colors.white,
                            strokeWidth: 2.5,
                          )
                        : null,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    _steps[i],
                    style: WBTypography.body.copyWith(
                      fontWeight:
                          i == _step ? FontWeight.w600 : FontWeight.w500,
                      fontSize: 15,
                      color: i <= _step
                          ? WBColors.fgHeader
                          : WBColors.fgDisabled,
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: WBSpacing.md),
          WBCard(
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: const BoxDecoration(
                    color: WBColors.bgSoft,
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: const WBIcon(WBIconName.user, size: 16),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Customer · Adunni',
                        style: WBTypography.body.copyWith(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        'Tap to call (masked)',
                        style: WBTypography.caption.copyWith(
                          color: WBColors.fgSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                WBButton(
                  label: 'Call',
                  size: WBButtonSize.sm,
                  variant: WBButtonVariant.secondary,
                  trailingIcon: WBIconName.phone,
                  onPressed: () =>
                      wbShowSnack(context, 'Calling customer…'),
                ),
              ],
            ),
          ),
          const SizedBox(height: WBSpacing.md),
          WBButton(
            label: isFinal ? 'Complete delivery' : 'Mark ${_steps[_step + 1]}',
            fullWidth: true,
            size: WBButtonSize.lg,
            trailingIcon: WBIconName.arrowRight,
            onPressed: () {
              if (isFinal) {
                wbShowSnack(context, 'Delivery complete · ₦600 earned');
                context.go(AppRoutes.riderHome);
              } else {
                setState(() => _step++);
                wbShowSnack(context, 'Status updated');
              }
            },
          ),
        ],
      ),
    );
  }
}

// ───────────────────── Rider earnings ─────────────────────

class RiderEarningsScreen extends StatelessWidget {
  const RiderEarningsScreen({super.key});

  static const _deliveries = [
    (id: 'WAWU-8821', vendor: 'Mama Cass Kitchen', amount: '₦600', time: 'Today, 12:34'),
    (id: 'WAWU-8820', vendor: 'Suya & Smoke', amount: '₦800', time: 'Today, 11:20'),
    (id: 'WAWU-8819', vendor: 'Iya Basira', amount: '₦500', time: 'Today, 10:14'),
    (id: 'WAWU-8810', vendor: 'Chicken Republic', amount: '₦700', time: 'Yesterday'),
  ];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(
          WBSpacing.screenPadding,
          12,
          WBSpacing.screenPadding,
          140,
        ),
        children: [
          Text('Your earnings', style: WBTypography.page),
          const SizedBox(height: WBSpacing.lg),
          Container(
            padding: const EdgeInsets.all(WBSpacing.lg),
            decoration: BoxDecoration(
              color: WBColors.surfaceDark,
              borderRadius: BorderRadius.circular(WBRadius.card),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'THIS WEEK',
                  style: WBTypography.label.copyWith(
                    color: Colors.white.withValues(alpha: 0.55),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '₦28,400',
                  style: WBTypography.hero.copyWith(
                    color: Colors.white,
                    fontSize: 32,
                    letterSpacing: -1,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '42 deliveries',
                  style: WBTypography.caption.copyWith(
                    color: Colors.white.withValues(alpha: 0.6),
                  ),
                ),
                const SizedBox(height: WBSpacing.md),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(WBRadius.pill),
                  ),
                  child: WBButton(
                    label: 'Withdraw to wallet',
                    size: WBButtonSize.md,
                    trailingIcon: WBIconName.arrowRight,
                    variant: WBButtonVariant.ghost,
                    onPressed: () => _openWithdraw(context),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: WBSpacing.lg),
          Text(
            'Recent deliveries',
            style: WBTypography.cardTitle.copyWith(fontSize: 16),
          ),
          const SizedBox(height: 10),
          WBCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                for (var i = 0; i < _deliveries.length; i++) ...[
                  Padding(
                    padding: const EdgeInsets.all(14),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _deliveries[i].vendor,
                                style: WBTypography.body.copyWith(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '#${_deliveries[i].id} · ${_deliveries[i].time}',
                                style: WBTypography.caption.copyWith(
                                  color: WBColors.fgSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          _deliveries[i].amount,
                          style: WBTypography.body.copyWith(
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (i != _deliveries.length - 1) const WBDivider(),
                ],
              ],
            ),
          ),
          const SizedBox(height: WBSpacing.lg),
          Center(
            child: GestureDetector(
              onTap: () {
                RoleController.instance.signOut();
                context.go(AppRoutes.welcome);
              },
              child: Text(
                'Sign out',
                style: WBTypography.caption.copyWith(
                  color: WBColors.statusError,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

void _openWithdraw(BuildContext context) {
  showModalBottomSheet<void>(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (_) => Container(
      decoration: const BoxDecoration(
        color: WBColors.surfaceCard,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.fromLTRB(
        20,
        14,
        20,
        MediaQuery.of(context).padding.bottom + 22,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 44,
              height: 4,
              decoration: BoxDecoration(
                color: WBColors.bgDivider,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 14),
          Text(
            'Withdraw to wallet',
            style: WBTypography.cardTitle.copyWith(fontSize: 18),
          ),
          const SizedBox(height: 14),
          const WBInput(
            label: 'Amount (₦)',
            initialValue: '28,400',
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 10),
          const WBInput(
            label: 'Mobile money / wallet',
            initialValue: '+234 805 ••• 2114',
            keyboardType: TextInputType.phone,
          ),
          const SizedBox(height: 14),
          WBButton(
            label: 'Send',
            fullWidth: true,
            size: WBButtonSize.lg,
            onPressed: () {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('₦28,400 sent to your wallet'),
                ),
              );
            },
          ),
        ],
      ),
    ),
  );
}
