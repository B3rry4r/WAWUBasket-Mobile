import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/wb_theme_exports.dart';
import '../../../../core/utils/wb_actions.dart';
import '../../../../core/utils/wb_format.dart';
import '../../../../core/utils/wb_l10n.dart';
import '../../../../core/widgets/wb_widgets.dart';
import '../../application/agent_controller.dart';

class AgentRecordTxnScreen extends StatefulWidget {
  const AgentRecordTxnScreen({super.key});

  @override
  State<AgentRecordTxnScreen> createState() => _AgentRecordTxnScreenState();
}

class _AgentRecordTxnScreenState extends State<AgentRecordTxnScreen> {
  String? _traderId;
  final _product = TextEditingController(text: 'Tomatoes');
  final _qty = TextEditingController(text: '50');
  final _price = TextEditingController(text: '360');
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    _traderId = AgentController.instance.traders.value.firstOrNull?.id;
  }

  @override
  void dispose() {
    _product.dispose();
    _qty.dispose();
    _price.dispose();
    super.dispose();
  }

  int get _total {
    final q = int.tryParse(_qty.text) ?? 0;
    final p = int.tryParse(_price.text.replaceAll(',', '')) ?? 0;
    return q * p;
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
                if (traders.isEmpty)
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: WBColors.bgSoft,
                      borderRadius: BorderRadius.circular(WBRadius.card),
                    ),
                    child: Text(
                      'No traders yet. Register one first.',
                      style: WBTypography.caption.copyWith(
                        color: WBColors.fgSecondary,
                      ),
                    ),
                  )
                else
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
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    t.name,
                                    style: WBTypography.body.copyWith(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14,
                                    ),
                                  ),
                                  Text(
                                    '${t.type.label} · ${t.location}',
                                    style: WBTypography.caption.copyWith(
                                      color: WBColors.fgSecondary,
                                    ),
                                  ),
                                ],
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
      wbShowSnack(context, context.l10n.agentTxnTraderRequired);
      return;
    }
    final q = int.tryParse(_qty.text.trim()) ?? 0;
    final p = int.tryParse(_price.text.trim().replaceAll(',', '')) ?? 0;
    if (q <= 0 || p <= 0 || _product.text.trim().isEmpty) {
      wbShowSnack(context, context.l10n.agentTxnFieldsRequired);
      return;
    }
    _submitting = true;
    AgentController.instance.addTransaction(
      traderId: trader.id,
      traderName: trader.name,
      product: _product.text.trim(),
      quantityKg: q,
      pricePerKgNaira: p,
    );
    wbShowSnack(context, context.l10n.agentTxnSavedOffline);
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
          Text(context.l10n.navRecord, style: WBTypography.page),
          const SizedBox(height: 4),
          Text(
            'Help trader log what they sold.',
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
                label: context.l10n.agentTxnTraderLabel,
                initialValue: _traderLabel(_traderId),
                leadingIcon: WBIconName.user,
                trailing: const WBIcon(WBIconName.chevronDown, size: 14),
              ),
            ),
          ),
          const SizedBox(height: WBSpacing.md),
          WBInput(
            label: context.l10n.agentTxnProductLabel,
            controller: _product,
            leadingIcon: WBIconName.basket,
          ),
          const SizedBox(height: WBSpacing.md),
          Row(
            children: [
              Expanded(
                child: WBInput(
                  label: context.l10n.agentTxnQuantityLabel,
                  controller: _qty,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                  ],
                  onChanged: (_) => setState(() {}),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: WBInput(
                  label: context.l10n.agentTxnUnitPriceLabel,
                  controller: _price,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                  ],
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
                  context.l10n.cartTotal,
                  style:
                      WBTypography.body.copyWith(fontWeight: FontWeight.w500),
                ),
                Text(
                  wbNaira(_total),
                  style: WBTypography.hero.copyWith(fontSize: 22),
                ),
              ],
            ),
          ),
          const SizedBox(height: WBSpacing.lg),
          WBButton(
            label: context.l10n.agentTxnSave,
            fullWidth: true,
            size: WBButtonSize.lg,
            onPressed: _save,
          ),
        ],
      ),
    );
  }
}
