import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/wb_theme_exports.dart';
import '../../../../core/utils/wb_actions.dart';
import '../../../../core/widgets/wb_widgets.dart';
import '../../../shopping/application/mock_data.dart';

class VendorMenuScreen extends StatefulWidget {
  const VendorMenuScreen({super.key});

  @override
  State<VendorMenuScreen> createState() => _VendorMenuScreenState();
}

class _VendorMenuScreenState extends State<VendorMenuScreen> {
  String _tab = 'All';
  static const _tabs = ['All', 'Popular', 'Mains', 'Sides', 'Drinks'];

  @override
  Widget build(BuildContext context) {
    final items = MockData.menu;
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
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Your menu', style: WBTypography.page),
                    Text(
                      "What's cooking today?",
                      style: WBTypography.caption.copyWith(
                        color: WBColors.fgSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              WBButton(
                label: 'Add',
                size: WBButtonSize.sm,
                trailingIcon: WBIconName.plus,
                onPressed: () => context.push(AppRoutes.vendorMenuEdit),
              ),
            ],
          ),
          const SizedBox(height: WBSpacing.lg),
          SizedBox(
            height: 36,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _tabs.length,
              separatorBuilder: (_, _) => const SizedBox(width: 8),
              itemBuilder: (_, i) => WBTag(
                label: _tabs[i],
                active: _tabs[i] == _tab,
                onTap: () => setState(() => _tab = _tabs[i]),
              ),
            ),
          ),
          const SizedBox(height: WBSpacing.lg),
          for (final item in items)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: WBCard(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: SizedBox(
                        width: 64,
                        height: 64,
                        child: WBNetworkImage(url: item.imageUrl),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.name,
                            style: WBTypography.body.copyWith(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            item.formattedPrice,
                            style: WBTypography.caption.copyWith(
                              color: WBColors.fgSecondary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const WBStatusPill(
                                label: 'Available',
                                kind: WBStatusKind.success,
                              ),
                              const SizedBox(width: 8),
                              GestureDetector(
                                onTap: () => context.push(
                                  AppRoutes.vendorMenuEdit,
                                ),
                                child: Text(
                                  'Edit',
                                  style: WBTypography.caption.copyWith(
                                    color: WBColors.fgHeader,
                                    fontWeight: FontWeight.w500,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              GestureDetector(
                                onTap: () => wbShowSnack(
                                  context,
                                  '${item.name} marked out of stock',
                                ),
                                child: Text(
                                  'Out of stock',
                                  style: WBTypography.caption.copyWith(
                                    color: WBColors.statusError,
                                    fontWeight: FontWeight.w500,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
