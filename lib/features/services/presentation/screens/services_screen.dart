import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/config/wawuafrica_hub.dart';
import '../../../../core/theme/wb_theme_exports.dart';
import '../../../../core/utils/wb_l10n.dart';
import '../../../../core/widgets/wb_widgets.dart';

/// A single WAWUAfrica service surfaced in the Services tab. `soon` flags a
/// service that is announced but not yet live (renders a "Soon" pill).
class WawuService {
  const WawuService({
    required this.label,
    required this.path,
    required this.icon,
    this.soon = false,
  });

  final String label;
  final String path;
  final IconData icon;
  final bool soon;
}

/// Every WAWUAfrica service the app surfaces. Tapping one deep-links into the
/// hub web platform via [openWawuHub]. Promoted verbatim from the old customer
/// home services strip so the same set reaches every role.
const List<WawuService> wawuServices = [
  WawuService(
    label: 'EasyBuy',
    path: '/services/easybuy/apply',
    icon: Icons.shopping_bag_outlined,
  ),
  WawuService(
    label: 'Health Insurance',
    path: '/services/insurance',
    icon: Icons.health_and_safety_outlined,
    soon: true,
  ),
  WawuService(
    label: 'Pension',
    path: '/services/pension',
    icon: Icons.savings_outlined,
    soon: true,
  ),
  WawuService(
    label: 'Banking',
    path: '/services/banking',
    icon: Icons.account_balance_outlined,
    soon: true,
  ),
  WawuService(
    label: 'Grants & Funding',
    path: '/services/grants',
    icon: Icons.volunteer_activism_outlined,
    soon: true,
  ),
  WawuService(
    label: 'CAC Registration',
    path: '/services/cac-registration/apply',
    icon: Icons.assignment_outlined,
  ),
  WawuService(
    label: 'NEPC Registration',
    path: '/services/nepc-registration/apply',
    icon: Icons.public_outlined,
  ),
  WawuService(
    label: 'Mentorship',
    path: '/services/mentors',
    icon: Icons.diversity_3_outlined,
  ),
];

/// Opens `$wawuAfricaHubUrl$path` in the external browser. Shows a snackbar if
/// the platform can't launch the url. Promoted verbatim from the old home
/// `_openHub` so behaviour is identical for every role.
Future<void> openWawuHub(BuildContext context, String path) async {
  final messenger = ScaffoldMessenger.of(context);
  final uri = Uri.parse('$wawuAfricaHubUrl$path');
  final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
  if (!ok && context.mounted) {
    messenger.showSnackBar(
      const SnackBar(content: Text('Could not open WAWUAfrica')),
    );
  }
}

/// The Services tab. A standard scrollable list of tappable WAWUAfrica service
/// cards, present in every role's bottom nav. Tapping a card opens the matching
/// hub page; the WAWUAfrica brand mark at the top links to the services home.
class ServicesScreen extends StatelessWidget {
  const ServicesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return SafeArea(
      bottom: false,
      child: ListView(
        padding: EdgeInsets.fromLTRB(
          WBSpacing.screenPadding,
          12 + MediaQuery.of(context).padding.top,
          WBSpacing.screenPadding,
          140,
        ),
        children: [
          Text(l.navServices, style: WBTypography.page),
          const SizedBox(height: WBSpacing.md),
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => openWawuHub(context, '/services'),
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
              decoration: BoxDecoration(
                color: WBColors.bgSecondary,
                borderRadius: BorderRadius.circular(WBRadius.card),
              ),
              child: Image.asset(
                'assets/brand_icons/wawuafrica_mark.png',
                height: 40,
                fit: BoxFit.contain,
                alignment: Alignment.centerLeft,
              ),
            ),
          ),
          const SizedBox(height: WBSpacing.lg),
          for (final service in wawuServices) ...[
            _ServiceTile(service: service),
            const SizedBox(height: WBSpacing.sm),
          ],
        ],
      ),
    );
  }
}

/// One full-width service row: icon disc + label (+ optional "Soon" pill) and a
/// chevron. Tapping opens the service's hub page.
class _ServiceTile extends StatelessWidget {
  const _ServiceTile({required this.service});

  final WawuService service;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => openWawuHub(context, service.path),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
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
    );
  }
}

/// The "Soon" pill flagging an announced-but-not-live service. Reused verbatim
/// from the old home services strip markup.
class ServiceSoonPill extends StatelessWidget {
  const ServiceSoonPill({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 1.5),
      decoration: BoxDecoration(
        color: WBColors.surfaceDark,
        borderRadius: BorderRadius.circular(WBRadius.pill),
      ),
      child: const Text(
        'Soon',
        style: TextStyle(
          color: Colors.white,
          fontSize: 9,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
