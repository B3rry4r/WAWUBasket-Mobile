import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/network/api_exception.dart';
import '../../../../core/responsive/wb_responsive_exports.dart';
import '../../../../core/theme/wb_theme_exports.dart';
import '../../../../core/utils/wb_actions.dart';
import '../../../../core/utils/wb_l10n.dart';
import '../../../../core/widgets/wb_widgets.dart';
import '../../../shell/presentation/desktop/customer_web_scaffold.dart';
import '../../data/profile_api.dart';

/// Desktop-web layout for [DietaryPreferencesScreen]. Same controllers, l10n
/// keys, options, toggling and save behaviour as the mobile screen — only the
/// layout is re-flowed into a centered settings column inside the customer web
/// chrome. Desktop-only; the mobile build never imports this.
class DietaryPreferencesDesktopScreen extends StatefulWidget {
  const DietaryPreferencesDesktopScreen({super.key});

  @override
  State<DietaryPreferencesDesktopScreen> createState() =>
      _DietaryPreferencesDesktopScreenState();
}

class _DietaryPreferencesDesktopScreenState
    extends State<DietaryPreferencesDesktopScreen> {
  final Set<String> _selected = {};
  final _custom = TextEditingController();
  bool _loading = true;
  bool _saving = false;

  List<String> _options(BuildContext context) => [
    context.l10n.dietaryNoBeef,
    context.l10n.dietaryNoPork,
    context.l10n.dietaryNoShellfish,
    context.l10n.dietaryHalal,
    context.l10n.dietaryVegetarian,
    context.l10n.dietaryVegan,
    context.l10n.dietaryNoDairy,
    context.l10n.dietaryNoNuts,
    context.l10n.dietaryLowSugar,
  ];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final prefs = await ProfileApi.instance.getDietaryPreferences();
      if (mounted) {
        setState(() {
          _selected.addAll(prefs);
          _loading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      final all = List<String>.from(_selected);
      final custom = _custom.text.trim();
      if (custom.isNotEmpty) all.add(custom);
      await ProfileApi.instance.saveDietaryPreferences(all);
      if (mounted) {
        wbShowSnack(context, context.l10n.dietarySaved);
        context.pop();
      }
    } on ApiException catch (e) {
      if (mounted) wbShowError(context, e.message);
    } catch (_) {
      // An unexpected (non-API) error is a failure — surface it instead of
      // falsely reporting success and dismissing the screen.
      if (mounted) {
        wbShowSnack(context, 'Could not save your preferences. Please try again.');
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  void dispose() {
    _custom.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CustomerWebScaffold(
      child: WBMaxWidth(
        maxWidth: 640,
        padding: const EdgeInsets.fromLTRB(
          WBSpacing.screenPadding,
          WBSpacing.xl,
          WBSpacing.screenPadding,
          WBSpacing.xl,
        ),
        child: ListView(
          children: [
            WBBackChip(onPressed: () => context.pop()),
            const SizedBox(height: 14),
            Text(context.l10n.dietaryTitle, style: WBTypography.page),
            Text(
              context.l10n.dietarySubtitle,
              style: WBTypography.caption.copyWith(
                color: WBColors.fgSecondary,
              ),
            ),
            const SizedBox(height: WBSpacing.lg),
            if (_loading)
              const Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 32),
                  child: SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.4,
                      valueColor: AlwaysStoppedAnimation(WBColors.surfaceDark),
                    ),
                  ),
                ),
              )
            else ...[
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final o in _options(context))
                    WBTag(
                      label: o,
                      active: _selected.contains(o),
                      onTap: () => setState(() {
                        _selected.contains(o)
                            ? _selected.remove(o)
                            : _selected.add(o);
                      }),
                    ),
                ],
              ),
              const SizedBox(height: WBSpacing.lg),
              Text(
                context.l10n.dietaryAnythingElse,
                style: WBTypography.cardTitle.copyWith(fontSize: 16),
              ),
              const SizedBox(height: 10),
              WBInput(
                controller: _custom,
                placeholder: context.l10n.dietaryCustomPlaceholder,
              ),
              const SizedBox(height: WBSpacing.xl),
              WBButton(
                label: context.l10n.dietarySave,
                fullWidth: true,
                size: WBButtonSize.lg,
                loading: _saving,
                onPressed: _save,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
