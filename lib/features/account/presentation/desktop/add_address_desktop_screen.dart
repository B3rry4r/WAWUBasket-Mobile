import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/network/api_exception.dart';
import '../../../../core/responsive/wb_responsive_exports.dart';
import '../../../../core/theme/wb_theme_exports.dart';
import '../../../../core/utils/wb_actions.dart';
import '../../../../core/utils/wb_l10n.dart';
import '../../../../core/widgets/wb_widgets.dart';
import '../../../shell/presentation/desktop/customer_web_scaffold.dart';
import '../../application/address_controller.dart';

/// Desktop-web layout for the add / edit saved-address form. Isolated from the
/// mobile [AddAddressScreen] — same controller, state, validation, money/copy
/// and navigation, re-laid-out as a centered reading column inside the shared
/// [CustomerWebScaffold] chrome.
class AddAddressDesktopScreen extends StatefulWidget {
  const AddAddressDesktopScreen({super.key, this.addressId});

  /// When set, the screen edits that saved address instead of adding one.
  final String? addressId;

  @override
  State<AddAddressDesktopScreen> createState() =>
      _AddAddressDesktopScreenState();
}

class _AddAddressDesktopScreenState extends State<AddAddressDesktopScreen> {
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
      wbShowSnack(context, context.l10n.addAddressEnterLine);
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
      wbShowSnack(
        context,
        _editing ? context.l10n.addAddressUpdated : context.l10n.addAddressSaved,
      );
      context.pop();
    } on ApiException catch (e) {
      if (mounted) wbShowError(context, e.message);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return CustomerWebScaffold(
      child: WBMaxWidth(
        maxWidth: 680,
        padding: const EdgeInsets.fromLTRB(
          WBSpacing.screenPadding,
          WBSpacing.xl,
          WBSpacing.screenPadding,
          40,
        ),
        child: ListView(
          children: [
            Row(
              children: [
                WBBackChip(onPressed: () => context.pop()),
                const SizedBox(width: 14),
                Text(
                  _editing
                      ? context.l10n.addAddressEditTitle
                      : context.l10n.addAddressTitle,
                  style: WBTypography.page,
                ),
              ],
            ),
            const SizedBox(height: WBSpacing.lg),
            Text(
              context.l10n.addAddressLabelSection,
              style: WBTypography.label.copyWith(
                color: WBColors.fgPlaceholder,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.66,
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                for (final option in [
                  (id: 'home', label: context.l10n.addAddressLabelHome),
                  (id: 'office', label: context.l10n.addAddressLabelOffice),
                  (id: 'other', label: context.l10n.addAddressLabelOther),
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
              label: context.l10n.addAddressLine,
              placeholder: context.l10n.addAddressLinePlaceholder,
              leadingIcon: WBIconName.pin,
              controller: _line,
            ),
            const SizedBox(height: WBSpacing.md),
            WBInput(
              label: context.l10n.addAddressApartment,
              placeholder: context.l10n.addAddressApartmentPlaceholder,
              leadingIcon: WBIconName.home,
              controller: _apartment,
            ),
            const SizedBox(height: WBSpacing.md),
            WBInput(
              label: context.l10n.addAddressNote,
              placeholder: context.l10n.addAddressNotePlaceholder,
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
                    context.l10n.addAddressDefault,
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
              label: _editing
                  ? context.l10n.addAddressSaveChanges
                  : context.l10n.addAddressSave,
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
