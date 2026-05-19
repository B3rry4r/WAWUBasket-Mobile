import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/wb_theme_exports.dart';
import '../../../../core/widgets/wb_widgets.dart';

class LanguageScreen extends StatefulWidget {
  const LanguageScreen({super.key});

  @override
  State<LanguageScreen> createState() => _LanguageScreenState();
}

class _LanguageScreenState extends State<LanguageScreen> {
  String _selected = 'english';

  static const _languages = [
    (id: 'english', label: 'English', sub: 'Default'),
    (id: 'pidgin', label: 'Pidgin', sub: 'Naija'),
    (id: 'yoruba', label: 'Yorùbá', sub: 'Èdè Yorùbá'),
    (id: 'igbo', label: 'Igbo', sub: 'Asụsụ Igbo'),
    (id: 'hausa', label: 'Hausa', sub: 'Harshen Hausa'),
    (id: 'french', label: 'French', sub: 'Français'),
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
                Text('Language', style: WBTypography.page),
              ],
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
                      onTap: () =>
                          setState(() => _selected = _languages[i].id),
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
