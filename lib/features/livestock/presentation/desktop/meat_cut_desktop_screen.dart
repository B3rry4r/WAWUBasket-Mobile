import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/network/api_exception.dart';
import '../../../../core/responsive/wb_responsive_exports.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/wb_theme_exports.dart';
import '../../../../core/utils/wb_actions.dart';
import '../../../../core/utils/wb_l10n.dart';
import '../../../../core/widgets/wb_widgets.dart';
import '../../../shell/presentation/desktop/customer_web_scaffold.dart';
import '../../../shopping/data/catalog_api.dart';
import '../../../shopping/domain/models/product.dart';

/// Desktop-web layout for the meat-cut configurator. Re-lays out
/// [MeatCutScreen] for a wide window: a two-column page (product media on the
/// left, butchery options + add-to-basket on the right) inside the shared
/// [CustomerWebScaffold]. The data loading, state, and navigation mirror the
/// mobile screen exactly.
class MeatCutDesktopScreen extends StatefulWidget {
  const MeatCutDesktopScreen({super.key, required this.productId});
  final String productId;

  @override
  State<MeatCutDesktopScreen> createState() => _MeatCutDesktopScreenState();
}

class _MeatCutDesktopScreenState extends State<MeatCutDesktopScreen> {
  String _cut = 'pieces';
  double _weight = 2.0;
  bool _fresh = true;
  bool _removeSkin = false;
  final _instructions = TextEditingController();

