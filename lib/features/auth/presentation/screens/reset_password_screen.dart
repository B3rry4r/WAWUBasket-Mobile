import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/network/api_exception.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/wb_theme_exports.dart';
import '../../../../core/utils/wb_actions.dart';
import '../../../../core/widgets/wb_widgets.dart';
import '../../application/role_controller.dart';
import '../../data/auth_api.dart';

/// Second half of the password-recovery flow: the user enters the 6-digit
/// code sent to [identifier] plus a new password. On success the API
/// returns a session, so we drop straight into the customer home.
class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key, required this.identifier});

  final String identifier;

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _code = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();
  bool _busy = false;

  @override
  void dispose() {
    _code.dispose();
    _password.dispose();
    _confirm.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_code.text.length != 6) {
      wbShowSnack(context, 'Enter the 6-digit code we sent you.');
      return;
    }
    if (_password.text.length < 8) {
      wbShowSnack(context, 'Password must be at least 8 characters.');
      return;
    }
    if (_password.text != _confirm.text) {
      wbShowSnack(context, "Passwords don't match.");
      return;
    }
    setState(() => _busy = true);
    try {
      await AuthApi.instance.resetPassword(
        widget.identifier,
        _code.text,
        _password.text,
      );
      RoleController.instance.setRole(AppRole.customer);
      if (!mounted) return;
      context.go(AppRoutes.home);
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
              const SizedBox(height: WBSpacing.xl - 4),
              Text('Choose a new\npassword', style: WBTypography.hero),
              const SizedBox(height: WBSpacing.sm + 2),
              Text(
                'Enter the code we sent you, then set a new password.',
                style: WBTypography.body.copyWith(
                  color: WBColors.fgSecondary,
                  fontSize: 15,
                ),
              ),
              const SizedBox(height: WBSpacing.lg + 4),
              WBInput(
                label: 'Verification code',
                controller: _code,
                keyboardType: TextInputType.number,
                leadingIcon: WBIconName.message,
              ),
              const SizedBox(height: WBSpacing.sm + 6),
              WBInput(
                label: 'New password',
                controller: _password,
                obscureText: true,
                leadingIcon: WBIconName.card,
                placeholder: 'At least 8 characters',
              ),
              const SizedBox(height: WBSpacing.sm + 6),
              WBInput(
                label: 'Confirm password',
                controller: _confirm,
                obscureText: true,
                leadingIcon: WBIconName.card,
              ),
              const Spacer(),
              WBButton(
                label: 'Save password',
                size: WBButtonSize.lg,
                fullWidth: true,
                trailingIcon: WBIconName.arrowRight,
                loading: _busy,
                onPressed: _submit,
              ),
              const SizedBox(height: WBSpacing.xl),
            ],
          ),
        ),
      ),
    );
  }
}
