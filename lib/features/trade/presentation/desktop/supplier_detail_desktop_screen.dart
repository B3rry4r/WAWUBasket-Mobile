import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/responsive/wb_responsive_exports.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/wb_theme_exports.dart';
import '../../../../core/utils/wb_actions.dart';
import '../../../../core/widgets/wb_widgets.dart';
import '../../../shell/presentation/desktop/customer_web_scaffold.dart';
import '../../application/trade_controller.dart';
import '../widgets/bulk_lot_card.dart';

/// Desktop-web layout for a single supplier. Mirrors [SupplierDetailScreen]'s
/// data loading (resolve suppliers + bulk lots from [TradeController]), the
/// supplier-not-found / loading states, the bulk-lot filtering by supplier
/// name, and the connect-with-supplier action exactly — re-laid out as a
/// two-column detail: the supplier identity card, stats and about copy on the
/// LEFT, the specialties, available bulk lots and the primary connect CTA on
/// the RIGHT. Desktop-only — the mobile build never imports this file.
class SupplierDetailDesktopScreen extends StatefulWidget {
  const SupplierDetailDesktopScreen({super.key, required this.supplierId});

  final String supplierId;

  @override
  State<SupplierDetailDesktopScreen> createState() =>
      _SupplierDetailDesktopScreenState();
}

class _SupplierDetailDesktopScreenState
    extends State<SupplierDetailDesktopScreen> {
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _resolve();
  }

  Future<void> _resolve() async {
    final ctrl = TradeController.instance;
    if (ctrl.suppliers.value.isEmpty) await ctrl.loadSuppliers();
    if (ctrl.bulkLots.value.isEmpty) await ctrl.loadBulkLots();
    if (mounted) setState(() => _loading = false);
  }

  void _onBack() =>
      context.canPop() ? context.pop() : context.go(AppRoutes.trade);

  @override
  Widget build(BuildContext context) {
    return CustomerWebScaffold(child: _buildBody(context));
  }

  Widget _buildBody(BuildContext context) {
    final ctrl = TradeController.instance;
    final supplier = ctrl.supplierById(widget.supplierId);

    if (supplier == null) {
      return _stateBody(
        child: _loading
            ? const SizedBox(
                width: 28,
                height: 28,
                child: CircularProgressIndicator(
                  strokeWidth: 2.6,
                  valueColor: AlwaysStoppedAnimation(WBColors.surfaceDark),
                ),
              )
            : Text(
                'Supplier not found.',
                style: WBTypography.body.copyWith(color: WBColors.fgSecondary),
              ),
      );
    }

    final lots = [
      for (final l in ctrl.bulkLots.value)
        if (l.supplierName == supplier.name) l,
    ];

    return SingleChildScrollView(
      child: WBMaxWidth(
        maxWidth: WBBreakpoints.maxContent,
        padding: const EdgeInsets.fromLTRB(
          WBSpacing.screenPadding,
          WBSpacing.lg,
          WBSpacing.screenPadding,
          WBSpacing.xxl,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: WBBackChip(onPressed: _onBack),
            ),
            const SizedBox(height: WBSpacing.lg),
            Text('Supplier', style: WBTypography.page),
            const SizedBox(height: WBSpacing.lg),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Left column: identity card + stats + about.
                Expanded(
                  flex: 6,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(WBSpacing.lg),
                        decoration: BoxDecoration(
                          color: WBColors.surfaceDark,
                          borderRadius: BorderRadius.circular(WBRadius.card),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                ClipOval(
                                  child: SizedBox(
                                    width: 64,
                                    height: 64,
                                    child: WBNetworkImage(
                                      url: supplier.avatarUrl,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        supplier.name,
                                        style: WBTypography.cardTitle.copyWith(
                                          color: Colors.white,
                                          fontSize: 18,
                                        ),
                                      ),
                                      const SizedBox(height: 3),
                                      Text(
                                        supplier.region,
                                        style: WBTypography.caption.copyWith(
                                          color: Colors.white
                                              .withValues(alpha: 0.65),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 14),
                            Row(
                              children: [
                                _DarkStat(
                                  label: 'Rating',
                                  value: supplier.rating.toString(),
                                ),
                                const SizedBox(width: 10),
                                _DarkStat(
                                  label: 'Reviews',
                                  value: supplier.reviews.toString(),
                                ),
                                const SizedBox(width: 10),
                                _DarkStat(
                                  label: 'Capacity',
                                  value: supplier.capacity,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: WBSpacing.lg),
                      Text(
                        'About this supplier',
                        style: WBTypography.cardTitle.copyWith(fontSize: 16),
                      ),
                      const SizedBox(height: 10),
                      WBCard(
                        child: Text(
                          'Verified farm partner sourcing directly from co-op members in ${supplier.region}. '
                          'Quality-controlled at the warehouse and shipped nationwide with traceable batch lots.',
                          style: WBTypography.body.copyWith(
                            fontSize: 14,
                            height: 1.5,
                            color: WBColors.fgSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: WBSpacing.xl),
                // Right column: specialties + available lots + connect CTA.
                Expanded(
                  flex: 5,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Specialties',
                        style: WBTypography.cardTitle.copyWith(fontSize: 16),
                      ),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          for (final s in supplier.specialties)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 7,
                              ),
                              decoration: BoxDecoration(
                                color: WBColors.surfaceTag,
                                borderRadius:
                                    BorderRadius.circular(WBRadius.pill),
                              ),
                              child: Text(
                                s,
                                style: WBTypography.caption.copyWith(
                                  color: WBColors.fgHeader,
                                  fontWeight: FontWeight.w500,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: WBSpacing.xl),
                      WBButton(
                        label: 'Connect with supplier',
                        fullWidth: true,
                        size: WBButtonSize.lg,
                        trailingIcon: WBIconName.arrowRight,
                        onPressed: () {
                          wbShowSnack(
                            context,
                            'Connection request sent to ${supplier.name}',
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (lots.isNotEmpty) ...[
              const SizedBox(height: WBSpacing.xl),
              Text(
                'Available bulk lots',
                style: WBTypography.cardTitle.copyWith(fontSize: 16),
              ),
              const SizedBox(height: 12),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: EdgeInsets.zero,
                itemCount: lots.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 0.62,
                ),
                itemBuilder: (_, i) => BulkLotCard(
                  lot: lots[i],
                  onTap: () => context.push(
                    '${AppRoutes.tradeLot}/${lots[i].id}',
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _stateBody({required Widget child}) {
    return WBMaxWidth(
      maxWidth: WBBreakpoints.maxContent,
      padding: const EdgeInsets.all(WBSpacing.screenPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: WBSpacing.lg),
          WBBackChip(onPressed: _onBack),
          const SizedBox(height: 120),
          Center(child: child),
        ],
      ),
    );
  }
}

class _DarkStat extends StatelessWidget {
  const _DarkStat({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label.toUpperCase(),
              style: WBTypography.label.copyWith(
                color: Colors.white.withValues(alpha: 0.55),
                fontWeight: FontWeight.w500,
                fontSize: 9,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: WBTypography.body.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
