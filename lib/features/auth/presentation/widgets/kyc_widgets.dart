import 'package:flutter/material.dart';

import '../../../../core/network/payouts_api.dart';
import '../../../../core/network/upload_service.dart';
import '../../../../core/theme/wb_theme_exports.dart';
import '../../../../core/utils/wb_actions.dart';
import '../../../../core/widgets/wb_widgets.dart';
import '../../../../core/utils/wb_l10n.dart';

/// Section header used in every KYC screen, UPPERCASE label + spacing.
/// Mirrors the look of the Profile screen menu-section labels so KYC feels
/// native to the design system.
class KycSectionLabel extends StatelessWidget {
  const KycSectionLabel({super.key, required this.label, this.sub});
  final String label;
  final String? sub;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: WBTypography.label.copyWith(
            color: WBColors.fgPlaceholder,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.66,
          ),
        ),
        if (sub != null) ...[
          const SizedBox(height: 4),
          Text(
            sub!,
            style: WBTypography.caption.copyWith(
              color: WBColors.fgSecondary,
            ),
          ),
        ],
      ],
    );
  }
}

/// Dashed-border upload tile. Tapping opens the image picker and uploads
/// the document to R2; once the upload succeeds the tile shows a filled
/// state and hands the stored object key back through [onUploaded].
class KycUploadTile extends StatefulWidget {
  const KycUploadTile({
    super.key,
    required this.label,
    required this.folder,
    required this.onUploaded,
    this.sub,
    this.icon = WBIconName.plus,
  });

  final String label;
  final String? sub;
  final WBIconName icon;

  /// R2 folder the document goes into, e.g. `UploadFolder.kyc('vendor')`.
  final String folder;

  /// Called with the stored object key once an upload succeeds.
  final ValueChanged<String> onUploaded;

  @override
  State<KycUploadTile> createState() => _KycUploadTileState();
}

class _KycUploadTileState extends State<KycUploadTile> {
  bool _uploaded = false;
  bool _uploading = false;

  Future<void> _pick() async {
    if (_uploading) return;
    setState(() => _uploading = true);
    try {
      final res = await UploadService.instance.pickAndUpload(
        folder: widget.folder,
      );
      if (res != null) {
        widget.onUploaded(res.key);
        if (mounted) setState(() => _uploaded = true);
      }
    } catch (_) {
      if (mounted) {
        wbShowSnack(context, context.l10n.kycUploadFailed);
      }
    } finally {
      if (mounted) setState(() => _uploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _pick,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: WBMotion.base,
        curve: WBMotion.easeSoft,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: _uploaded ? WBColors.surfaceCard : WBColors.bgSoft,
          borderRadius: BorderRadius.circular(WBRadius.card),
          border: Border.all(
            color: _uploaded ? WBColors.borderFilled : WBColors.bgDivider,
          ),
          boxShadow: _uploaded ? WBShadows.card : null,
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: _uploaded
                    ? const Color(0x1410B981)
                    : WBColors.bgPrimary,
                borderRadius: BorderRadius.circular(12),
              ),
              alignment: Alignment.center,
              child: _uploading
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor:
                            AlwaysStoppedAnimation(WBColors.fgHeader),
                      ),
                    )
                  : WBIcon(
                      _uploaded ? WBIconName.check : widget.icon,
                      size: 16,
                      color: _uploaded
                          ? const Color(0xFF10B981)
                          : WBColors.fgHeader,
                    ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.label,
                    style: WBTypography.body.copyWith(
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                    ),
                  ),
                  if (widget.sub != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      _uploaded ? 'Captured · tap to replace' : widget.sub!,
                      style: WBTypography.caption.copyWith(
                        color: _uploaded
                            ? const Color(0xFF10B981)
                            : WBColors.fgSecondary,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const WBIcon(
              WBIconName.chevronRight,
              size: 16,
              color: WBColors.fgPlaceholder,
            ),
          ],
        ),
      ),
    );
  }
}

/// Small status chip used on role cards and login screens to indicate
/// where the user is in the registration journey for a given role.
class KycStatusChip extends StatelessWidget {
  const KycStatusChip({
    super.key,
    required this.label,
    required this.tone,
  });

  final String label;
  final KycStatusTone tone;

