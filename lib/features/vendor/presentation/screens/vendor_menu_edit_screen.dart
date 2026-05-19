import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/wb_theme_exports.dart';
import '../../../../core/utils/wb_actions.dart';
import '../../../../core/widgets/wb_widgets.dart';
import '../../application/vendor_menu_controller.dart';

/// Add-or-edit form for one menu item. With an `itemId` it loads that item
/// for editing; without one it stages a new item to be added on save.
///
/// Modifier groups (size / spice / extras) are first-class: add a group,
/// add option rows, set per-option price deltas, mark a group required.
/// Save commits everything to the in-memory [VendorMenuController].
class VendorMenuEditScreen extends StatefulWidget {
  const VendorMenuEditScreen({super.key, this.itemId});
  final String? itemId;

  @override
  State<VendorMenuEditScreen> createState() => _VendorMenuEditScreenState();
}

class _VendorMenuEditScreenState extends State<VendorMenuEditScreen> {
  late final _name = TextEditingController();
  late final _desc = TextEditingController();
  late final _price = TextEditingController();
  late String _category;
  late bool _available;
  late double _prep;
  late List<_EditableGroup> _groups;

  bool get _isEdit => widget.itemId != null;

  @override
  void initState() {
    super.initState();
    final src =
        widget.itemId == null ? null : VendorMenuController.instance.byId(widget.itemId!);
    _name.text = src?.name ?? '';
    _desc.text = src?.description ?? '';
    _price.text = src == null ? '' : '${src.priceNaira}';
    _category = src?.category ?? VendorMenuController.categories.first;
    _available = src?.available ?? true;
    _prep = (src?.prepMins ?? 15).toDouble();
    _groups = (src?.modifierGroups ?? const <ModifierGroup>[])
        .map(_EditableGroup.fromGroup)
        .toList();
  }

  @override
  void dispose() {
    _name.dispose();
    _desc.dispose();
    _price.dispose();
    super.dispose();
  }

  void _save() {
    final priceParsed = int.tryParse(_price.text.replaceAll(',', '')) ?? 0;
    if (_name.text.trim().isEmpty || priceParsed <= 0) {
      wbShowSnack(context, 'Dish name and price are required.');
      return;
    }
    final groups = [for (final g in _groups) g.toGroup()];
    final ctrl = VendorMenuController.instance;
    if (_isEdit) {
      ctrl.update(
        id: widget.itemId!,
        name: _name.text.trim(),
        description: _desc.text.trim(),
        priceNaira: priceParsed,
        category: _category,
        prepMins: _prep.toInt(),
        available: _available,
        modifierGroups: groups,
      );
      wbShowSnack(context, '${_name.text.trim()} updated');
    } else {
      ctrl.add(
        name: _name.text.trim(),
        description: _desc.text.trim(),
        priceNaira: priceParsed,
        category: _category,
        prepMins: _prep.toInt(),
        available: _available,
        modifierGroups: groups,
      );
      wbShowSnack(context, '${_name.text.trim()} added to the menu');
    }
    context.pop();
  }

  void _addGroup() {
    setState(() {
      _groups = [
        ..._groups,
        _EditableGroup(
          name: 'New group',
          required: false,
          options: [_EditableOption(label: '', priceDeltaNaira: 0)],
        ),
      ];
    });
  }

  void _addOption(int groupIndex) {
    setState(() {
      _groups[groupIndex].options.add(
            _EditableOption(label: '', priceDeltaNaira: 0),
          );
    });
  }

  void _removeOption(int g, int o) {
    setState(() {
      _groups[g].options.removeAt(o);
      if (_groups[g].options.isEmpty) _groups.removeAt(g);
    });
  }

  void _removeGroup(int index) {
    setState(() => _groups.removeAt(index));
  }

