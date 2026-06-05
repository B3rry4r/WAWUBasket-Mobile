import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/responsive/wb_responsive_exports.dart';
import '../../../../core/theme/wb_theme_exports.dart';
import '../../../../core/utils/wb_actions.dart';
import '../../../../core/utils/wb_l10n.dart';
import '../../../../core/widgets/wb_widgets.dart';
import '../../../shell/presentation/desktop/customer_web_scaffold.dart';
import '../screens/top_up_screen.dart' show WalletActionKind;

/// Desktop-web layout for the wallet amount/cards flow (top up, send, withdraw,
/// payment methods). Re-lays the mobile [TopUpScreen] into a centered reading
/// column inside the customer web chrome. Mobile build never imports this.
class TopUpDesktopScreen extends StatefulWidget {
  const TopUpDesktopScreen({super.key, this.kind = WalletActionKind.topUp});
  final WalletActionKind kind;

  @override
  State<TopUpDesktopScreen> createState() => _TopUpDesktopScreenState();
}

class _TopUpDesktopScreenState extends State<TopUpDesktopScreen> {
  String _amount = '';
  String _method = 'card';

  String _title(BuildContext context) {
    switch (widget.kind) {
      case WalletActionKind.topUp:
        return context.l10n.walletTopUpTitle;
      case WalletActionKind.send:
        return context.l10n.walletSendTitle;
      case WalletActionKind.withdraw:
        return context.l10n.walletWithdrawTitle;
      case WalletActionKind.cards:
        return context.l10n.walletPaymentMethodsTitle;
    }
  }

  String _ctaLabel(BuildContext context) {
    switch (widget.kind) {
      case WalletActionKind.topUp:
        return context.l10n.walletTopUpHint;
      case WalletActionKind.send:
        return context.l10n.walletSend;
      case WalletActionKind.withdraw:
        return context.l10n.walletWithdraw;
      case WalletActionKind.cards:
        return context.l10n.walletAddNewMethod;
    }
  }

  String _snackMessage(BuildContext context) {
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
    return CustomerWebScaffold(
      child: WBMaxWidth(
        maxWidth: 560,
        padding: const EdgeInsets.fromLTRB(
          WBSpacing.screenPadding,
          WBSpacing.xl,
          WBSpacing.screenPadding,
          48,
        ),
        child: widget.kind == WalletActionKind.cards
            ? _buildCardsList(context)
            : _buildAmountFlow(context),
      ),
    );
  }

  Widget _buildAmountFlow(BuildContext context) {
    final amounts = ['₦1,000', '₦5,000', '₦10,000', '₦20,000'];
    return ListView(
      padding: EdgeInsets.zero,
      children: [
        Row(
          children: [
            WBBackChip(onPressed: () => context.pop()),
            const SizedBox(width: 14),
            Text(_title(context), style: WBTypography.page),
          ],
        ),
        const SizedBox(height: WBSpacing.lg),
        Text(
          context.l10n.walletAmountLabel,
          style: WBTypography.label.copyWith(
            color: WBColors.fgPlaceholder,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.66,
          ),
        ),
        const SizedBox(height: 10),
        WBInput(
          placeholder: context.l10n.walletEnterAmount,
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
              ? context.l10n.walletWithdrawTo
              : context.l10n.walletPayWith,
          style: WBTypography.label.copyWith(
            color: WBColors.fgPlaceholder,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.66,
          ),
        ),
        const SizedBox(height: 10),
        for (final option in [
          (id: 'card', icon: WBIconName.card, label: context.l10n.walletDebitCard, sub: '•••• 4218'),
          (id: 'bank', icon: WBIconName.arrowRight, label: context.l10n.walletBankTransfer, sub: 'GTBank · ****0021'),
          (id: 'mobile', icon: WBIconName.phone, label: context.l10n.walletMobileMoney, sub: 'OPay, Palmpay'),
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
              ? context.l10n.walletEnterAmountHint
              : '${_ctaLabel(context)} $_amount',
          size: WBButtonSize.lg,
          fullWidth: true,
          disabled: _amount.isEmpty,
          onPressed: _amount.isEmpty
              ? null
              : () {
                  wbShowSnack(context, _snackMessage(context));
                  context.pop();
                },
        ),
      ],
    );
  }

  Widget _buildCardsList(BuildContext context) {
    return ListView(
      padding: EdgeInsets.zero,
      children: [
        Row(
          children: [
            WBBackChip(onPressed: () => context.pop()),
            const SizedBox(width: 14),
            Text(context.l10n.walletPaymentMethodsTitle, style: WBTypography.page),
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
                  onTap: () => wbShowSnack(context, context.l10n.walletMethodRemoved),
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
          label: context.l10n.walletAddNewMethod,
          icon: WBIconName.plus,
          size: WBButtonSize.lg,
          fullWidth: true,
          variant: WBButtonVariant.secondary,
          onPressed: () => wbShowSnack(context, context.l10n.topUpMethodSoon),
        ),
      ],
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
