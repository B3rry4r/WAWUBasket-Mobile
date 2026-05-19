import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/wb_theme_exports.dart';
import '../../../../core/utils/wb_actions.dart';
import '../../../../core/widgets/wb_widgets.dart';

enum WalletActionKind { topUp, send, withdraw, cards }

class TopUpScreen extends StatefulWidget {
  const TopUpScreen({super.key, this.kind = WalletActionKind.topUp});
  final WalletActionKind kind;

  @override
  State<TopUpScreen> createState() => _TopUpScreenState();
}

class _TopUpScreenState extends State<TopUpScreen> {
  String _amount = '';
  String _method = 'card';

  String get _title {
    switch (widget.kind) {
      case WalletActionKind.topUp:
        return 'Top up wallet';
      case WalletActionKind.send:
        return 'Send money';
      case WalletActionKind.withdraw:
        return 'Withdraw';
      case WalletActionKind.cards:
        return 'Payment methods';
    }
  }

  String get _ctaLabel {
    switch (widget.kind) {
      case WalletActionKind.topUp:
        return 'Top up';
      case WalletActionKind.send:
        return 'Send';
      case WalletActionKind.withdraw:
        return 'Withdraw';
      case WalletActionKind.cards:
        return 'Add new method';
    }
  }

  String get _snackMessage {
    switch (widget.kind) {
      case WalletActionKind.topUp:
        return 'Top-up of $_amount started';
      case WalletActionKind.send:
        return 'Transfer of $_amount queued';
      case WalletActionKind.withdraw:
        return 'Withdrawal of $_amount queued';
      case WalletActionKind.cards:
        return 'Add a new method';
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.kind == WalletActionKind.cards) return _buildCardsList();
    return _buildAmountFlow();
  }

  Widget _buildAmountFlow() {
    final amounts = ['₦1,000', '₦5,000', '₦10,000', '₦20,000'];
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
                Text(_title, style: WBTypography.page),
              ],
            ),
            const SizedBox(height: WBSpacing.lg),
            Text(
              'AMOUNT',
              style: WBTypography.label.copyWith(
                color: WBColors.fgPlaceholder,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.66,
              ),
            ),
            const SizedBox(height: 10),
            WBInput(
              placeholder: 'Enter amount',
              leadingIcon: WBIconName.card,
              keyboardType: TextInputType.number,
              onChanged: (v) => setState(() => _amount = v.isEmpty ? '' : '₦$v'),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final a in amounts)
                  WBTag(
                    label: a,
                    active: _amount == a,
                    onTap: () => setState(() => _amount = a),
                  ),
              ],
            ),
            const SizedBox(height: WBSpacing.lg),
            Text(
              widget.kind == WalletActionKind.withdraw
                  ? 'WITHDRAW TO'
                  : 'PAY WITH',
              style: WBTypography.label.copyWith(
                color: WBColors.fgPlaceholder,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.66,
              ),
            ),
            const SizedBox(height: 10),
            for (final option in const [
              (id: 'card', icon: WBIconName.card, label: 'Debit card', sub: '•••• 4218'),
              (id: 'bank', icon: WBIconName.arrowRight, label: 'Bank transfer', sub: 'GTBank · ****0021'),
              (id: 'mobile', icon: WBIconName.phone, label: 'Mobile money', sub: 'OPay, Palmpay'),
            ]) ...[
              _MethodTile(
                icon: option.icon,
                label: option.label,
                sub: option.sub,
                selected: _method == option.id,
                onTap: () => setState(() => _method = option.id),
              ),
              const SizedBox(height: 10),
            ],
            const SizedBox(height: WBSpacing.lg),
            WBButton(
              label: _amount.isEmpty
                  ? 'Enter an amount'
                  : '$_ctaLabel $_amount',
              size: WBButtonSize.lg,
              fullWidth: true,
              disabled: _amount.isEmpty,
              onPressed: _amount.isEmpty
                  ? null
                  : () {
                      wbShowSnack(context, _snackMessage);
                      context.pop();
                    },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCardsList() {
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
                Text('Payment methods', style: WBTypography.page),
              ],
            ),
            const SizedBox(height: WBSpacing.lg),
            for (final m in const [
              (icon: WBIconName.card, label: 'Visa · •••• 4218', sub: 'Default · Expires 09/27'),
              (icon: WBIconName.card, label: 'Mastercard · •••• 0982', sub: 'Expires 04/26'),
              (icon: WBIconName.arrowRight, label: 'GTBank ****0021', sub: 'Bank transfer'),
            ]) ...[
              Container(
                padding: const EdgeInsets.all(WBSpacing.md),
                decoration: BoxDecoration(
                  color: WBColors.surfaceCard,
                  borderRadius: BorderRadius.circular(WBRadius.card),
                  boxShadow: WBShadows.card,
                ),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: const BoxDecoration(
                        color: WBColors.bgSoft,
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: WBIcon(m.icon, size: 18),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            m.label,
                            style: WBTypography.body.copyWith(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            m.sub,
                            style: WBTypography.caption.copyWith(
                              color: WBColors.fgSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: () => wbShowSnack(context, 'Method removed'),
                      child: const WBIcon(
                        WBIconName.more,
                        size: 18,
                        color: WBColors.fgPlaceholder,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
            ],
            const SizedBox(height: WBSpacing.md),
            WBButton(
              label: 'Add new method',
              icon: WBIconName.plus,
              size: WBButtonSize.lg,
              fullWidth: true,
              variant: WBButtonVariant.secondary,
              onPressed: () => wbShowSnack(context, 'Method picker, coming soon'),
            ),
          ],
        ),
      ),
    );
  }
}

class _MethodTile extends StatelessWidget {
  const _MethodTile({
    required this.icon,
    required this.label,
    required this.sub,
    required this.selected,
    required this.onTap,
  });
  final WBIconName icon;
  final String label;
  final String sub;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: WBMotion.base,
        curve: WBMotion.easeSoft,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: selected ? WBColors.bgPrimary : WBColors.bgSoft,
          border: Border.all(
            color: selected ? WBColors.borderFilled : Colors.transparent,
            width: 1.5,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: const BoxDecoration(
                color: WBColors.bgSoft,
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: WBIcon(icon, size: 16),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: WBTypography.body.copyWith(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 1),
                  Text(
                    sub,
                    style: WBTypography.caption.copyWith(
                      color: WBColors.fgSecondary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: selected ? WBColors.surfaceDark : Colors.transparent,
                border: Border.all(
                  color: selected ? WBColors.surfaceDark : WBColors.bgDivider,
                  width: 1.5,
                ),
              ),
              alignment: Alignment.center,
              child: selected
                  ? const WBIcon(
                      WBIconName.check,
                      size: 10,
                      color: Colors.white,
                      strokeWidth: 2.5,
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}
