import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/wb_theme_exports.dart';
import '../../../../core/widgets/wb_widgets.dart';
import '../../application/terms_acceptance.dart';

/// One-time EULA / Terms acceptance gate shown before the user can reach
/// login or signup (App Review Guideline 1.2 — UGC apps must present terms
/// before registering OR logging in).
///
/// [TermsGate] wraps the real auth screen: while
/// [TermsAcceptance.isAccepted] is false it renders the acceptance screen;
/// once accepted (persisted locally) it renders [child] directly, so the
/// gate is shown only once per install.
class TermsGate extends StatelessWidget {
  const TermsGate({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: TermsAcceptance.instance.accepted,
      builder: (_, accepted, _) {
        if (accepted) return child;
        return const _TermsGateScreen();
      },
    );
  }
}

class _TermsGateScreen extends StatefulWidget {
  const _TermsGateScreen();

  @override
  State<_TermsGateScreen> createState() => _TermsGateScreenState();
}

class _TermsGateScreenState extends State<_TermsGateScreen> {
  bool _agreed = false;

  Future<void> _accept() async {
    await TermsAcceptance.instance.accept();
    // The ValueListenableBuilder in [TermsGate] swaps in the real auth
    // screen as soon as the flag flips — no navigation needed.
  }

  /// A tappable, underlined legal link. Tapping opens the in-app document and
  /// does not toggle the agreement checkbox.
  InlineSpan _legalLink(BuildContext context, String label, String route) {
    return WidgetSpan(
      alignment: PlaceholderAlignment.baseline,
      baseline: TextBaseline.alphabetic,
      child: GestureDetector(
        onTap: () => context.push(route),
        child: Text(
          label,
          style: WBTypography.caption.copyWith(
            color: WBColors.fgHeader,
            fontSize: 13,
            height: 1.5,
            fontWeight: FontWeight.w500,
            decoration: TextDecoration.underline,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: WBColors.bgPrimary,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: WBSpacing.screenPadding,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 12),
              const WBBackChip(),
              const Spacer(),
              const WBWMark(size: 52),
              const SizedBox(height: WBSpacing.lg),
              // TODO(i18n): key=termsGateTitle / termsGateBody
              Text('Before you continue', style: WBTypography.hero),
              const SizedBox(height: WBSpacing.sm),
              Text(
                'WAWUBasket includes chats, listings, reviews and other '
                'content from people across the community. To keep everyone '
                'safe, please review and accept our terms before signing in '
                'or creating an account.',
                style: WBTypography.body.copyWith(
                  color: WBColors.fgSecondary,
                  fontSize: 15,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: WBSpacing.lg),
              Container(
                padding: const EdgeInsets.all(WBSpacing.md),
                decoration: BoxDecoration(
                  color: WBColors.bgSecondary,
                  borderRadius: BorderRadius.circular(WBRadius.card),
                ),
                child: Text(
                  'There is zero tolerance for objectionable content or '
                  'abusive behaviour. You can report content and block users '
                  'at any time from within the app.',
                  style: WBTypography.caption.copyWith(
                    color: WBColors.fgSecondary,
                    height: 1.5,
                  ),
                ),
              ),
              const SizedBox(height: WBSpacing.lg),
              GestureDetector(
                onTap: () => setState(() => _agreed = !_agreed),
                behavior: HitTestBehavior.opaque,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 20,
                      height: 20,
                      margin: const EdgeInsets.only(top: 2),
                      decoration: BoxDecoration(
                        color:
                            _agreed ? WBColors.surfaceDark : Colors.transparent,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color:
                              _agreed ? WBColors.surfaceDark : WBColors.bgDivider,
                          width: 1.5,
                        ),
                      ),
                      child: _agreed
                          ? const WBIcon(
                              WBIconName.check,
                              size: 12,
                              color: Colors.white,
                              strokeWidth: 2.5,
                            )
                          : null,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: RichText(
                        text: TextSpan(
                          style: WBTypography.caption.copyWith(
                            color: WBColors.fgSecondary,
                            fontSize: 13,
                            height: 1.5,
                          ),
                          children: [
                            const TextSpan(
                              text: 'I have read and agree to the ',
                            ),
                            _legalLink(context, 'Terms of Use',
                                AppRoutes.terms),
                            const TextSpan(text: ' and '),
                            _legalLink(
                                context, 'Privacy Policy', AppRoutes.privacy),
                            const TextSpan(text: '.'),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: WBSpacing.lg),
              WBButton(
                // TODO(i18n): key=termsGateAccept
                label: 'Agree & continue',
                size: WBButtonSize.lg,
                fullWidth: true,
                trailingIcon: WBIconName.arrowRight,
                disabled: !_agreed,
                onPressed: _agreed ? _accept : null,
              ),
              const Spacer(),
              const SizedBox(height: WBSpacing.lg),
            ],
          ),
        ),
      ),
    );
  }
}
