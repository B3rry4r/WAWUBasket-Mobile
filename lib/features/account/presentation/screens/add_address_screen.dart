import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/wb_theme_exports.dart';
import '../../../../core/utils/wb_actions.dart';
import '../../../../core/widgets/wb_widgets.dart';

class AddAddressScreen extends StatefulWidget {
  const AddAddressScreen({super.key, this.editing = false});
  final bool editing;

  @override
  State<AddAddressScreen> createState() => _AddAddressScreenState();
}

class _AddAddressScreenState extends State<AddAddressScreen> {
  bool _saveDefault = false;
  String _label = 'home';

  @override
  Widget build(BuildContext context) {
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
                Text(
                  widget.editing ? 'Edit address' : 'Add address',
                  style: WBTypography.page,
                ),
              ],
            ),
            const SizedBox(height: WBSpacing.lg),
            Text(
              'LABEL',
              style: WBTypography.label.copyWith(
                color: WBColors.fgPlaceholder,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.66,
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                for (final option in const [
                  (id: 'home', label: 'Home'),
                  (id: 'office', label: 'Office'),
                  (id: 'other', label: 'Other'),
                ]) ...[
                  WBTag(
                    label: option.label,
                    active: _label == option.id,
                    onTap: () => setState(() => _label = option.id),
                  ),
                  const SizedBox(width: 8),
                ],
              ],
            ),
            const SizedBox(height: WBSpacing.lg),
            const WBInput(
              label: 'Address line',
              placeholder: 'Street, area, city',
              leadingIcon: WBIconName.pin,
              initialValue: '12 Adeola Odeku St, Victoria Island',
            ),
            const SizedBox(height: WBSpacing.md),
            const WBInput(
              label: 'Apartment / unit',
              placeholder: 'Optional',
              leadingIcon: WBIconName.home,
              initialValue: 'Apt 4B',
            ),
            const SizedBox(height: WBSpacing.md),
            const WBInput(
              label: 'Note for the rider',
              placeholder: 'Use the gate on Akin Adesola',
              leadingIcon: WBIconName.message,
            ),
            const SizedBox(height: WBSpacing.lg),
            GestureDetector(
              onTap: () => setState(() => _saveDefault = !_saveDefault),
              behavior: HitTestBehavior.opaque,
              child: Row(
                children: [
                  Container(
                    width: 22,
                    height: 22,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _saveDefault
                          ? WBColors.surfaceDark
                          : Colors.transparent,
                      border: Border.all(
                        color: _saveDefault
                            ? WBColors.surfaceDark
                            : WBColors.bgDivider,
                        width: 1.5,
                      ),
                    ),
                    alignment: Alignment.center,
                    child: _saveDefault
                        ? const WBIcon(
                            WBIconName.check,
                            size: 12,
                            color: Colors.white,
                            strokeWidth: 2.5,
                          )
                        : null,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'Make this my default address',
                    style: WBTypography.body.copyWith(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: WBSpacing.xl),
            WBButton(
              label: widget.editing ? 'Save changes' : 'Save address',
              size: WBButtonSize.lg,
              fullWidth: true,
              onPressed: () {
                wbShowSnack(
                  context,
                  widget.editing
                      ? 'Address updated'
                      : 'Address saved',
                );
                context.pop();
              },
            ),
          ],
        ),
      ),
    );
  }
}