  void _pickCategory() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: WBColors.bgPrimary,
      shape: const RoundedRectangleBorder(
        borderRadius:
            BorderRadius.vertical(top: Radius.circular(WBRadius.sheet)),
      ),
      builder: (sheetCtx) {
        return Padding(
          padding: EdgeInsets.only(
            left: WBSpacing.screenPadding,
            right: WBSpacing.screenPadding,
            top: WBSpacing.lg,
            bottom: MediaQuery.of(sheetCtx).padding.bottom + WBSpacing.lg,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: WBSpacing.lg),
                  decoration: BoxDecoration(
                    color: WBColors.bgDivider,
                    borderRadius: BorderRadius.circular(WBRadius.pill),
                  ),
                ),
              ),
              Text(
                'Category',
                style: WBTypography.cardTitle.copyWith(fontSize: 18),
              ),
              const SizedBox(height: WBSpacing.md),
              for (final c in VendorMenuController.categories)
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () {
                    setState(() => _category = c);
                    Navigator.of(sheetCtx).pop();
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            c,
                            style: WBTypography.body.copyWith(
                              fontWeight: FontWeight.w500,
                              fontSize: 15,
                            ),
                          ),
                        ),
                        if (c == _category)
                          const WBIcon(WBIconName.check, size: 16),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: WBColors.bgSecondary,
      body: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            ListView(
              padding: const EdgeInsets.fromLTRB(
                WBSpacing.screenPadding,
                12,
                WBSpacing.screenPadding,
                140,
              ),
              children: [
                Row(
                  children: [
                    WBBackChip(onPressed: () => context.pop()),
                    const SizedBox(width: 14),
                    Text(
                      _isEdit ? 'Edit dish' : 'Add a new dish',
                      style: WBTypography.page,
                    ),
                  ],
                ),
                const SizedBox(height: WBSpacing.lg),
                GestureDetector(
                  onTap: () =>
                      wbShowSnack(context, 'Pick a photo from your camera'),
                  child: Container(
                    height: 160,
                    decoration: BoxDecoration(
                      color: WBColors.bgSoft,
                      borderRadius: BorderRadius.circular(WBRadius.card),
                      border: Border.all(color: WBColors.bgDivider),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: const BoxDecoration(
                            color: WBColors.bgPrimary,
                            shape: BoxShape.circle,
                          ),
                          alignment: Alignment.center,
                          child: const WBIcon(WBIconName.plus, size: 18),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Upload photo',
                          style: WBTypography.body.copyWith(
                            fontWeight: FontWeight.w500,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Tap to add — at least one shot',
                          style: WBTypography.caption.copyWith(
                            color: WBColors.fgSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: WBSpacing.lg),
                WBInput(
                  label: 'Dish name',
                  placeholder: 'e.g. Jollof rice',
                  controller: _name,
                ),
                const SizedBox(height: WBSpacing.md),
                WBInput(
                  label: 'Description',
                  placeholder: 'Tasty, spicy, fresh…',
                  controller: _desc,
                ),
                const SizedBox(height: WBSpacing.md),
                Row(
                  children: [
                    Expanded(
                      child: WBInput(
                        label: 'Price (₦)',
                        placeholder: '0',
                        controller: _price,
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: GestureDetector(
                        onTap: _pickCategory,
                        behavior: HitTestBehavior.opaque,
                        child: AbsorbPointer(
                          // re-read on every rebuild — `key` forces the
                          // child WBInput to discard its stale text state
                          // when the user picks a new category.
                          child: WBInput(
                            key: ValueKey('cat-$_category'),
                            label: 'Category',
                            initialValue: _category,
                            trailing: const WBIcon(
                              WBIconName.chevronDown,
                              size: 14,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: WBSpacing.lg),
                Text(
                  'PREP TIME · ${_prep.toInt()} min',
                  style: WBTypography.label.copyWith(
                    fontWeight: FontWeight.w600,
                    color: WBColors.fgPlaceholder,
                    letterSpacing: 0.66,
                  ),
                ),
                SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    activeTrackColor: WBColors.surfaceDark,
                    inactiveTrackColor: WBColors.bgDivider,
                    thumbColor: WBColors.surfaceDark,
                    overlayColor:
                        WBColors.surfaceDark.withValues(alpha: 0.1),
                    trackHeight: 3,
                  ),
                  child: Slider(
                    value: _prep,
                    min: 5,
                    max: 60,
                    divisions: 11,
                    onChanged: (v) => setState(() => _prep = v),
                  ),
                ),

                const SizedBox(height: WBSpacing.md),
                WBCard(
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Available',
                              style: WBTypography.body.copyWith(
                                fontWeight: FontWeight.w500,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Toggle off to hide this dish from customers.',
                              style: WBTypography.caption.copyWith(
                                color: WBColors.fgSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Switch.adaptive(
                        value: _available,
                        activeThumbColor: WBColors.surfaceDark,
                        onChanged: (v) => setState(() => _available = v),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: WBSpacing.lg),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Modifiers',
                            style: WBTypography.cardTitle
                                .copyWith(fontSize: 16),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Sizes, spice levels, add-ons — anything customers should choose.',
                            style: WBTypography.caption.copyWith(
                              color: WBColors.fgSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    WBButton(
                      label: 'Add group',
                      size: WBButtonSize.sm,
                      variant: WBButtonVariant.secondary,
                      trailingIcon: WBIconName.plus,
                      onPressed: _addGroup,
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                if (_groups.isEmpty)
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: WBColors.bgSoft,
                      borderRadius: BorderRadius.circular(WBRadius.card),
                    ),
                    child: Text(
                      'No modifiers yet. Tap "Add group" to give customers options like spice level or add-ons.',
                      style: WBTypography.caption.copyWith(
                        color: WBColors.fgSecondary,
                        height: 1.45,
                      ),
                    ),
                  )
                else
                  for (var i = 0; i < _groups.length; i++)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: _ModifierGroupEditor(
                        group: _groups[i],
                        onChanged: () => setState(() {}),
                        onAddOption: () => _addOption(i),
                        onRemoveOption: (o) => _removeOption(i, o),
                        onDelete: () => _removeGroup(i),
                      ),
                    ),
              ],
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    WBSpacing.screenPadding,
                    0,
                    WBSpacing.screenPadding,
                    20,
                  ),
                  child: WBButton(
                    label: _isEdit ? 'Save changes' : 'Save dish',
                    fullWidth: true,
                    size: WBButtonSize.lg,
                    onPressed: _save,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ModifierGroupEditor extends StatelessWidget {
  const _ModifierGroupEditor({
    required this.group,
    required this.onChanged,
    required this.onAddOption,
    required this.onRemoveOption,
    required this.onDelete,
  });
  final _EditableGroup group;
  final VoidCallback onChanged;
  final VoidCallback onAddOption;
  final ValueChanged<int> onRemoveOption;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return WBCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: WBInput(
                  label: 'Group name',
                  initialValue: group.name,
                  onChanged: (v) {
                    group.name = v;
                    onChanged();
                  },
                ),
              ),
              const SizedBox(width: 10),
              GestureDetector(
                onTap: onDelete,
                behavior: HitTestBehavior.opaque,
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: const Color(0x14EF4444),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  alignment: Alignment.center,
                  child: const WBIcon(
                    WBIconName.close,
                    size: 14,
                    color: WBColors.statusError,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Text(
                'Required',
                style: WBTypography.caption.copyWith(
                  color: WBColors.fgSecondary,
                ),
              ),
              const Spacer(),
              Switch.adaptive(
                value: group.required,
                activeThumbColor: WBColors.surfaceDark,
                onChanged: (v) {
                  group.required = v;
                  onChanged();
                },
              ),
            ],
          ),
          const SizedBox(height: 8),
          for (var i = 0; i < group.options.length; i++) ...[
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Expanded(
                    flex: 5,
                    child: WBInput(
                      placeholder: 'Option label',
                      initialValue: group.options[i].label,
                      onChanged: (v) => group.options[i].label = v,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    flex: 3,
                    child: WBInput(
                      placeholder: '+₦0',
                      initialValue: group.options[i].priceDeltaNaira == 0
                          ? ''
                          : '${group.options[i].priceDeltaNaira}',
                      keyboardType: TextInputType.number,
                      onChanged: (v) {
                        group.options[i].priceDeltaNaira =
                            int.tryParse(v.replaceAll(',', '')) ?? 0;
                      },
                    ),
                  ),
                  GestureDetector(
                    onTap: () => onRemoveOption(i),
                    behavior: HitTestBehavior.opaque,
                    child: Container(
                      width: 40,
                      height: 40,
                      alignment: Alignment.center,
                      child: const WBIcon(
                        WBIconName.close,
                        size: 14,
                        color: WBColors.fgPlaceholder,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          GestureDetector(
            onTap: onAddOption,
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                children: [
                  const WBIcon(WBIconName.plus, size: 14),
                  const SizedBox(width: 6),
                  Text(
                    'Add option',
                    style: WBTypography.caption.copyWith(
                      fontWeight: FontWeight.w600,
                      color: WBColors.fgHeader,
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

/// Mutable editor projection of a [ModifierGroup]. Kept inside the screen
/// because no other screen edits modifier groups directly.
class _EditableGroup {
  _EditableGroup({
    required this.name,
    required this.required,
    required this.options,
  });

  factory _EditableGroup.fromGroup(ModifierGroup g) => _EditableGroup(
        name: g.name,
        required: g.required,
        options: [
          for (final o in g.options)
            _EditableOption(label: o.label, priceDeltaNaira: o.priceDeltaNaira),
        ],
      );

  String name;
  bool required;
  List<_EditableOption> options;

  ModifierGroup toGroup() => ModifierGroup(
        name: name.trim().isEmpty ? 'Options' : name.trim(),
        required: required,
        options: [
          for (final o in options)
            if (o.label.trim().isNotEmpty)
              ModifierOption(
                label: o.label.trim(),
                priceDeltaNaira: o.priceDeltaNaira,
              ),
        ],
      );
}

class _EditableOption {
  _EditableOption({required this.label, required this.priceDeltaNaira});
  String label;
  int priceDeltaNaira;
}
