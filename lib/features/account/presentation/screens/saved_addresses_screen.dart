import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/network/api_exception.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/wb_theme_exports.dart';
import '../../../../core/utils/wb_actions.dart';
import '../../../../core/widgets/wb_widgets.dart';
import '../../application/address_controller.dart';

class SavedAddressesScreen extends StatefulWidget {
  const SavedAddressesScreen({super.key});

  @override
  State<SavedAddressesScreen> createState() => _SavedAddressesScreenState();
}

class _SavedAddressesScreenState extends State<SavedAddressesScreen> {
  @override
  void initState() {
    super.initState();
    AddressController.instance.load();
  }

  Future<void> _makeDefault(Address a) async {
    try {
      await AddressController.instance.setDefault(a.id);
      if (mounted) wbShowSnack(context, '${a.label} set as default');
    } on ApiException catch (e) {
      if (mounted) wbShowSnack(context, e.message);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: WBColors.bgSecondary,
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
                Text('Saved addresses', style: WBTypography.page),
              ],
            ),
            const SizedBox(height: WBSpacing.lg),
            WBButton(
              label: 'Add address',
              icon: WBIconName.plus,
              size: WBButtonSize.lg,
              fullWidth: true,
              variant: WBButtonVariant.secondary,
              onPressed: () => context.push(AppRoutes.addAddress),
            ),
            const SizedBox(height: WBSpacing.lg),
            ValueListenableBuilder(
              valueListenable: AddressController.instance.addresses,
              builder: (_, list, _) {
                return ValueListenableBuilder(
                  valueListenable: AddressController.instance.loading,
                  builder: (_, loading, _) {
                    if (loading && list.isEmpty) {
                      return const Padding(
                        padding: EdgeInsets.symmetric(vertical: 48),
                        child: Center(
                          child: SizedBox(
                            width: 26,
                            height: 26,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.4,
                              valueColor: AlwaysStoppedAnimation(
                                  WBColors.surfaceDark),
                            ),
                          ),
                        ),
                      );
                    }
                    if (list.isEmpty) {
                      return Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(WBSpacing.md + 4),
                        decoration: BoxDecoration(
                          color: WBColors.bgSoft,
                          borderRadius:
                              BorderRadius.circular(WBRadius.card),
                        ),
                        child: Text(
                          'No saved addresses yet. Add your first above.',
                          style: WBTypography.caption
                              .copyWith(color: WBColors.fgSecondary),
                        ),
                      );
                    }
                    return Column(
                      children: [
                        for (final a in list) ...[
                          _AddressCard(
                            address: a,
                            onEdit: () => context.push(
                              '${AppRoutes.addAddress}?id=${a.id}',
                            ),
                            onMakeDefault: () => _makeDefault(a),
                          ),
                          const SizedBox(height: WBSpacing.md),
                        ],
                      ],
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _AddressCard extends StatelessWidget {
  const _AddressCard({
    required this.address,
    required this.onEdit,
    required this.onMakeDefault,
  });

  final Address address;
  final VoidCallback onEdit;
  final VoidCallback onMakeDefault;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(WBSpacing.md + 2),
      decoration: BoxDecoration(
        color: WBColors.surfaceCard,
        borderRadius: BorderRadius.circular(WBRadius.card),
        boxShadow: WBShadows.card,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: const BoxDecoration(
                  color: WBColors.bgSoft,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: const WBIcon(WBIconName.pin, size: 18),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  address.label,
                  style: WBTypography.body.copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
              ),
              if (address.isDefault)
                const WBStatusPill(
                  label: 'Default',
                  kind: WBStatusKind.success,
                ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            address.line,
            style: WBTypography.body.copyWith(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          if (address.detail.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              address.detail,
              style: WBTypography.caption.copyWith(
                color: WBColors.fgSecondary,
              ),
            ),
          ],
          const SizedBox(height: 14),
          Row(
            children: [
              WBButton(
                label: 'Edit',
                size: WBButtonSize.sm,
                variant: WBButtonVariant.secondary,
                onPressed: onEdit,
              ),
              const SizedBox(width: 8),
              if (!address.isDefault)
                WBButton(
                  label: 'Make default',
                  size: WBButtonSize.sm,
                  variant: WBButtonVariant.ghost,
                  onPressed: onMakeDefault,
                ),
            ],
          ),
        ],
      ),
    );
  }
}
