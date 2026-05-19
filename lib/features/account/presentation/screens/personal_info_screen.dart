import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/wb_theme_exports.dart';
import '../../../../core/utils/wb_actions.dart';
import '../../../../core/widgets/wb_widgets.dart';
import '../../../shopping/application/wb_images.dart';

class PersonalInfoScreen extends StatelessWidget {
  const PersonalInfoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: WBColors.bgPrimary,
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
                Text('Personal information', style: WBTypography.page),
              ],
            ),
            const SizedBox(height: WBSpacing.lg),
            // Profile photo picker
            Center(
              child: GestureDetector(
                onTap: () => wbShowSnack(context, 'Choose a profile photo'),
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      width: 108,
                      height: 108,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: WBColors.bgDivider,
                          width: 2,
                        ),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: const WBNetworkImage(url: WBImages.avatar),
                    ),
                    Positioned(
                      right: 2,
                      bottom: 2,
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: WBColors.surfaceDark,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: WBColors.bgPrimary,
                            width: 2,
                          ),
                        ),
                        alignment: Alignment.center,
                        child: const WBIcon(
                          WBIconName.plus,
                          size: 14,
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10),
            Center(
              child: Text(
                'Tap to change photo',
                style: WBTypography.caption.copyWith(
                  color: WBColors.fgSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(height: WBSpacing.lg),
            const WBInput(
              label: 'Full name',
              initialValue: 'Brooks Adesanya',
              leadingIcon: WBIconName.user,
            ),
            const SizedBox(height: WBSpacing.md),
            const WBInput(
              label: 'Email',
              initialValue: 'brooks@wawu.africa',
              leadingIcon: WBIconName.message,
            ),
            const SizedBox(height: WBSpacing.md),
            const WBInput(
              label: 'Phone number',
              initialValue: '+234 803 421 1820',
              leadingIcon: WBIconName.phone,
            ),
            const SizedBox(height: WBSpacing.md),
            const WBInput(
              label: 'Date of birth',
              initialValue: '14 Mar 1996',
              leadingIcon: WBIconName.clock,
            ),
            const SizedBox(height: WBSpacing.xl),
            WBButton(
              label: 'Save changes',
              size: WBButtonSize.lg,
              fullWidth: true,
              onPressed: () {
                wbShowSnack(context, 'Changes saved');
                context.pop();
              },
            ),
          ],
        ),
      ),
    );
  }
}
