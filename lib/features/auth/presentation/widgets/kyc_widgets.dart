import 'package:flutter/material.dart';

import '../../../../core/theme/wb_theme_exports.dart';
import '../../../../core/utils/wb_actions.dart';
import '../../../../core/widgets/wb_widgets.dart';

/// Section header used in every KYC screen — UPPERCASE label + spacing.
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

/// Dashed-border upload tile. Tapping fires [onTap] (which should open the
/// camera / file picker — here it just snackbars). Once "uploaded" the
/// tile shows a filled state.
class KycUploadTile extends StatefulWidget {
  const KycUploadTile({
    super.key,
    required this.label,
    this.sub,
    this.icon = WBIconName.plus,
  });

  final String label;
  final String? sub;
  final WBIconName icon;

  @override
  State<KycUploadTile> createState() => _KycUploadTileState();
}

class _KycUploadTileState extends State<KycUploadTile> {
  bool _uploaded = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        setState(() => _uploaded = true);
        wbShowSnack(context, '${widget.label} captured');
      },
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
              child: WBIcon(
                _uploaded ? WBIconName.check : widget.icon,
                size: 16,
                color:
                    _uploaded ? const Color(0xFF10B981) : WBColors.fgHeader,
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

enum KycStatusTone { unregistered, pending, approved }
