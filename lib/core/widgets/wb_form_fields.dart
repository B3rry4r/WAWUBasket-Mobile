import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../network/country_api.dart';
import '../theme/wb_theme_exports.dart';
import 'wb_icon.dart';
import 'wb_input.dart';

const _months = [
  'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
  'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
];

String wbFormatDate(DateTime d) => '${d.day} ${_months[d.month - 1]} ${d.year}';

/// A read-only [WBInput] that opens the native date picker on tap. Use for
/// every date field (DOB, harvest date, batch date) instead of free text.
class WBDateField extends StatelessWidget {
  const WBDateField({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
    this.firstDate,
    this.lastDate,
    this.placeholder = 'Select a date',
    this.icon = WBIconName.clock,
  });

  final String label;
  final DateTime? value;
  final ValueChanged<DateTime> onChanged;
  final DateTime? firstDate;
  final DateTime? lastDate;
  final String placeholder;
  final WBIconName icon;

  Future<void> _pick(BuildContext context) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: value ?? now,
      firstDate: firstDate ?? DateTime(now.year - 100),
      lastDate: lastDate ?? DateTime(now.year + 5),
    );
    if (picked != null) onChanged(picked);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _pick(context),
      behavior: HitTestBehavior.opaque,
      child: AbsorbPointer(
        child: WBInput(
          key: ValueKey('$label-${value?.toIso8601String() ?? ''}'),
          label: label,
          leadingIcon: icon,
          initialValue: value == null ? '' : wbFormatDate(value!),
          placeholder: placeholder,
          trailing: const WBIcon(WBIconName.chevronDown, size: 14),
        ),
      ),
    );
  }
}

/// A read-only [WBInput] that opens a bottom-sheet option list on tap.
/// Use for every fixed-choice field — country code, state, business type,
/// vehicle type — instead of a free-text input.
class WBPickerField<T> extends StatelessWidget {
  const WBPickerField({
    super.key,
    required this.label,
    required this.value,
    required this.options,
    required this.display,
    required this.onSelected,
    this.placeholder = 'Select',
    this.icon,
    this.sheetTitle,
  });

  final String label;
  final T? value;
  final List<T> options;
  final String Function(T) display;
  final ValueChanged<T> onSelected;
  final String placeholder;
  final WBIconName? icon;
  final String? sheetTitle;

  void _openSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: WBColors.bgPrimary,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius:
            BorderRadius.vertical(top: Radius.circular(WBRadius.sheet)),
      ),
      builder: (sheetCtx) => SafeArea(
        child: Padding(
          padding: EdgeInsets.only(
            left: WBSpacing.screenPadding,
            right: WBSpacing.screenPadding,
            top: WBSpacing.lg,
            bottom: WBSpacing.lg,
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
                sheetTitle ?? label,
                style: WBTypography.cardTitle.copyWith(fontSize: 18),
              ),
              const SizedBox(height: WBSpacing.sm),
              Flexible(
                child: ListView(
                  shrinkWrap: true,
                  children: [
                    for (final option in options)
                      GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () {
                          onSelected(option);
                          Navigator.of(sheetCtx).pop();
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 13),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  display(option),
                                  style: WBTypography.body.copyWith(
                                    fontWeight: FontWeight.w500,
                                    fontSize: 15,
                                  ),
                                ),
                              ),
                              if (value != null &&
                                  display(option) ==
                                      display(value as T))
                                const WBIcon(WBIconName.check, size: 16),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _openSheet(context),
      behavior: HitTestBehavior.opaque,
      child: AbsorbPointer(
        child: WBInput(
          key: ValueKey('$label-${value == null ? '' : display(value as T)}'),
          label: label,
          leadingIcon: icon,
          initialValue: value == null ? '' : display(value as T),
          placeholder: placeholder,
          trailing: const WBIcon(WBIconName.chevronDown, size: 14),
        ),
      ),
    );
  }
}

/// Phone-number field with a country-code picker. The country list comes
/// from [CountryApi] (restcountries.com) — never hard-coded. The number
/// box is digit-only and length-capped. [onCountryChanged] hands the
/// parent the selected dial code so it can build the E.164 number.
class WBPhoneField extends StatefulWidget {
  const WBPhoneField({
    super.key,
    required this.controller,
    required this.onCountryChanged,
    this.label = 'Phone number',
  });

  final TextEditingController controller;
  final ValueChanged<Country> onCountryChanged;
  final String label;

  @override
  State<WBPhoneField> createState() => _WBPhoneFieldState();
}

