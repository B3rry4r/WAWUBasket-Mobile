import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/network/api_exception.dart';
import '../../../../core/responsive/wb_responsive_exports.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/services/notification_service.dart';
import '../../../../core/theme/wb_theme_exports.dart';
import '../../../../core/utils/wb_actions.dart';
import '../../../../core/utils/wb_l10n.dart';
import '../../../../core/widgets/wb_widgets.dart';
import '../../../auth/application/role_controller.dart';
import '../../../auth/data/auth_api.dart';

/// Desktop-web layout for the trader login screen. Isolated from the mobile
/// build: it reuses the exact controllers, API calls, error handling and
/// navigation that [TraderLoginScreen] (mobile) uses, re-laid-out as a split
/// brand / form panel for wide windows.
class TraderLoginDesktopScreen extends StatefulWidget {
  const TraderLoginDesktopScreen({super.key});

  @override
  State<TraderLoginDesktopScreen> createState() =>
      _TraderLoginDesktopScreenState();
}

class _TraderLoginDesktopScreenState extends State<TraderLoginDesktopScreen> {
  final _identifier = TextEditingController();
  final _password = TextEditingController();
  bool _obscure = true;
  bool _busy = false;

  @override
  void dispose() {
    _identifier.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_identifier.text.trim().isEmpty || _password.text.isEmpty) {
      wbShowSnack(context, context.l10n.loginErrorEmpty);
      return;
    }
    setState(() => _busy = true);
    try {
      await AuthApi.instance.login(_identifier.text.trim(), _password.text);
      await AuthApi.instance.switchRole('trader');
      RoleController.instance.setRole(AppRole.trader);
      NotificationService.instance.registerToken();
      if (!mounted) return;
      context.go(AppRoutes.traderHome);
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
      body: LayoutBuilder(
        builder: (context, constraints) {
          // Hide the brand panel below ~1100px so the form never feels cramped.
          final showBrand = constraints.maxWidth >= 1100;
          return Row(
            children: [
              if (showBrand) const Expanded(child: _BrandPanel()),
              SizedBox(
                width: 520,
                child: _FormPanel(
                  identifier: _identifier,
                  password: _password,
                  obscure: _obscure,
                  busy: _busy,
                  onToggleObscure: () => setState(() => _obscure = !_obscure),
                  onSubmit: _submit,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

/// Left brand panel: dark surface, white wordmark, calm tagline. Desktop-only.
class _BrandPanel extends StatelessWidget {
  const _BrandPanel();

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: WBColors.surfaceDark,
      child: Padding(
        padding: const EdgeInsets.all(WBSpacing.xxl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const WBWordmark(height: 40, color: WBColors.bgPrimary),
            const SizedBox(height: WBSpacing.lg),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 380),
              child: Text(
                'Bulk listings, corridor prices, ready buyers.',
                style: WBTypography.hero.copyWith(
                  color: WBColors.bgPrimary,
                  height: 1.2,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Right form panel: the real trader login content, vertically centered in a
/// capped reading column with a top-left back chip where the mobile screen
/// had one.
class _FormPanel extends StatelessWidget {
  const _FormPanel({
    required this.identifier,
    required this.password,
    required this.obscure,
    required this.busy,
    required this.onToggleObscure,
    required this.onSubmit,
  });

  final TextEditingController identifier;
  final TextEditingController password;
  final bool obscure;
  final bool busy;
  final VoidCallback onToggleObscure;
  final Future<void> Function() onSubmit;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(
          horizontal: WBSpacing.screenPadding,
          vertical: WBSpacing.xxl,
        ),
        child: WBMaxWidth(
          maxWidth: WBBreakpoints.maxReading,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              WBBackChip(onPressed: () => context.go(AppRoutes.welcome)),
              const SizedBox(height: WBSpacing.xl),
              Text('Trader access', style: WBTypography.hero),
              const SizedBox(height: WBSpacing.sm),
              Text(
                'Bulk listings, corridor prices, ready buyers.',
                style: WBTypography.body.copyWith(color: WBColors.fgSecondary),
              ),
              const SizedBox(height: WBSpacing.xl),
              WBInput(
                label: 'Business email',
                controller: identifier,
                leadingIcon: WBIconName.user,
              ),
              const SizedBox(height: WBSpacing.md),
              WBInput(
                label: 'Password',
                controller: password,
                leadingIcon: WBIconName.card,
                obscureText: obscure,
                trailing: TextButton(
                  onPressed: onToggleObscure,
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: const Size(40, 24),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Text(
                    obscure ? 'Show' : 'Hide',
                    style: WBTypography.caption.copyWith(
                      color: WBColors.fgSecondary,
                      fontWeight: FontWeight.w500,
                      fontSize: 13,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: WBSpacing.xl),
              WBButton(
                label: 'Sign in to dashboard',
                size: WBButtonSize.lg,
                fullWidth: true,
                trailingIcon: WBIconName.arrowRight,
                loading: busy,
                onPressed: onSubmit,
              ),
              const SizedBox(height: WBSpacing.md),
              Center(
                child: GestureDetector(
                  onTap: () => context.push(AppRoutes.traderKyc),
                  child: RichText(
                    text: TextSpan(
                      style: WBTypography.secondary,
                      children: const [
                        TextSpan(text: 'New trader? '),
                        TextSpan(
                          text: 'Apply to list bulk goods',
                          style: TextStyle(
                            color: WBColors.fgHeader,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
