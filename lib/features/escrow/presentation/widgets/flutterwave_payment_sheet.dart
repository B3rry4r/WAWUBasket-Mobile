import 'package:flutter/material.dart';

import '../../../../core/theme/wb_theme_exports.dart';
import '../../../../core/utils/wb_format.dart';
import '../../../../core/widgets/wb_widgets.dart';
import '../../domain/models/bulk_order.dart';

/// Flutterwave checkout method-picker sheet. Lets the buyer select a payment
/// method and immediately returns the chosen [PaymentMethod] to the caller.
///
/// The caller is responsible for opening the actual Flutterwave checkout URL
/// (via url_launcher) and persisting the order once payment is confirmed.
///
/// No fake delay — the sheet closes as soon as the user taps "Pay".
class FlutterwavePaymentSheet extends StatefulWidget {
  const FlutterwavePaymentSheet({
    super.key,
    required this.amountNaira,
    required this.purpose,
    required this.recipientName,
  });

  final int amountNaira;
  final String purpose;
  final String recipientName;

  static Future<PaymentMethod?> show(
    BuildContext context, {
    required int amountNaira,
    required String purpose,
    required String recipientName,
  }) {
    return showModalBottomSheet<PaymentMethod>(
      context: context,
      backgroundColor: WBColors.bgPrimary,
      isScrollControlled: true,
      isDismissible: false,
      enableDrag: false,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(WBRadius.sheet),
        ),
      ),
      builder: (_) => FlutterwavePaymentSheet(
        amountNaira: amountNaira,
        purpose: purpose,
        recipientName: recipientName,
      ),
    );
  }

  @override
  State<FlutterwavePaymentSheet> createState() =>
      _FlutterwavePaymentSheetState();
}

class _FlutterwavePaymentSheetState extends State<FlutterwavePaymentSheet> {
  PaymentMethod _method = PaymentMethod.card;

  // The actual Flutterwave checkout URL is opened by the caller (bulk_checkout_screen)
  // using url_launcher after this sheet returns the selected PaymentMethod.
  Future<void> _pay() async {
    if (!mounted) return;
    Navigator.of(context).pop(_method);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: WBSpacing.screenPadding,
        right: WBSpacing.screenPadding,
        top: WBSpacing.lg,
        bottom: MediaQuery.of(context).padding.bottom + WBSpacing.xl,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: WBSpacing.lg),
              decoration: BoxDecoration(
                color: WBColors.bgDivider,
                borderRadius: BorderRadius.circular(WBRadius.pill),
              ),
            ),
          ),
          _Header(
            amount: widget.amountNaira,
            purpose: widget.purpose,
            recipientName: widget.recipientName,
          ),
          const SizedBox(height: WBSpacing.lg),
          Text(
            'PAYMENT METHOD',
            style: WBTypography.label.copyWith(
              fontWeight: FontWeight.w600,
              color: WBColors.fgPlaceholder,
              letterSpacing: 0.66,
            ),
          ),
          const SizedBox(height: 8),
          for (final m in PaymentMethod.values) ...[
            _MethodRow(
              method: m,
              selected: _method == m,
              onTap: () => setState(() => _method = m),
            ),
            if (m != PaymentMethod.values.last) const SizedBox(height: 8),
          ],
          const SizedBox(height: WBSpacing.lg),
          WBButton(
            label: 'Pay ${wbNaira(widget.amountNaira)}',
            size: WBButtonSize.lg,
            fullWidth: true,
            trailingIcon: WBIconName.arrowRight,
            onPressed: _pay,
          ),
          const SizedBox(height: 10),
          Center(
            child: Text(
              'Powered by Flutterwave · 256-bit encrypted',
              style: WBTypography.caption.copyWith(
                color: WBColors.fgPlaceholder,
                fontSize: 11,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({
    required this.amount,
    required this.purpose,
    required this.recipientName,
  });
  final int amount;
  final String purpose;
  final String recipientName;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(WBSpacing.lg),
      decoration: BoxDecoration(
        color: WBColors.surfaceDark,
        borderRadius: BorderRadius.circular(WBRadius.card),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'YOU PAY',
            style: WBTypography.label.copyWith(
              color: Colors.white.withValues(alpha: 0.55),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            wbNaira(amount),
            style: WBTypography.hero.copyWith(
              color: Colors.white,
              fontSize: 32,
              letterSpacing: -0.6,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '$purpose · to $recipientName',
            style: WBTypography.caption.copyWith(
              color: Colors.white.withValues(alpha: 0.6),
            ),
          ),
        ],
      ),
    );
  }
}

class _MethodRow extends StatelessWidget {
  const _MethodRow({
    required this.method,
    required this.selected,
    required this.onTap,
  });
  final PaymentMethod method;
  final bool selected;
  final VoidCallback onTap;

  WBIconName get _icon => switch (method) {
        PaymentMethod.card => WBIconName.card,
        PaymentMethod.bankTransfer => WBIconName.home,
        PaymentMethod.mobileMoney => WBIconName.phone,
      };

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: WBMotion.base,
        curve: WBMotion.easeSoft,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: selected ? WBColors.surfaceDark : WBColors.bgPrimary,
          border: Border.all(
            color: selected ? WBColors.surfaceDark : WBColors.bgDivider,
            width: 1.4,
          ),
          borderRadius: BorderRadius.circular(WBRadius.card),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: selected
                    ? Colors.white.withValues(alpha: 0.12)
                    : WBColors.bgSoft,
                borderRadius: BorderRadius.circular(12),
              ),
              alignment: Alignment.center,
              child: WBIcon(
                _icon,
                size: 16,
                color: selected ? Colors.white : WBColors.fgHeader,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    method.label,
                    style: WBTypography.body.copyWith(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                      color: selected ? Colors.white : WBColors.fgHeader,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    method.hint,
                    style: WBTypography.caption.copyWith(
                      color: selected
                          ? Colors.white.withValues(alpha: 0.6)
                          : WBColors.fgSecondary,
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
                color: selected ? Colors.white : Colors.transparent,
                border: Border.all(
                  color: selected ? Colors.white : WBColors.bgDivider,
                  width: 1.5,
                ),
              ),
              alignment: Alignment.center,
              child: selected
                  ? const WBIcon(
                      WBIconName.check,
                      size: 11,
                      color: WBColors.surfaceDark,
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

