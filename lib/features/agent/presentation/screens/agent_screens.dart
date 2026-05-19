import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/wb_theme_exports.dart';
import '../../../../core/utils/wb_actions.dart';
import '../../../../core/widgets/wb_widgets.dart';
import '../../../auth/application/role_controller.dart';

// ───────────────────────── Login ─────────────────────────

class AgentLoginScreen extends StatelessWidget {
  const AgentLoginScreen({super.key});

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
              Text('Agent access', style: WBTypography.hero),
              const SizedBox(height: WBSpacing.sm),
              Text(
                'Your traders are waiting.',
                style:
                    WBTypography.body.copyWith(color: WBColors.fgSecondary),
              ),
              const SizedBox(height: WBSpacing.xl),
              const WBInput(
                label: 'Agent ID',
                initialValue: 'WAWU-AG-0142',
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
                  RoleController.instance.completeKyc(AppRole.agent);
                  RoleController.instance.setRole(AppRole.agent);
                  context.go(AppRoutes.agentHome);
                },
              ),
              const SizedBox(height: WBSpacing.md),
              Center(
                child: GestureDetector(
                  onTap: () => context.push(AppRoutes.agentKyc),
                  child: RichText(
                    text: TextSpan(
                      style: WBTypography.secondary,
                      children: const [
                        TextSpan(text: 'New here? '),
                        TextSpan(
                          text: 'Apply to be an agent',
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

// ───────────────────────── Home ─────────────────────────

class AgentHomeScreen extends StatelessWidget {
  const AgentHomeScreen({super.key});

  static const _recent = [
    (name: 'Adamu Bello', product: 'Tomatoes · 50 kg', amount: '₦18,000', time: '12 min ago'),
    (name: 'Hauwa Sani', product: 'Maize · 100 kg', amount: '₦55,000', time: '34 min ago'),
    (name: 'Sani Audu', product: 'Onions · 25 kg', amount: '₦22,500', time: '1 hr ago'),
    (name: 'Aisha Garba', product: 'Cassava · 80 kg', amount: '₦22,400', time: '2 hr ago'),
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
          // Hero
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
                    Text(
                      'Hello, Musa',
                      style: WBTypography.hero.copyWith(
                        color: Colors.white,
                        fontSize: 22,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(WBRadius.pill),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 7,
                            height: 7,
                            decoration: const BoxDecoration(
                              color: Color(0xFF10B981),
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Online',
                            style: WBTypography.caption.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'Zone B · Mile 12 Market',
                  style: WBTypography.caption.copyWith(
                    color: Colors.white.withValues(alpha: 0.6),
                  ),
                ),
                const SizedBox(height: WBSpacing.lg),
                Row(
                  children: const [
                    _Stat(label: 'Today', value: '12 txns'),
                    SizedBox(width: 10),
                    _Stat(label: 'Commission', value: '₦4,250'),
                    SizedBox(width: 10),
                    _Stat(label: 'To sync', value: '3'),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: WBSpacing.md),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0x1410B981),
              borderRadius: BorderRadius.circular(WBRadius.card),
              border: Border.all(color: const Color(0x3310B981)),
            ),
            child: Row(
              children: [
                const WBIcon(WBIconName.check, size: 14),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    "You're online — transactions sync as you record them.",
                    style: WBTypography.caption.copyWith(
                      color: WBColors.fgHeader,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () => context.push(AppRoutes.agentSync),
                  child: Text(
                    'Sync',
                    style: WBTypography.caption.copyWith(
                      color: WBColors.fgHeader,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: WBSpacing.lg),
          Text(
            'Quick actions',
            style: WBTypography.cardTitle.copyWith(fontSize: 16),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              _Quick(
                icon: WBIconName.user,
                label: 'Register trader',
                onTap: () => context.push(AppRoutes.agentRegisterTrader),
              ),
              const SizedBox(width: 10),
              _Quick(
                icon: WBIconName.basket,
                label: 'Record txn',
                onTap: () => context.push(AppRoutes.agentRecordTxn),
              ),
              const SizedBox(width: 10),
              _Quick(
                icon: WBIconName.card,
                label: 'Cash payout',
                onTap: () => context.push(AppRoutes.agentCashPayout),
              ),
            ],
          ),
          const SizedBox(height: WBSpacing.lg),
          Row(
            children: [
              Expanded(
                child: Text(
                  'Recent transactions',
                  style: WBTypography.cardTitle.copyWith(fontSize: 16),
                ),
              ),
              GestureDetector(
                onTap: () => context.push(AppRoutes.agentSync),
                child: Text(
                  'See all',
                  style: WBTypography.caption.copyWith(
                    color: WBColors.fgSecondary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          for (final r in _recent)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: WBCard(
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: WBColors.bgSoft,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      alignment: Alignment.center,
                      child: const WBIcon(WBIconName.basket, size: 16),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            r.name,
                            style: WBTypography.body.copyWith(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${r.product} · ${r.time}',
                            style: WBTypography.caption.copyWith(
                              color: WBColors.fgSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      r.amount,
                      style: WBTypography.body.copyWith(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
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

class _Stat extends StatelessWidget {
  const _Stat({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label.toUpperCase(),
              style: WBTypography.label.copyWith(
                color: Colors.white.withValues(alpha: 0.55),
                fontWeight: FontWeight.w500,
                fontSize: 9,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: WBTypography.body.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Quick extends StatelessWidget {
  const _Quick({required this.icon, required this.label, required this.onTap});
  final WBIconName icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: WBColors.surfaceCard,
            borderRadius: BorderRadius.circular(WBRadius.card),
            boxShadow: WBShadows.card,
          ),
          child: Column(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: WBColors.bgSoft,
                  borderRadius: BorderRadius.circular(10),
                ),
                alignment: Alignment.center,
                child: WBIcon(icon, size: 16),
              ),
              const SizedBox(height: 8),
              Text(
                label,
                style: WBTypography.caption.copyWith(
                  color: WBColors.fgHeader,
                  fontWeight: FontWeight.w500,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ───────────────────── Register trader ─────────────────────

class AgentRegisterTraderScreen extends StatefulWidget {
  const AgentRegisterTraderScreen({super.key});

  @override
  State<AgentRegisterTraderScreen> createState() =>
      _AgentRegisterTraderScreenState();
}

class _AgentRegisterTraderScreenState
    extends State<AgentRegisterTraderScreen> {
  String _type = 'farmer';

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
          Text('New trader', style: WBTypography.page),
          const SizedBox(height: 4),
          Text(
            "Let's get them set up.",
            style: WBTypography.body.copyWith(
              color: WBColors.fgSecondary,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: WBSpacing.lg),
          const WBInput(label: 'Full name', placeholder: 'Full name as on ID'),
          const SizedBox(height: WBSpacing.md),
          const WBInput(
            label: 'Phone number',
            placeholder: '812 345 6789',
            keyboardType: TextInputType.phone,
          ),
          const SizedBox(height: WBSpacing.md),
          Text(
            'BUSINESS TYPE',
            style: WBTypography.label.copyWith(
              color: WBColors.fgPlaceholder,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.66,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [
              for (final t in const [
                ('farmer', 'Farmer'),
                ('trader', 'Trader'),
                ('processor', 'Processor'),
                ('other', 'Other'),
              ])
                WBTag(
                  label: t.$2,
                  active: t.$1 == _type,
                  onTap: () => setState(() => _type = t.$1),
                ),
            ],
          ),
          const SizedBox(height: WBSpacing.md),
          const WBInput(
            label: 'Location',
            placeholder: 'Market or village name',
          ),
          const SizedBox(height: WBSpacing.lg),
          Row(
            children: [
              Expanded(
                child: _PhotoSquare(
                  icon: WBIconName.user,
                  label: 'Trader photo',
                  onTap: () => wbShowSnack(context, 'Camera opened'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _PhotoSquare(
                  icon: WBIconName.card,
                  label: 'ID document',
                  onTap: () => wbShowSnack(context, 'Camera opened'),
                ),
              ),
            ],
          ),
          const SizedBox(height: WBSpacing.lg),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: WBColors.bgSoft,
              borderRadius: BorderRadius.circular(WBRadius.card),
            ),
            child: Row(
              children: [
                const WBIcon(WBIconName.bell, size: 14),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    "Offline-capable — we'll sync when you have connection.",
                    style: WBTypography.caption.copyWith(
                      color: WBColors.fgSecondary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: WBSpacing.lg),
          WBButton(
            label: 'Save trader',
            fullWidth: true,
            size: WBButtonSize.lg,
            onPressed: () {
              wbShowSnack(context, 'Trader saved offline');
              context.go(AppRoutes.agentHome);
            },
          ),
        ],
      ),
    );
  }
}

class _PhotoSquare extends StatelessWidget {
  const _PhotoSquare({
    required this.icon,
    required this.label,
    required this.onTap,
  });
  final WBIconName icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AspectRatio(
        aspectRatio: 1.3,
        child: Container(
          decoration: BoxDecoration(
            color: WBColors.bgSoft,
            borderRadius: BorderRadius.circular(WBRadius.card),
            border: Border.all(color: WBColors.bgDivider),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: const BoxDecoration(
                  color: WBColors.bgPrimary,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: WBIcon(icon, size: 16),
              ),
              const SizedBox(height: 8),
              Text(
                label,
                style: WBTypography.caption.copyWith(
                  color: WBColors.fgHeader,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'Tap to capture',
                style: WBTypography.caption.copyWith(
                  color: WBColors.fgPlaceholder,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────── Record txn ───────────────────────

class AgentRecordTxnScreen extends StatefulWidget {
  const AgentRecordTxnScreen({super.key});

  @override
  State<AgentRecordTxnScreen> createState() => _AgentRecordTxnScreenState();
}

class _AgentRecordTxnScreenState extends State<AgentRecordTxnScreen> {
  final _qty = TextEditingController(text: '50');
  final _price = TextEditingController(text: '360');

  @override
  void dispose() {
    _qty.dispose();
    _price.dispose();
    super.dispose();
  }

  int get _total {
    final q = int.tryParse(_qty.text) ?? 0;
    final p = int.tryParse(_price.text.replaceAll(',', '')) ?? 0;
    return q * p;
  }

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
          Text('Record sale', style: WBTypography.page),
          const SizedBox(height: 4),
          Text(
            'Help trader log what they sold.',
            style: WBTypography.body.copyWith(
              color: WBColors.fgSecondary,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: WBSpacing.lg),
          const WBInput(
            label: 'Trader',
            initialValue: 'Adamu Bello',
            leadingIcon: WBIconName.user,
          ),
          const SizedBox(height: WBSpacing.md),
          const WBInput(
            label: 'Product',
            initialValue: 'Tomatoes',
            leadingIcon: WBIconName.basket,
          ),
          const SizedBox(height: WBSpacing.md),
          Row(
            children: [
              Expanded(
                child: WBInput(
                  label: 'Quantity (kg)',
                  controller: _qty,
                  keyboardType: TextInputType.number,
                  onChanged: (_) => setState(() {}),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: WBInput(
                  label: 'Unit price (₦)',
                  controller: _price,
                  keyboardType: TextInputType.number,
                  onChanged: (_) => setState(() {}),
                ),
              ),
            ],
          ),
          const SizedBox(height: WBSpacing.md),
          WBCard(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total',
                  style: WBTypography.body.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  '₦${_n(_total)}',
                  style: WBTypography.hero.copyWith(fontSize: 22),
                ),
              ],
            ),
          ),
          const SizedBox(height: WBSpacing.md),
          const WBInput(
            label: 'Buyer name (optional)',
            placeholder: 'Buyer name',
          ),
          const SizedBox(height: WBSpacing.md),
          const WBInput(
            label: 'Buyer location (optional)',
            placeholder: 'Benin Republic',
          ),
          const SizedBox(height: WBSpacing.lg),
          Row(
            children: [
              Expanded(
                child: _PhotoSquare(
                  icon: WBIconName.basket,
                  label: 'Photo of goods',
                  onTap: () => wbShowSnack(context, 'Camera opened'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _PhotoSquare(
                  icon: WBIconName.user,
                  label: 'Trader signature',
                  onTap: () => wbShowSnack(context, 'Signature pad opened'),
                ),
              ),
            ],
          ),
          const SizedBox(height: WBSpacing.lg),
          WBButton(
            label: 'Save transaction',
            fullWidth: true,
            size: WBButtonSize.lg,
            onPressed: () {
              wbShowSnack(context, 'Transaction saved offline');
              context.go(AppRoutes.agentHome);
            },
          ),
        ],
      ),
    );
  }
}

// ──────────────────── Cash payout ────────────────────

class AgentCashPayoutScreen extends StatelessWidget {
  const AgentCashPayoutScreen({super.key});

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
          Text('Cash payout', style: WBTypography.page),
          const SizedBox(height: 4),
          Text(
            'Give trader their money.',
            style: WBTypography.body.copyWith(
              color: WBColors.fgSecondary,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: WBSpacing.lg),
          const WBInput(
            label: 'Trader',
            initialValue: 'Adamu Bello',
            leadingIcon: WBIconName.user,
          ),
          const SizedBox(height: WBSpacing.md),
          const WBInput(
            label: 'Amount (₦)',
            initialValue: '18,000',
            keyboardType: TextInputType.number,
            leadingIcon: WBIconName.card,
          ),
          const SizedBox(height: WBSpacing.md),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: WBColors.bgSoft,
              borderRadius: BorderRadius.circular(WBRadius.card),
            ),
            child: Row(
              children: [
                const WBIcon(WBIconName.card, size: 14),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Cash from agent float',
                        style: WBTypography.body.copyWith(
                          fontWeight: FontWeight.w500,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'WAWU reimburses within 24 hrs.',
                        style: WBTypography.caption.copyWith(
                          color: WBColors.fgSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: WBSpacing.lg),
          Row(
            children: [
              Expanded(
                child: _PhotoSquare(
                  icon: WBIconName.user,
                  label: 'Trader photo',
                  onTap: () {},
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _PhotoSquare(
                  icon: WBIconName.check,
                  label: 'Thumbprint',
                  onTap: () {},
                ),
              ),
            ],
          ),
          const SizedBox(height: WBSpacing.md),
          const WBInput(
            label: 'Agent note',
            placeholder: 'Payout for tomato sale',
          ),
          const SizedBox(height: WBSpacing.lg),
          WBButton(
            label: 'Complete payout',
            fullWidth: true,
            size: WBButtonSize.lg,
            onPressed: () {
              wbShowSnack(context, 'Payout recorded · reimbursement queued');
              context.go(AppRoutes.agentHome);
            },
          ),
        ],
      ),
    );
  }
}

// ────────────────────── Sync ──────────────────────

class AgentSyncScreen extends StatefulWidget {
  const AgentSyncScreen({super.key});

  @override
  State<AgentSyncScreen> createState() => _AgentSyncScreenState();
}

class _AgentSyncScreenState extends State<AgentSyncScreen> {
  double _progress = 0;
  bool _syncing = false;
  bool _done = false;

  Future<void> _runSync() async {
    setState(() {
      _syncing = true;
      _done = false;
      _progress = 0;
    });
    for (var i = 1; i <= 10; i++) {
      await Future<void>.delayed(const Duration(milliseconds: 140));
      if (!mounted) return;
      setState(() => _progress = i / 10);
    }
    if (!mounted) return;
    setState(() {
      _syncing = false;
      _done = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: WBColors.bgSecondary,
      body: SafeArea(
        bottom: false,
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
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Sync with WAWU', style: WBTypography.page),
                      Text(
                        'Send your offline data to the cloud.',
                        style: WBTypography.caption.copyWith(
                          color: WBColors.fgSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: WBSpacing.lg),
            WBCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _SyncRow(label: 'Pending traders', value: '2'),
                  const SizedBox(height: 12),
                  _SyncRow(label: 'Pending transactions', value: '3'),
                  const SizedBox(height: 12),
                  _SyncRow(label: 'Pending payouts', value: '1'),
                  const SizedBox(height: 12),
                  _SyncRow(
                    label: 'Last sync',
                    value: '2 hr ago',
                    valueColor: WBColors.fgSecondary,
                  ),
                ],
              ),
            ),
            const SizedBox(height: WBSpacing.lg),
            if (_syncing) ...[
              Text(
                'Syncing… ${(_progress * 100).toInt()}%',
                style: WBTypography.body.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(WBRadius.pill),
                child: LinearProgressIndicator(
                  value: _progress,
                  minHeight: 6,
                  backgroundColor: WBColors.bgSoft,
                  valueColor:
                      const AlwaysStoppedAnimation(WBColors.surfaceDark),
                ),
              ),
              const SizedBox(height: WBSpacing.lg),
            ] else if (_done) ...[
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0x1410B981),
                  borderRadius: BorderRadius.circular(WBRadius.card),
                  border: Border.all(color: const Color(0x3310B981)),
                ),
                child: Row(
                  children: [
                    const WBIcon(WBIconName.check, size: 16),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        "All done! Your data is safe.",
                        style: WBTypography.body.copyWith(
                          fontWeight: FontWeight.w500,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: WBSpacing.lg),
            ],
            WBButton(
              label: _syncing ? 'Syncing…' : 'Sync now',
              fullWidth: true,
              size: WBButtonSize.lg,
              trailingIcon: WBIconName.arrowRight,
              onPressed: _syncing ? null : _runSync,
            ),
            const SizedBox(height: WBSpacing.md),
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
      ),
    );
  }
}

class _SyncRow extends StatelessWidget {
  const _SyncRow({
    required this.label,
    required this.value,
    this.valueColor,
  });
  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: WBTypography.body.copyWith(fontSize: 14)),
        Text(
          value,
          style: WBTypography.body.copyWith(
            fontWeight: FontWeight.w600,
            fontSize: 14,
            color: valueColor ?? WBColors.fgHeader,
          ),
        ),
      ],
    );
  }
}

String _n(int v) {
  final s = v.toString();
  final buf = StringBuffer();
  for (var i = 0; i < s.length; i++) {
    if (i != 0 && (s.length - i) % 3 == 0) buf.write(',');
    buf.write(s[i]);
  }
  return buf.toString();
}
