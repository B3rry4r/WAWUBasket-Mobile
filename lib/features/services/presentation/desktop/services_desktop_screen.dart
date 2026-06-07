import 'package:flutter/material.dart';

import '../../../../core/responsive/wb_responsive_exports.dart';
import '../../../../core/theme/wb_theme_exports.dart';
import '../../../../core/utils/wb_l10n.dart';
import '../../../../core/widgets/wb_widgets.dart';
import '../screens/services_screen.dart';

/// Desktop-web layout for the Services tab. Body content only — the role's
/// desktop scaffold (customer top bar / operator sidebar) already supplies the
/// chrome. Re-lays the mobile list into a wide, centered multi-column grid,
/// reusing the same [wawuServices] data and [openWawuHub] behaviour.
class ServicesDesktopScreen extends StatelessWidget {
  const ServicesDesktopScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return SingleChildScrollView(
      child: WBMaxWidth(
        maxWidth: WBBreakpoints.maxContent,
        padding: const EdgeInsets.fromLTRB(
          WBSpacing.xl,
          WBSpacing.xl,
          WBSpacing.xl,
          WBSpacing.xxl,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l.navServices, style: WBTypography.page),
            const SizedBox(height: WBSpacing.lg),
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => openWawuHub(context, '/services'),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 16,
                ),
                decoration: BoxDecoration(
                  color: WBColors.bgSecondary,
                  borderRadius: BorderRadius.circular(WBRadius.card),
                ),
                child: Image.asset(
                  'assets/brand_icons/wawuafrica_mark.png',
                  height: 44,
                  fit: BoxFit.contain,
                  alignment: Alignment.centerLeft,
                ),
              ),
            ),
            const SizedBox(height: WBSpacing.xl),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: EdgeInsets.zero,
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 360,
                mainAxisSpacing: WBSpacing.md,
                crossAxisSpacing: WBSpacing.md,
                mainAxisExtent: 76,
              ),
              itemCount: wawuServices.length,
              itemBuilder: (_, i) => _ServiceCard(service: wawuServices[i]),
            ),
          ],
        ),
      ),
    );
  }
}

class _ServiceCard extends StatefulWidget {
  const _ServiceCard({required this.service});

  final WawuService service;

  @override
  State<_ServiceCard> createState() => _ServiceCardState();
}

class _ServiceCardState extends State<_ServiceCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final service = widget.service;
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => openWawuHub(context, service.path),
        child: AnimatedContainer(
          duration: WBMotion.base,
          curve: WBMotion.easeSoft,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          decoration: BoxDecoration(
            color: WBColors.surfaceCard,
            borderRadius: BorderRadius.circular(WBRadius.card),
            boxShadow: _hovered ? WBShadows.float : WBShadows.card,
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: WBColors.bgSecondary,
                  borderRadius: BorderRadius.circular(WBRadius.input),
                ),
                alignment: Alignment.center,
                child: Icon(service.icon, size: 22, color: WBColors.fgHeader),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  service.label,
                  style: WBTypography.body.copyWith(
                    color: WBColors.fgHeader,
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
              ),
              if (service.soon) ...[
                const ServiceSoonPill(),
                const SizedBox(width: 10),
              ],
              const WBIcon(
                WBIconName.chevronRight,
                size: 18,
                color: WBColors.fgPlaceholder,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
