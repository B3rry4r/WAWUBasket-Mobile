import 'package:flutter/material.dart';

import '../../../../core/theme/wb_theme_exports.dart';
import '../../../../core/utils/wb_format.dart';
import '../../../../core/widgets/wb_widgets.dart';
import '../../domain/models/bulk_order.dart';

/// Simulated Flutterwave checkout sheet. Lets the buyer pick a payment
/// method, runs a 3-second processing animation, then returns the chosen
/// [PaymentMethod]. The caller is responsible for persisting the order
/// once the future resolves.
///
/// Stays UI-only — no real Flutterwave SDK call. The "Powered by
/// Flutterwave" footer makes the simulated brand explicit.
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
  bool _processing = false;

  Future<void> _pay() async {
    setState(() => _processing = true);
    await Future<void>.delayed(const Duration(milliseconds: 2400));
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
          if (_processing)
            _ProcessingView(amount: widget.amountNaira)
          else ...[
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

class _ProcessingView extends StatelessWidget {
  const _ProcessingView({required this.amount});
  final int amount;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: WBSpacing.xl),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(
            width: 56,
            height: 56,
            child: CircularProgressIndicator(
              strokeWidth: 3.5,
              color: WBColors.surfaceDark,
              backgroundColor: WBColors.bgSoft,
            ),
          ),
          const SizedBox(height: WBSpacing.lg),
          Text(
            'Processing ${wbNaira(amount)}…',
            style: WBTypography.cardTitle.copyWith(fontSize: 17),
          ),
          const SizedBox(height: 4),
          Text(
            "Hold tight — we're moving funds into escrow.",
            textAlign: TextAlign.center,
            style: WBTypography.caption.copyWith(color: WBColors.fgSecondary),
          ),
          const SizedBox(height: WBSpacing.lg),
          Text(
            'Powered by Flutterwave',
            style: WBTypography.caption.copyWith(
              color: WBColors.fgPlaceholder,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}
