import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/i18n/locale_controller.dart';
import '../../../../core/theme/wb_theme_exports.dart';
import '../../../../core/widgets/wb_widgets.dart';
import '../../../../core/utils/wb_l10n.dart';

class LanguageScreen extends StatefulWidget {
  const LanguageScreen({super.key});

  @override
  State<LanguageScreen> createState() => _LanguageScreenState();
}

class _LanguageScreenState extends State<LanguageScreen> {
  late String _selected =
      LocaleController.instance.locale.value?.languageCode ?? 'en';

  // `id` is the locale code. Pidgin has no translations yet and falls
  // back to English until its ARB lands.
  static const _languages = [
    (id: 'en', label: 'English', sub: 'Default'),
    (id: 'fr', label: 'French', sub: 'Français'),
    (id: 'ar', label: 'Arabic', sub: 'العربية'),
    (id: 'pt', label: 'Portuguese', sub: 'Português'),
    (id: 'sw', label: 'Swahili', sub: 'Kiswahili'),
    (id: 'ha', label: 'Hausa', sub: 'Harshen Hausa'),
    (id: 'yo', label: 'Yorùbá', sub: 'Èdè Yorùbá'),
    (id: 'ig', label: 'Igbo', sub: 'Asụsụ Igbo'),
    (id: 'am', label: 'Amharic', sub: 'አማርኛ'),
    (id: 'zu', label: 'Zulu', sub: 'isiZulu'),
    (id: 'pcm', label: 'Pidgin', sub: 'Naija'),
  ];

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
                Text(
                  context.l10n.languageTitle,
                  style: WBTypography.page,
                ),
              ],
            ),
            const SizedBox(height: WBSpacing.sm),
            Text(
              context.l10n.languageSubtitle,
              style: WBTypography.body.copyWith(
                color: WBColors.fgSecondary,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: WBSpacing.lg),
            Container(
              decoration: BoxDecoration(
                color: WBColors.surfaceCard,
                borderRadius: BorderRadius.circular(WBRadius.card),
                boxShadow: WBShadows.card,
              ),
              clipBehavior: Clip.antiAlias,
              child: Column(
                children: [
                  for (var i = 0; i < _languages.length; i++) ...[
                    GestureDetector(
                      onTap: () {
                        LocaleController.instance
                            .setLocale(_languages[i].id);
                        setState(() => _selected = _languages[i].id);
                      },
                      behavior: HitTestBehavior.opaque,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 16,
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _languages[i].label,
                                    style: WBTypography.body.copyWith(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    _languages[i].sub,
                                    style: WBTypography.caption.copyWith(
                                      color: WBColors.fgSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              width: 22,
                              height: 22,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: _selected == _languages[i].id
                                    ? WBColors.surfaceDark
                                    : Colors.transparent,
                                border: Border.all(
                                  color: _selected == _languages[i].id
                                      ? WBColors.surfaceDark
                                      : WBColors.bgDivider,
                                  width: 1.5,
                                ),
                              ),
                              alignment: Alignment.center,
                              child: _selected == _languages[i].id
                                  ? const WBIcon(
                                      WBIconName.check,
                                      size: 12,
                                      color: Colors.white,
                                      strokeWidth: 2.5,
                                    )
                                  : null,
                            ),
                          ],
                        ),
                      ),
                    ),
                    if (i != _languages.length - 1) const WBDivider(),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
