import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/wb_theme_exports.dart';
import '../../../../core/utils/wb_actions.dart';
import '../../../../core/widgets/wb_widgets.dart';
import '../../application/agent_controller.dart';
import '../widgets/signature_pad.dart';
import '../../../../core/utils/wb_l10n.dart';

class AgentCashPayoutScreen extends StatefulWidget {
  const AgentCashPayoutScreen({super.key});

  @override
  State<AgentCashPayoutScreen> createState() => _AgentCashPayoutScreenState();
}

class _AgentCashPayoutScreenState extends State<AgentCashPayoutScreen> {
  String? _traderId;
  final _amount = TextEditingController(text: '18000');
  final _note = TextEditingController();
  final _sig = SignaturePadController();
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    _traderId = AgentController.instance.traders.value.firstOrNull?.id;
  }

  @override
  void dispose() {
    _amount.dispose();
    _note.dispose();
    _sig.dispose();
    super.dispose();
  }

  String _traderLabel(String? id) {
    if (id == null) return 'Pick a trader';
    return AgentController.instance.traderById(id)?.name ?? 'Pick a trader';
  }

  void _pickTrader() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: WBColors.bgPrimary,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius:
            BorderRadius.vertical(top: Radius.circular(WBRadius.sheet)),
      ),
      builder: (sheetCtx) {
        return ValueListenableBuilder(
          valueListenable: AgentController.instance.traders,
          builder: (_, traders, _) => Padding(
            padding: EdgeInsets.only(
              left: WBSpacing.screenPadding,
              right: WBSpacing.screenPadding,
              top: WBSpacing.lg,
              bottom: MediaQuery.of(sheetCtx).padding.bottom + WBSpacing.lg,
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
                Text(
                  'Pick a trader',
                  style: WBTypography.cardTitle.copyWith(fontSize: 18),
                ),
                const SizedBox(height: WBSpacing.md),
                for (final t in traders)
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () {
                      setState(() => _traderId = t.id);
                      Navigator.of(sheetCtx).pop();
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              t.name,
                              style: WBTypography.body.copyWith(
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                          ),
                          if (t.id == _traderId)
                            const WBIcon(WBIconName.check, size: 16),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _save() {
    if (_submitting) return;
    final trader = _traderId == null
        ? null
        : AgentController.instance.traderById(_traderId!);
    if (trader == null) {
      wbShowSnack(context, context.l10n.agentPayoutTraderRequired);
      return;
    }
    final amt = int.tryParse(_amount.text.trim().replaceAll(',', '')) ?? 0;
    if (amt <= 0) {
      wbShowSnack(context, context.l10n.agentPayoutAmountRequired);
      return;
    }
    if (_sig.isEmpty) {
      wbShowSnack(
        context,
        'Trader signature is required for cash payouts.',
      );
      return;
    }
    _submitting = true;
    AgentController.instance.addPayout(
      traderId: trader.id,
      traderName: trader.name,
      amountNaira: amt,
      note: _note.text.trim().isEmpty ? null : _note.text.trim(),
      signatureBytes: _sig.strokes,
    );
    wbShowSnack(context, context.l10n.agentPayoutRecorded);
    context.go(AppRoutes.agentHome);
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
          Text(context.l10n.navPayout, style: WBTypography.page),
          const SizedBox(height: 4),
          Text(
            'Give trader their money.',
            style: WBTypography.body.copyWith(
              color: WBColors.fgSecondary,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: WBSpacing.lg),
          GestureDetector(
            onTap: _pickTrader,
            behavior: HitTestBehavior.opaque,
            child: AbsorbPointer(
              child: WBInput(
                key: ValueKey('trader-$_traderId'),
                label: 'Trader',
                initialValue: _traderLabel(_traderId),
                leadingIcon: WBIconName.user,
                trailing: const WBIcon(WBIconName.chevronDown, size: 14),
              ),
            ),
          ),
          const SizedBox(height: WBSpacing.md),
          WBInput(
            label: 'Amount (₦)',
            controller: _amount,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
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
          SignaturePad(controller: _sig),
          const SizedBox(height: WBSpacing.md),
          WBInput(
            label: 'Agent note (optional)',
            placeholder: context.l10n.agentPayoutNotePlaceholder,
            controller: _note,
          ),
          const SizedBox(height: WBSpacing.lg),
          WBButton(
            label: 'Complete payout',
            fullWidth: true,
            size: WBButtonSize.lg,
            onPressed: _save,
          ),
        ],
      ),
    );
  }
}
