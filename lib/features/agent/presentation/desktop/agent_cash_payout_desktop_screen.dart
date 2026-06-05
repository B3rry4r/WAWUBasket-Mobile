import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/responsive/wb_responsive_exports.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/wb_theme_exports.dart';
import '../../../../core/utils/wb_actions.dart';
import '../../../../core/utils/wb_l10n.dart';
import '../../../../core/widgets/wb_widgets.dart';
import '../../application/agent_controller.dart';
import '../widgets/signature_pad.dart';

/// Desktop-web layout for the agent cash-payout tab. Isolated from the mobile
/// [AgentCashPayoutScreen] — same controller, state, validation, signature
/// requirement, copy and navigation, re-laid-out as a two-column dashboard
/// (payout form left, cash-float context right) capped by [WBMaxWidth].
///
/// TAB screen: the agent role shell supplies the desktop sidebar, so this
/// renders body content only.
class AgentCashPayoutDesktopScreen extends StatefulWidget {
  const AgentCashPayoutDesktopScreen({super.key});

  @override
  State<AgentCashPayoutDesktopScreen> createState() =>
      _AgentCashPayoutDesktopScreenState();
}

class _AgentCashPayoutDesktopScreenState
    extends State<AgentCashPayoutDesktopScreen> {
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
    return WBMaxWidth(
      padding: const EdgeInsets.fromLTRB(
        WBSpacing.screenPadding,
        WBSpacing.xl,
        WBSpacing.screenPadding,
        40,
      ),
      child: ListView(
        children: [
          // Page header.
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
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
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: WBSpacing.xl),
          LayoutBuilder(
            builder: (context, constraints) {
              final twoColumn = constraints.maxWidth >= 880;
              final form = _buildForm(context);
              final aside = _buildAside(context);
              if (!twoColumn) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    form,
                    const SizedBox(height: WBSpacing.lg),
                    aside,
                  ],
                );
              }
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(flex: 7, child: form),
                  const SizedBox(width: WBSpacing.xl),
                  Expanded(flex: 5, child: aside),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildForm(BuildContext context) {
    return WBCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
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

  Widget _buildAside(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: WBColors.bgSoft,
        borderRadius: BorderRadius.circular(WBRadius.card),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
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
    );
  }
}
