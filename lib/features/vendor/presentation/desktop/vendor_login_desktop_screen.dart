import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/network/api_exception.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/services/notification_service.dart';
import '../../../../core/theme/wb_theme_exports.dart';
import '../../../../core/utils/wb_actions.dart';
import '../../../../core/utils/wb_l10n.dart';
import '../../../../core/widgets/wb_widgets.dart';
import '../../../auth/application/role_controller.dart';
import '../../../auth/data/auth_api.dart';

/// Desktop-web layout for the vendor login screen. Isolated from the mobile
/// build: it reuses the exact controllers, API calls, error handling and
/// navigation that [VendorLoginScreen] (mobile) uses, re-laid-out as a calm
/// centered pre-auth column for wide windows.
class VendorLoginDesktopScreen extends StatefulWidget {
  const VendorLoginDesktopScreen({super.key});

  @override
  State<VendorLoginDesktopScreen> createState() =>
      _VendorLoginDesktopScreenState();
}

class _VendorLoginDesktopScreenState extends State<VendorLoginDesktopScreen> {
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
      await AuthApi.instance.switchRole('vendor');
      RoleController.instance.setRole(AppRole.vendor);
      NotificationService.instance.registerToken();
      if (!mounted) return;
      context.go(AppRoutes.vendorHome);
    } on ApiException catch (e) {
      if (mounted) wbShowError(context, e.message);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: WBColors.bgPrimary,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: WBSpacing.screenPadding,
              vertical: WBSpacing.xxl,
            ),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const WBWMark(size: 32),
                  const SizedBox(height: WBSpacing.xxl),
                  WBBackChip(onPressed: () => context.go(AppRoutes.welcome)),
                  const SizedBox(height: WBSpacing.xl),
                  Text('Welcome back, vendor', style: WBTypography.hero),
                  const SizedBox(height: WBSpacing.sm),
                  Text(
                    'Your customers are waiting.',
                    style: WBTypography.body.copyWith(
                      color: WBColors.fgSecondary,
                    ),
                  ),
                  const SizedBox(height: WBSpacing.xl),
                  WBInput(
                    label: 'Business email',
                    controller: _identifier,
                    leadingIcon: WBIconName.user,
                  ),
                  const SizedBox(height: WBSpacing.md),
                  WBInput(
                    label: context.l10n.loginPasswordLabel,
                    controller: _password,
                    leadingIcon: WBIconName.card,
                    obscureText: _obscure,
                    trailing: TextButton(
                      onPressed: () => setState(() => _obscure = !_obscure),
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: const Size(40, 24),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: Text(
                        _obscure ? 'Show' : 'Hide',
                        style: WBTypography.caption.copyWith(
                          color: WBColors.fgSecondary,
                          fontWeight: FontWeight.w500,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: WBSpacing.sm),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () => context.push(AppRoutes.forgotPassword),
                      style: TextButton.styleFrom(padding: EdgeInsets.zero),
                      child: Text(
                        context.l10n.loginForgotPassword,
                        style: WBTypography.caption.copyWith(
                          color: WBColors.fgHeader,
                          fontWeight: FontWeight.w500,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: WBSpacing.xl),
                  WBButton(
                    label: context.l10n.signIn,
                    size: WBButtonSize.lg,
                    fullWidth: true,
                    trailingIcon: WBIconName.arrowRight,
                    loading: _busy,
                    onPressed: _submit,
                  ),
                  const SizedBox(height: WBSpacing.md),
                  Center(
                    child: GestureDetector(
                      onTap: () => context.push(AppRoutes.vendorKyc),
                      child: RichText(
                        text: TextSpan(
                          style: WBTypography.secondary,
                          children: const [
                            TextSpan(text: 'New to WAWU? '),
                            TextSpan(
                              text: 'List your business',
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
        ),
      ),
    );
  }
}
