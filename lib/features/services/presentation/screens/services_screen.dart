import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/config/wawuafrica_hub.dart';
import '../../../../core/theme/wb_theme_exports.dart';
import '../../../../core/utils/wb_l10n.dart';

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
  // Insurance / Pension / Banking / Grants now resolve to real "Coming soon"
  // pages on the hub (/services/<id>), so the tiles link to a live URL instead
  // of a 404 — the coming-soon state is shown on the hub page they open.
  WawuService(
    label: 'EasyBuy',
    path: '/services/easybuy/apply',
    icon: Icons.shopping_bag_outlined,
  ),
  WawuService(
    label: 'Health Insurance',
    path: '/services/insurance',
    icon: Icons.health_and_safety_outlined,
  ),
  WawuService(
    label: 'Pension',
    path: '/services/pension',
    icon: Icons.savings_outlined,
  ),
  WawuService(
    label: 'Banking',
    path: '/services/banking',
    icon: Icons.account_balance_outlined,
  ),
  WawuService(
    label: 'Grants & Funding',
    path: '/services/grants',
    icon: Icons.volunteer_activism_outlined,
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
  bool ok = false;
  try {
    ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
  } catch (_) {
    // launchUrl can throw a PlatformException (no browser/handler) instead of
    // returning false — treat that as a failure and show the fallback.
    ok = false;
  }
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
          const SizedBox(height: WBSpacing.lg),
          // Same 3-column grid layout as WAWUBeauty's Services tab.
          GridView.builder(
            padding: EdgeInsets.zero,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              mainAxisExtent: 120,
            ),
            itemCount: wawuServices.length,
            itemBuilder: (context, index) =>
                _ServiceItem(service: wawuServices[index]),
          ),
        ],
      ),
    );
  }
}

/// One grid cell: icon over label (+ optional "Soon" pill), matching the
/// WAWUBeauty services grid. Tapping opens the service's hub page.
class _ServiceItem extends StatelessWidget {
  const _ServiceItem({required this.service});

  final WawuService service;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => openWawuHub(context, service.path),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
        decoration: BoxDecoration(
          color: WBColors.bgSecondary,
          borderRadius: BorderRadius.circular(WBRadius.card),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(service.icon, size: 26, color: WBColors.fgHeader),
            const SizedBox(height: 8),
            Text(
              service.label,
              maxLines: 2,
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              style: WBTypography.body.copyWith(
                color: WBColors.fgHeader,
                fontWeight: FontWeight.w600,
                fontSize: 11.5,
                height: 1.15,
              ),
            ),
            if (service.soon) ...[
              const SizedBox(height: 6),
              const ServiceSoonPill(),
            ],
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
