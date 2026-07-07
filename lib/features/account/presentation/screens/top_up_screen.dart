import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/network/api_exception.dart';
import '../../../../core/network/api_parse.dart';
import '../../../../core/theme/wb_theme_exports.dart';
import '../../../../core/utils/wb_actions.dart';
import '../../../../core/utils/wb_l10n.dart';
import '../../../../core/widgets/wb_widgets.dart';
import '../../data/payment_methods_api.dart';

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

  // ─── Payment methods (WalletActionKind.cards) ──────────────────────────
  List<Map<String, dynamic>>? _methods;
  String? _methodsError;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    if (widget.kind == WalletActionKind.cards) _loadMethods();
  }

  Future<void> _loadMethods() async {
    setState(() => _methodsError = null);
    try {
      final list = await PaymentMethodsApi.instance.list();
      if (!mounted) return;
      setState(() => _methods = list);
    } on ApiException catch (e) {
      if (mounted) setState(() => _methodsError = e.message);
    }
  }

  Future<void> _openAddSheet() async {
    final result = await showModalBottomSheet<_NewMethod>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const _AddMethodSheet(),
    );
    if (result == null) return;
    await _addMethod(result);
  }

  Future<void> _addMethod(_NewMethod m) async {
    setState(() => _busy = true);
    try {
      // No PSP SDK is wired into the app yet, so we stand in a client-side
      // reference for the tokenised card. Replace with the real Flutterwave
      // token once card tokenisation is integrated.
      final pspToken = 'tok_${DateTime.now().millisecondsSinceEpoch}';
      await PaymentMethodsApi.instance.add(
        type: m.type,
        label: m.label,
        pspToken: pspToken,
        lastFour: m.lastFour,
        expiresAt: m.expiresAt,
      );
      if (mounted) wbShowSnack(context, 'Payment method added');
    } on ApiException catch (e) {
      if (mounted) wbShowError(context, e.message);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
    await _loadMethods();
  }

  Future<void> _openMethodActions(Map<String, dynamic> m) async {
    final id = safeString(m['id']);
    if (id.isEmpty) return;
    final isDefault = safeBool(m['isDefault']);
    final action = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => _MethodActionsSheet(
        label: safeString(m['label']),
        canSetDefault: !isDefault,
      ),
    );
    if (action == 'default') {
      await _setDefaultMethod(id);
    } else if (action == 'remove') {
      await _removeMethod(id);
    }
  }

  Future<void> _setDefaultMethod(String id) async {
    setState(() => _busy = true);
    try {
      await PaymentMethodsApi.instance.setDefault(id);
      if (mounted) wbShowSnack(context, 'Default payment method updated');
    } on ApiException catch (e) {
      if (mounted) wbShowError(context, e.message);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
    await _loadMethods();
  }

  Future<void> _removeMethod(String id) async {
    setState(() => _busy = true);
    try {
      await PaymentMethodsApi.instance.remove(id);
      if (mounted) wbShowSnack(context, context.l10n.walletMethodRemoved);
    } on ApiException catch (e) {
      if (mounted) wbShowError(context, e.message);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
    await _loadMethods();
  }

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
                Text(context.l10n.walletPaymentMethodsTitle, style: WBTypography.page),
              ],
            ),
            const SizedBox(height: WBSpacing.lg),
            _buildMethodsBody(),
            const SizedBox(height: WBSpacing.md),
            WBButton(
              label: context.l10n.walletAddNewMethod,
              icon: WBIconName.plus,
              size: WBButtonSize.lg,
              fullWidth: true,
              variant: WBButtonVariant.secondary,
              loading: _busy,
              onPressed: _busy ? null : _openAddSheet,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMethodsBody() {
    if (_methodsError != null) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(WBSpacing.md + 4),
        decoration: BoxDecoration(
          color: WBColors.bgSoft,
          borderRadius: BorderRadius.circular(WBRadius.card),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _methodsError!,
              style: WBTypography.caption.copyWith(color: WBColors.fgSecondary),
            ),
            const SizedBox(height: 12),
            WBButton(
              label: context.l10n.actionRetry,
              size: WBButtonSize.sm,
              variant: WBButtonVariant.secondary,
              onPressed: _loadMethods,
            ),
          ],
        ),
      );
    }
    final methods = _methods;
    if (methods == null) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 48),
        child: Center(
          child: SizedBox(
            width: 26,
            height: 26,
            child: CircularProgressIndicator(
              strokeWidth: 2.4,
              valueColor: AlwaysStoppedAnimation(WBColors.surfaceDark),
            ),
          ),
        ),
      );
    }
    if (methods.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(WBSpacing.md + 4),
        decoration: BoxDecoration(
          color: WBColors.bgSoft,
          borderRadius: BorderRadius.circular(WBRadius.card),
        ),
        child: Text(
          'No saved payment methods yet',
          style: WBTypography.caption.copyWith(color: WBColors.fgSecondary),
        ),
      );
    }
    return Column(
      children: [
        for (final m in methods) ...[
          _MethodCard(method: m, onMore: () => _openMethodActions(m)),
          const SizedBox(height: 10),
        ],
      ],
    );
  }
}

/// A single saved payment method rendered from the backend payload.
class _MethodCard extends StatelessWidget {
  const _MethodCard({required this.method, required this.onMore});

  final Map<String, dynamic> method;
  final VoidCallback onMore;