  Product? _product;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _error = null);
    try {
      final p = await CatalogApi.instance.item(widget.productId);
      if (mounted) setState(() => _product = p);
    } on ApiException catch (e) {
      if (mounted) setState(() => _error = e.message);
    }
  }

  @override
  void dispose() {
    _instructions.dispose();
    super.dispose();
  }

  static const _cutsByCat = {
    'chicken': [
      ('whole', 'Whole'),
      ('breast', 'Breast'),
      ('thighs', 'Thighs'),
      ('drumsticks', 'Drumsticks'),
      ('wings', 'Wings'),
      ('pieces', '8 pieces'),
    ],
    'beef': [
      ('chunks', 'Chunks'),
      ('strips', 'Strips'),
      ('cubes', 'Cubes'),
      ('mince', 'Minced'),
      ('bone-in', 'Bone-in'),
    ],
    'goat': [
      ('chunks', 'Chunks'),
      ('soup-cut', 'Pepper-soup cut'),
      ('bone-in', 'Bone-in'),
    ],
    'fish': [
      ('whole', 'Whole'),
      ('cleaned', 'Cleaned'),
      ('steaks', 'Steaks'),
      ('fillets', 'Fillets'),
    ],
    'seafood': [
      ('whole', 'As-is'),
      ('peeled', 'Peeled'),
    ],
  };

  @override
  Widget build(BuildContext context) {
    return CustomerWebScaffold(
      child: WBMaxWidth(
        maxWidth: WBBreakpoints.maxContent,
        child: _body(context),
      ),
    );
  }

  Widget _body(BuildContext context) {
    final product = _product;
    if (product == null) {
      return Padding(
        padding: const EdgeInsets.all(WBSpacing.screenPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            WBBackChip(onPressed: () => context.pop()),
            const SizedBox(height: 80),
            Center(
              child: _error != null
                  ? Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _error!,
                          textAlign: TextAlign.center,
                          style: WBTypography.body
                              .copyWith(color: WBColors.fgSecondary),
                        ),
                        const SizedBox(height: 14),
                        WBButton(
                          label: context.l10n.actionRetry,
                          size: WBButtonSize.sm,
                          variant: WBButtonVariant.secondary,
                          onPressed: _load,
                        ),
                      ],
                    )
                  : const SizedBox(
                      width: 28,
                      height: 28,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.6,
                        valueColor:
                            AlwaysStoppedAnimation(WBColors.surfaceDark),
                      ),
                    ),
            ),
          ],
        ),
      );
    }

    final cuts = _cutsByCat[product.subcategoryId] ?? _cutsByCat['chicken']!;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(
        WBSpacing.screenPadding,
        WBSpacing.lg,
        WBSpacing.screenPadding,
        WBSpacing.xl,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          WBBackChip(onPressed: () => context.pop()),
          const SizedBox(height: WBSpacing.lg),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(flex: 5, child: _mediaColumn(product)),
              const SizedBox(width: WBSpacing.xl),
              Expanded(flex: 6, child: _configColumn(context, product, cuts)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _mediaColumn(Product product) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(WBRadius.card),
          child: Stack(
            children: [
              AspectRatio(
                aspectRatio: 16 / 11,
                child: WBNetworkImage(url: product.imageUrl),
              ),
              Positioned(
                top: 12,
                right: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: WBColors.surfaceDark,
                    borderRadius: BorderRadius.circular(WBRadius.pill),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const WBIcon(
                        WBIconName.check,
                        size: 11,
                        color: Colors.white,
                        strokeWidth: 2.5,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'HALAL',
                        style: WBTypography.label.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.66,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: WBSpacing.lg),
        WBCard(
          child: Row(
            children: [
              ClipOval(
                child: SizedBox(
                  width: 44,
                  height: 44,
                  child: WBNetworkImage(url: product.imageUrl),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Butcher John',
                      style: WBTypography.body.copyWith(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '★ 4.9 · 5 min wait',
                      style: WBTypography.caption.copyWith(
                        color: WBColors.fgSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              // Live butcher video isn't wired yet (no vendor WhatsApp/stream
              // number is available), so the control is disabled and clearly
              // labelled rather than firing a fake "Calling…" message.
              WBButton(
                label: context.l10n.commonComingSoon,
                size: WBButtonSize.sm,
                variant: WBButtonVariant.secondary,
                disabled: true,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _configColumn(
    BuildContext context,
    Product product,
    List<(String, String)> cuts,
  ) {
    final total = (product.priceNaira * _weight).round();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          product.name,
          style: WBTypography.hero.copyWith(fontSize: 28),
        ),
        const SizedBox(height: 4),
        Text(
          '${product.formattedPrice}${product.unit ?? ''} · Cut to order',
          style: WBTypography.body.copyWith(
            color: WBColors.fgSecondary,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: WBSpacing.lg),
        _LabelText(label: 'Cut'),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final c in cuts)
              WBTag(
                label: c.$2,
                active: c.$1 == _cut,
                onTap: () => setState(() => _cut = c.$1),
              ),
          ],
        ),
        const SizedBox(height: WBSpacing.lg),
        _LabelText(label: 'Weight'),
        const SizedBox(height: 8),
        Row(
          children: [
            Text(
              '${_weight.toStringAsFixed(1)} kg',
              style: WBTypography.body.copyWith(
                fontWeight: FontWeight.w600,
                fontSize: 18,
              ),
            ),
            const Spacer(),
            Text(
              '0.5 – 10 kg',
              style: WBTypography.caption.copyWith(
                color: WBColors.fgPlaceholder,
              ),
            ),
          ],
        ),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: WBColors.surfaceDark,
            inactiveTrackColor: WBColors.bgDivider,
            thumbColor: WBColors.surfaceDark,
            overlayColor: WBColors.surfaceDark.withValues(alpha: 0.1),
            trackHeight: 3,
          ),
          child: Slider(
            value: _weight,
            min: 0.5,
            max: 10,
            divisions: 19,
            onChanged: (v) => setState(() => _weight = v),
          ),
        ),
        const SizedBox(height: WBSpacing.md),
        _LabelText(label: 'Fresh or frozen'),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _FreshTile(
                label: 'Fresh',
                sub: context.l10n.livestockSameDay,
                active: _fresh,
                onTap: () => setState(() => _fresh = true),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _FreshTile(
                label: 'Frozen',
                sub: context.l10n.livestockVacuumPacked,
                active: !_fresh,
                onTap: () => setState(() => _fresh = false),
              ),
            ),
          ],
        ),
        const SizedBox(height: WBSpacing.lg),
        _LabelText(label: 'Butchery instructions'),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: () => setState(() => _removeSkin = !_removeSkin),
          behavior: HitTestBehavior.opaque,
          child: Row(
            children: [
              Container(
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  color: _removeSkin
                      ? WBColors.surfaceDark
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: _removeSkin
                        ? WBColors.surfaceDark
                        : WBColors.bgDivider,
                    width: 1.5,
                  ),
                ),
                alignment: Alignment.center,
                child: _removeSkin
                    ? const WBIcon(
                        WBIconName.check,
                        size: 13,
                        color: Colors.white,
                        strokeWidth: 2.5,
                      )
                    : null,
              ),
              const SizedBox(width: 10),
              Text(
                'Remove skin',
                style: WBTypography.body.copyWith(fontSize: 14),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
          decoration: BoxDecoration(
            color: WBColors.bgSoft,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: WBColors.borderFilled),
          ),
          child: TextField(
            controller: _instructions,
            maxLines: 2,
            style: WBTypography.body.copyWith(fontSize: 14),
            decoration: InputDecoration(
              isCollapsed: true,
              border: InputBorder.none,
              hintText: 'e.g. Remove feet, cut into 8 pieces, no fat',
              hintStyle: WBTypography.body.copyWith(
                color: WBColors.fgPlaceholder,
                fontSize: 14,
              ),
            ),
          ),
        ),
        const SizedBox(height: WBSpacing.lg),
        WBButton(
          label: 'Add to basket, ₦${_n(total)}',
          fullWidth: true,
          size: WBButtonSize.lg,
          onPressed: () {
            wbShowSnack(context, '${product.name} added to basket');
            context.push(AppRoutes.cart);
          },
        ),
      ],
    );
  }
}

String _n(int v) {
  final s = v.toString();
  final buf = StringBuffer();
  for (var i = 0; i < s.length; i++) {
    if (i != 0 && (s.length - i) % 3 == 0) buf.write(',');
    buf.write(s[i]);
  }
  return buf.toString();
}

class _LabelText extends StatelessWidget {
  const _LabelText({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label.toUpperCase(),
      style: WBTypography.label.copyWith(
        color: WBColors.fgPlaceholder,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.66,
      ),
    );
  }
}

class _FreshTile extends StatelessWidget {
  const _FreshTile({
    required this.label,
    required this.sub,
    required this.active,
    required this.onTap,
  });
  final String label;
  final String sub;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: WBMotion.base,
        curve: WBMotion.easeSoft,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: active ? WBColors.surfaceDark : WBColors.bgSoft,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: WBTypography.body.copyWith(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: active ? Colors.white : WBColors.fgHeader,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              sub,
              style: WBTypography.caption.copyWith(
                color: active
                    ? Colors.white.withValues(alpha: 0.65)
                    : WBColors.fgSecondary,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