class _WBPhoneFieldState extends State<WBPhoneField> {
  List<Country> _countries = const [];
  Country? _selected;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final list = await CountryApi.instance.all();
      if (!mounted) return;
      final preferred = CountryApi.instance.byIso(list, 'NG') ??
          (list.isNotEmpty ? list.first : null);
      setState(() {
        _countries = list;
        _selected = preferred;
        _loading = false;
      });
      if (preferred != null) widget.onCountryChanged(preferred);
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _openPicker() async {
    if (_countries.isEmpty) return;
    final picked = await showModalBottomSheet<Country>(
      context: context,
      backgroundColor: WBColors.bgPrimary,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius:
            BorderRadius.vertical(top: Radius.circular(WBRadius.sheet)),
      ),
      builder: (_) => _CountryPickerSheet(countries: _countries),
    );
    if (picked != null && mounted) {
      setState(() => _selected = picked);
      widget.onCountryChanged(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: WBTypography.caption.copyWith(
            color: WBColors.fgSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          height: 52,
          padding: const EdgeInsets.only(left: 6, right: 18),
          decoration: BoxDecoration(
            color: WBColors.bgPrimary,
            border: Border.all(color: WBColors.borderFilled, width: 1),
            borderRadius: BorderRadius.circular(WBRadius.input),
          ),
          child: Row(
            children: [
              GestureDetector(
                onTap: _openPicker,
                behavior: HitTestBehavior.opaque,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: WBColors.bgSoft,
                    borderRadius: BorderRadius.circular(WBRadius.pill),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (_loading)
                        const SizedBox(
                          width: 12,
                          height: 12,
                          child:
                              CircularProgressIndicator(strokeWidth: 1.8),
                        )
                      else
                        Text(
                          _selected?.compactLabel ?? '+—',
                          style: WBTypography.caption.copyWith(
                            color: WBColors.fgHeader,
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                      const SizedBox(width: 4),
                      const WBIcon(WBIconName.chevronDown,
                          size: 12, color: WBColors.fgSecondary),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: TextField(
                  controller: widget.controller,
                  keyboardType: TextInputType.phone,
                  maxLength: 11,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly
                  ],
                  buildCounter: (_,
                          {required currentLength,
                          required isFocused,
                          maxLength}) =>
                      null,
                  cursorColor: WBColors.fgHeader,
                  style:
                      WBTypography.body.copyWith(color: WBColors.fgHeader),
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    isCollapsed: true,
                    contentPadding:
                        const EdgeInsets.symmetric(vertical: 14),
                    hintText: '803 000 0000',
                    hintStyle: WBTypography.body
                        .copyWith(color: WBColors.fgPlaceholder),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Searchable country list for [WBPhoneField].
class _CountryPickerSheet extends StatefulWidget {
  const _CountryPickerSheet({required this.countries});
  final List<Country> countries;

  @override
  State<_CountryPickerSheet> createState() => _CountryPickerSheetState();
}

class _CountryPickerSheetState extends State<_CountryPickerSheet> {
  String _q = '';

  @override
  Widget build(BuildContext context) {
    final q = _q.trim().toLowerCase();
    final filtered = q.isEmpty
        ? widget.countries
        : widget.countries
            .where((c) =>
                c.name.toLowerCase().contains(q) ||
                c.dialCode.contains(q))
            .toList();
    return Padding(
      padding: EdgeInsets.only(
        left: WBSpacing.screenPadding,
        right: WBSpacing.screenPadding,
        top: WBSpacing.lg,
        bottom: MediaQuery.of(context).viewInsets.bottom + WBSpacing.lg,
      ),
      child: SizedBox(
        height: MediaQuery.of(context).size.height * 0.7,
        child: Column(
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
            WBInput(
              placeholder: 'Search country',
              leadingIcon: WBIconName.search,
              autofocus: true,
              onChanged: (v) => setState(() => _q = v),
            ),
            const SizedBox(height: WBSpacing.sm),
            Expanded(
              child: ListView.builder(
                itemCount: filtered.length,
                itemBuilder: (_, i) => GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => Navigator.of(context).pop(filtered[i]),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            '${filtered[i].flag}  ${filtered[i].name}',
                            style:
                                WBTypography.body.copyWith(fontSize: 15),
                          ),
                        ),
                        Text(
                          filtered[i].dialCode,
                          style: WBTypography.caption.copyWith(
                            color: WBColors.fgSecondary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
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

/// Address-country picker. Shows flag + name in a searchable bottom sheet
/// backed by [CountryApi] (restcountries.com). Returns the country name.
class WBCountryField extends StatefulWidget {
  const WBCountryField({
    super.key,
    required this.onChanged,
    this.value,
    this.label = 'Country',
  });

  final ValueChanged<String> onChanged;
  final String? value;
  final String label;

  @override
  State<WBCountryField> createState() => _WBCountryFieldState();
}

class _WBCountryFieldState extends State<WBCountryField> {
  List<Country> _countries = const [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final list = await CountryApi.instance.all();
      if (mounted) setState(() { _countries = list; _loading = false; });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _open() async {
    if (_countries.isEmpty) return;
    final picked = await showModalBottomSheet<Country>(
      context: context,
      backgroundColor: WBColors.bgPrimary,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(WBRadius.sheet)),
      ),
      builder: (_) => _CountryPickerSheet(countries: _countries),
    );
    if (picked != null && mounted) widget.onChanged(picked.name);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _loading ? null : _open,
      behavior: HitTestBehavior.opaque,
      child: Container(
        height: 52,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: WBColors.surfaceInput,
          borderRadius: BorderRadius.circular(WBRadius.pill),
        ),
        child: Row(
          children: [
            if (_loading)
              const SizedBox(
                width: 14, height: 14,
                child: CircularProgressIndicator(
                  strokeWidth: 1.5,
                  valueColor: AlwaysStoppedAnimation(WBColors.fgPlaceholder),
                ),
              )
            else
              Expanded(
                child: Text(
                  widget.value ?? widget.label,
                  style: WBTypography.body.copyWith(
                    color: widget.value != null
                        ? WBColors.fgHeader
                        : WBColors.fgPlaceholder,
                    fontSize: 15,
                  ),
                ),
              ),
            if (!_loading) ...[
              const SizedBox(width: 8),
              const WBIcon(WBIconName.chevronDown, size: 14,
                  color: WBColors.fgPlaceholder),
            ],
          ],
        ),
      ),
    );
  }
}
