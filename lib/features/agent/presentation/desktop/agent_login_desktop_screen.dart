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

/// Desktop-web layout for the agent login screen. Isolated from the mobile
/// build: it reuses the exact controllers, API calls, error handling and
/// navigation that [AgentLoginScreen] (mobile) uses, re-laid-out as a calm
/// centered pre-auth column for wide windows.
class AgentLoginDesktopScreen extends StatefulWidget {
  const AgentLoginDesktopScreen({super.key});

  @override
  State<AgentLoginDesktopScreen> createState() =>
      _AgentLoginDesktopScreenState();
}

class _AgentLoginDesktopScreenState extends State<AgentLoginDesktopScreen> {
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
      await AuthApi.instance.switchRole('agent');
      RoleController.instance.setRole(AppRole.agent);
      NotificationService.instance.registerToken();
      if (!mounted) return;
      context.go(AppRoutes.agentHome);
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
                  Text('Agent access', style: WBTypography.hero),
                  const SizedBox(height: WBSpacing.sm),
                  Text(
                    'Your traders are waiting.',
                    style: WBTypography.body.copyWith(
                      color: WBColors.fgSecondary,
                    ),
                  ),
                  const SizedBox(height: WBSpacing.xl),
                  WBInput(
                    label: 'Phone or email',
                    controller: _identifier,
                    leadingIcon: WBIconName.user,
                  ),
                  const SizedBox(height: WBSpacing.md),
                  WBInput(
                    label: 'Password',
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
                      onTap: () => context.push(AppRoutes.agentKyc),
                      child: RichText(
                        text: TextSpan(
                          style: WBTypography.secondary,
                          children: const [
                            TextSpan(text: 'New here? '),
                            TextSpan(
                              text: 'Apply to be an agent',
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