  WBIconName get _icon => switch (safeString(method['type'])) {
        'bank' => WBIconName.arrowRight,
        'mobile' => WBIconName.phone,
        _ => WBIconName.card,
      };

  String _sub(BuildContext context) {
    final parts = <String>[];
    if (safeBool(method['isDefault'])) {
      parts.add(context.l10n.savedAddressesDefault);
    }
    final expiresAt = safeString(method['expiresAt']);
    if (expiresAt.isNotEmpty) parts.add('Expires $expiresAt');
    if (parts.isEmpty) {
      final type = safeString(method['type']);
      if (type.isNotEmpty) parts.add(type);
    }
    return parts.join(' · ');
  }

  @override
  Widget build(BuildContext context) {
    final sub = _sub(context);
    return Container(
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
            child: WBIcon(_icon, size: 18),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  safeString(method['label']),
                  style: WBTypography.body.copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                if (sub.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    sub,
                    style: WBTypography.caption.copyWith(
                      color: WBColors.fgSecondary,
                    ),
                  ),
                ],
              ],
            ),
          ),
          GestureDetector(
            onTap: onMore,
            child: const WBIcon(
              WBIconName.more,
              size: 18,
              color: WBColors.fgPlaceholder,
            ),
          ),
        ],
      ),
    );
  }
}

/// Data collected by [_AddMethodSheet] before it is tokenised and POSTed.
class _NewMethod {
  const _NewMethod({
    required this.type,
    required this.label,
    this.lastFour,
    this.expiresAt,
  });

  final String type;
  final String label;
  final String? lastFour;
  final String? expiresAt;
}

/// Bottom sheet that captures the fields the POST /v1/payment-methods DTO
/// needs (type + label, plus optional lastFour/expiresAt).
class _AddMethodSheet extends StatefulWidget {
  const _AddMethodSheet();

  @override
  State<_AddMethodSheet> createState() => _AddMethodSheetState();
}

class _AddMethodSheetState extends State<_AddMethodSheet> {
  String _type = 'card';
  final _labelCtrl = TextEditingController();
  final _lastFourCtrl = TextEditingController();
  final _expiresCtrl = TextEditingController();

  @override
  void dispose() {
    _labelCtrl.dispose();
    _lastFourCtrl.dispose();
    _expiresCtrl.dispose();
    super.dispose();
  }

  bool get _valid => _labelCtrl.text.trim().isNotEmpty;

  void _submit() {
    Navigator.of(context).pop(
      _NewMethod(
        type: _type,
        label: _labelCtrl.text.trim(),
        lastFour: _lastFourCtrl.text.trim(),
        expiresAt: _expiresCtrl.text.trim(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        decoration: const BoxDecoration(
          color: WBColors.bgPrimary,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.fromLTRB(
          WBSpacing.screenPadding,
          16,
          WBSpacing.screenPadding,
          24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(context.l10n.walletAddNewMethod, style: WBTypography.section),
            const SizedBox(height: WBSpacing.lg),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final t in const [
                  (id: 'card', label: 'Card'),
                  (id: 'bank', label: 'Bank'),
                  (id: 'mobile', label: 'Mobile money'),
                ])
                  WBTag(
                    label: t.label,
                    active: _type == t.id,
                    onTap: () => setState(() => _type = t.id),
                  ),
              ],
            ),
            const SizedBox(height: 14),
            WBInput(
              label: context.l10n.walletPaymentMethodsTitle,
              placeholder: 'e.g. Visa •••• 4218',
              controller: _labelCtrl,
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 12),
            WBInput(
              label: 'Last 4 digits',
              placeholder: '4218',
              controller: _lastFourCtrl,
              keyboardType: TextInputType.number,
              maxLength: 4,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            ),
            const SizedBox(height: 12),
            WBInput(
              label: 'Expiry (MM/YY)',
              placeholder: '09/27',
              controller: _expiresCtrl,
            ),
            const SizedBox(height: WBSpacing.lg),
            WBButton(
              label: context.l10n.walletAddNewMethod,
              size: WBButtonSize.lg,
              fullWidth: true,
              disabled: !_valid,
              onPressed: _valid ? _submit : null,
            ),
          ],
        ),
      ),
    );
  }
}

/// Action sheet for a saved method: set as default and/or remove.
class _MethodActionsSheet extends StatelessWidget {
  const _MethodActionsSheet({
    required this.label,
    required this.canSetDefault,
  });

  final String label;
  final bool canSetDefault;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: WBColors.bgPrimary,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.fromLTRB(
        WBSpacing.screenPadding,
        16,
        WBSpacing.screenPadding,
        24,
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (label.isNotEmpty) ...[
              Text(
                label,
                style: WBTypography.body.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: WBSpacing.lg),
            ],
            if (canSetDefault) ...[
              WBButton(
                label: context.l10n.savedAddressesMakeDefault,
                size: WBButtonSize.lg,
                fullWidth: true,
                variant: WBButtonVariant.secondary,
                onPressed: () => Navigator.of(context).pop('default'),
              ),
              const SizedBox(height: 10),
            ],
            WBButton(
              label: context.l10n.actionRemove,
              size: WBButtonSize.lg,
              fullWidth: true,
              variant: WBButtonVariant.danger,
              onPressed: () => Navigator.of(context).pop('remove'),
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
