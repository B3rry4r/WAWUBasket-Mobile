import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/responsive/wb_responsive_exports.dart';
import '../../../../core/theme/wb_theme_exports.dart';
import '../../../../core/widgets/wb_widgets.dart';
import '../../../shell/presentation/desktop/customer_web_scaffold.dart';

/// Desktop-web layout for the Privacy Policy screen. Isolated from the mobile
/// build — re-lays the same legal copy as a centered, readable document column
/// inside the shared [CustomerWebScaffold]. Behaviour mirrors [PrivacyScreen].
class PrivacyDesktopScreen extends StatelessWidget {
  const PrivacyDesktopScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomerWebScaffold(
      child: ListView(
        padding: const EdgeInsets.symmetric(vertical: WBSpacing.xl),
        children: [
          WBMaxWidth(
            maxWidth: 720,
            padding: const EdgeInsets.symmetric(
              horizontal: WBSpacing.screenPadding,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    WBBackChip(onPressed: () => context.pop()),
                    const SizedBox(width: 14),
                    Text('Privacy Policy', style: WBTypography.page),
                  ],
                ),
                const SizedBox(height: WBSpacing.lg),
                _buildHeader('Privacy Policy'),
                _buildBody(
                  'Effective Date: June 1, 2025\n\n'
                  'WAWUBasket Ltd ("we", "us", or "our") is committed to protecting your privacy. '
                  'This Privacy Policy explains how we collect, use, disclose, and safeguard your '
                  'information when you use the WAWUBasket mobile application, website, and related '
                  'services (collectively, the "Platform").\n\n'
                  'By using our Platform, you agree to the terms of this Privacy Policy. If you do '
                  'not agree, please do not use the Platform.',
                ),
                const SizedBox(height: WBSpacing.md),
                _buildSection(
                  '1. Information We Collect',
                  'We collect the following categories of information:\n\n'
                  'Account Information: Name, phone number, email address, and password when you '
                  'register an account.\n\n'
                  'Profile Information: Delivery addresses, dietary preferences, profile photo, '
                  'and role-specific details (e.g., KYC documents for vendors, agents, traders, '
                  'riders, and drivers).\n\n'
                  'Transaction Data: Order history, payment details (processed and tokenised by '
                  'our payment partners — we do not store full card numbers), and escrow records.\n\n'
                  'Location Data: With your permission, we collect precise location data to '
                  'calculate delivery routes, show nearby vendors, and enable live order tracking.\n\n'
                  'Device & Usage Data: Device type, operating system, IP address, app version, '
                  'and in-app interaction logs to improve the Platform.\n\n'
                  'Communications: Messages sent through our in-app chat and support channels.',
                ),
                _buildSection(
                  '2. How We Use Your Information',
                  'We use your information to:\n\n'
                  '• Operate and provide the Platform and its features\n'
                  '• Process and fulfil your orders and payments\n'
                  '• Verify identity and complete KYC for operator roles\n'
                  '• Enable real-time order tracking and delivery coordination\n'
                  '• Send order confirmations, delivery updates, and service notifications\n'
                  '• Personalise your experience, including product recommendations\n'
                  '• Detect and prevent fraud, abuse, and security incidents\n'
                  '• Comply with legal obligations\n'
                  '• Improve and develop our products and services',
                ),
                _buildSection(
                  '3. Sharing Your Information',
                  'We share your information only as necessary:\n\n'
                  'Vendors, Riders, and Drivers: We share your name, delivery address, and order '
                  'details with the relevant fulfilment parties to complete your order.\n\n'
                  'Payment Processors: We share transaction data with our payment partners (e.g., '
                  'Flutterwave) to process payments securely.\n\n'
                  'Service Providers: We may engage third-party companies to help operate the '
                  'Platform (e.g., cloud hosting, analytics, push notifications) under strict '
                  'data processing agreements.\n\n'
                  'Legal Authorities: We may disclose information when required by law, court order, '
                  'or government request, or to protect the rights and safety of users and the public.\n\n'
                  'We do not sell your personal data to third parties.',
                ),
                _buildSection(
                  '4. Location Data',
                  'Location access is used only while the app is in use (foreground), unless you '
                  'are operating as a Rider or Driver with an active delivery — in which case '
                  'background location is required to enable live tracking.\n\n'
                  'You can revoke location permissions at any time in your device settings. Doing so '
                  'may affect delivery accuracy and live tracking features.',
                ),
                _buildSection(
                  '5. Push Notifications',
                  'We send push notifications for order updates, promotional offers, and platform '
                  'alerts. You can opt out at any time through your device\'s notification settings '
                  'or within the WAWUBasket app.',
                ),
                _buildSection(
                  '6. Data Retention',
                  'We retain your personal data for as long as your account is active or as needed '
                  'to provide our services. Transaction records may be retained for up to seven years '
                  'for tax and regulatory compliance. You may request deletion of your account and '
                  'associated data at any time (see Section 10).',
                ),
                _buildSection(
                  '7. Data Security',
                  'We implement industry-standard security measures including encryption in transit '
                  '(TLS), encrypted storage for sensitive data, and access controls. However, no '
                  'system is completely secure. We encourage you to use a strong, unique password.',
                ),
                _buildSection(
                  '8. Children\'s Privacy',
                  'WAWUBasket is not intended for users under the age of 18. We do not knowingly '
                  'collect personal information from children. If we become aware that a child has '
                  'provided us with personal information, we will take steps to delete it promptly.',
                ),
                _buildSection(
                  '9. Third-Party Links',
                  'Our Platform may contain links to third-party websites or services. We are not '
                  'responsible for the privacy practices of those third parties. We encourage you '
                  'to review their privacy policies before providing any information.',
                ),
                _buildSection(
                  '10. Your Rights',
                  'Subject to applicable law, you have the right to:\n\n'
                  '• Access the personal data we hold about you\n'
                  '• Request correction of inaccurate data\n'
                  '• Request deletion of your account and personal data\n'
                  '• Object to or restrict certain processing activities\n'
                  '• Withdraw consent where processing is based on consent\n\n'
                  'To exercise any of these rights, contact us at basket@wawuafrica.com. We will '
                  'respond within 30 days.',
                ),
                _buildSection(
                  '11. Changes to This Policy',
                  'We may update this Privacy Policy periodically. We will notify you of material '
                  'changes via in-app notification or email. Your continued use of the Platform '
                  'after the effective date of the updated policy constitutes your acceptance.',
                ),
                _buildSection(
                  '12. Contact Us',
                  'If you have questions or concerns about this Privacy Policy or our data practices, '
                  'please contact us:\n\n'
                  'WAWUBasket Ltd\n'
                  'Email: basket@wawuafrica.com\n'
                  'Phone: 07050622222',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(String text) {
    return Text(
      text,
      style: WBTypography.cardTitle.copyWith(fontSize: 20, height: 1.3),
    );
  }

  Widget _buildBody(String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Text(
        text,
        style: WBTypography.body.copyWith(
          color: WBColors.fgSecondary,
          fontSize: 14,
          height: 1.6,
        ),
      ),
    );
  }

  Widget _buildSection(String title, String body) {
    return Padding(
      padding: const EdgeInsets.only(bottom: WBSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: WBTypography.body.copyWith(
              fontWeight: FontWeight.w600,
              fontSize: 15,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            body,
            style: WBTypography.body.copyWith(
              color: WBColors.fgSecondary,
              fontSize: 14,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}
