import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/network/api_exception.dart';
import '../../../../core/theme/wb_theme_exports.dart';
import '../../../../core/utils/wb_actions.dart';
import '../../../../core/widgets/wb_widgets.dart';
import '../../application/address_controller.dart';

class AddAddressScreen extends StatefulWidget {
  const AddAddressScreen({super.key, this.addressId});

  /// When set, the screen edits that saved address instead of adding one.
  final String? addressId;

  @override
  State<AddAddressScreen> createState() => _AddAddressScreenState();
}

class _AddAddressScreenState extends State<AddAddressScreen> {
  final _line = TextEditingController();
  final _apartment = TextEditingController();
  final _note = TextEditingController();
  bool _saveDefault = false;
  String _label = 'home';
  bool _busy = false;

  bool get _editing => widget.addressId != null;

  @override
  void initState() {
    super.initState();
    if (_editing) _loadForEdit();
  }

  @override
  void dispose() {
    _line.dispose();
    _apartment.dispose();
    _note.dispose();
    super.dispose();
  }

  Future<void> _loadForEdit() async {
    var a = AddressController.instance.byId(widget.addressId!);
    if (a == null) {
      await AddressController.instance.load();
      a = AddressController.instance.byId(widget.addressId!);
    }
    if (a == null || !mounted) return;
    final addr = a;
    setState(() {
      _line.text = addr.line;
      _apartment.text = addr.apartment;
      _note.text = addr.noteForRider;
      _label = addr.label;
      _saveDefault = addr.isDefault;
    });
  }

  Future<void> _save() async {
    if (_line.text.trim().isEmpty) {
      wbShowSnack(context, 'Enter the address line.');
      return;
    }
    setState(() => _busy = true);
    try {
      final ctrl = AddressController.instance;
      if (_editing) {
        await ctrl.update(
          widget.addressId!,
          label: _label,
          line: _line.text.trim(),
          apartment: _apartment.text.trim(),
          noteForRider: _note.text.trim(),
          isDefault: _saveDefault,
        );
      } else {
        await ctrl.create(
          label: _label,
          line: _line.text.trim(),
          apartment: _apartment.text.trim(),
          noteForRider: _note.text.trim(),
          isDefault: _saveDefault,
        );
      }
      if (!mounted) return;
      wbShowSnack(context, _editing ? 'Address updated' : 'Address saved');
      context.pop();
    } on ApiException catch (e) {
      if (mounted) wbShowSnack(context, e.message);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

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
                  _editing ? 'Edit address' : 'Add address',
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
            WBInput(
              label: 'Address line',
              placeholder: 'Street, area, city',
              leadingIcon: WBIconName.pin,
              controller: _line,
            ),
            const SizedBox(height: WBSpacing.md),
            WBInput(
              label: 'Apartment / unit',
              placeholder: 'Optional',
              leadingIcon: WBIconName.home,
              controller: _apartment,
            ),
            const SizedBox(height: WBSpacing.md),
            WBInput(
              label: 'Note for the rider',
              placeholder: 'Use the gate on Akin Adesola',
              leadingIcon: WBIconName.message,
              controller: _note,
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
              label: _editing ? 'Save changes' : 'Save address',
              size: WBButtonSize.lg,
              fullWidth: true,
              loading: _busy,
              onPressed: _save,
            ),
          ],
        ),
      ),
    );
  }
}