  @override
  Widget build(BuildContext context) {
    final (bg, fg) = switch (tone) {
      KycStatusTone.unregistered => (WBColors.bgSoft, WBColors.fgSecondary),
      KycStatusTone.pending => (const Color(0x14F59E0B), const Color(0xFFB45309)),
      KycStatusTone.approved => (const Color(0x1410B981), const Color(0xFF065F46)),
      KycStatusTone.suspended => (const Color(0x14EF4444), const Color(0xFFB91C1C)),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(WBRadius.pill),
      ),
      child: Text(
        label,
        style: WBTypography.caption.copyWith(
          color: fg,
          fontWeight: FontWeight.w600,
          fontSize: 11,
          letterSpacing: 0.2,
        ),
      ),
    );
  }
}

enum KycStatusTone { unregistered, pending, approved, suspended }

/// Tap-to-open bank picker.  Fetches the Flutterwave bank list once, caches
/// it in memory, and shows a searchable bottom sheet.  Calls [onChanged] with
/// the selected bank name and bank code.
class KycBankPickerField extends StatefulWidget {
  const KycBankPickerField({
    super.key,
    required this.onChanged,
    this.value,
  });

  final String? value;
  final void Function(String bankName, String bankCode) onChanged;

  @override
  State<KycBankPickerField> createState() => _KycBankPickerFieldState();
}

class _KycBankPickerFieldState extends State<KycBankPickerField> {
  Future<void> _openPicker() async {
    List<BankItem> banks;
    try {
      banks = await PayoutsApi.instance.fetchBanks();
    } catch (_) {
      if (mounted) wbShowSnack(context, 'Could not load bank list. Try again.');
      return;
    }
    if (!mounted) return;
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: WBColors.bgPrimary,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(WBRadius.sheet)),
      ),
      builder: (_) => _BankPickerSheet(banks: banks, onSelected: widget.onChanged),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _openPicker,
      behavior: HitTestBehavior.opaque,
      child: Container(
        height: 52,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: WBColors.surfaceInput,
          borderRadius: BorderRadius.circular(WBRadius.pill),
        ),
        child: Row(
          children: [
            const WBIcon(WBIconName.card, size: 18, color: WBColors.fgPlaceholder),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                widget.value ?? 'Select bank',
                style: WBTypography.body.copyWith(
                  color: widget.value != null ? WBColors.fgHeader : WBColors.fgPlaceholder,
                  fontSize: 15,
                ),
              ),
            ),
            const WBIcon(WBIconName.chevronDown, size: 14, color: WBColors.fgPlaceholder),
          ],
        ),
      ),
    );
  }
}

class _BankPickerSheet extends StatefulWidget {
  const _BankPickerSheet({required this.banks, required this.onSelected});
  final List<BankItem> banks;
  final void Function(String bankName, String bankCode) onSelected;

  @override
  State<_BankPickerSheet> createState() => _BankPickerSheetState();
}

class _BankPickerSheetState extends State<_BankPickerSheet> {
  final _search = TextEditingController();
  List<BankItem> _filtered = const [];

  @override
  void initState() {
    super.initState();
    _filtered = widget.banks;
    _search.addListener(_filter);
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  void _filter() {
    final q = _search.text.toLowerCase();
    setState(() {
      _filtered = q.isEmpty
          ? widget.banks
          : widget.banks.where((b) => b.name.toLowerCase().contains(q)).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.7,
      maxChildSize: 0.95,
      builder: (_, scrollCtrl) => Column(
        children: [
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: WBColors.bgDivider,
              borderRadius: BorderRadius.circular(WBRadius.pill),
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextField(
              controller: _search,
              autofocus: true,
              style: WBTypography.body,
              decoration: InputDecoration(
                hintText: 'Search banks…',
                hintStyle: WBTypography.body.copyWith(color: WBColors.fgPlaceholder),
                filled: true,
                fillColor: WBColors.surfaceInput,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(WBRadius.pill),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                prefixIcon: const Icon(Icons.search, size: 18, color: WBColors.fgPlaceholder),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: ListView.builder(
              controller: scrollCtrl,
              itemCount: _filtered.length,
              itemBuilder: (_, i) {
                final bank = _filtered[i];
                return ListTile(
                  title: Text(bank.name, style: WBTypography.body),
                  onTap: () {
                    widget.onSelected(bank.name, bank.code);
                    Navigator.of(context).pop();
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
