import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/wb_theme_exports.dart';
import '../../../../core/widgets/wb_widgets.dart';

class TermsScreen extends StatelessWidget {
  const TermsScreen({super.key});

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
                Text('Terms of Service', style: WBTypography.page),
              ],
            ),
            const SizedBox(height: WBSpacing.lg),
            _buildHeader('Terms of Service'),
            _buildBody(
              'Effective Date: June 1, 2025\n\n'
              'Welcome to WAWUBasket. By accessing or using our platform — whether through our '
              'mobile application, website, or any related services — you agree to be bound by '
              'these Terms of Service. Please read them carefully before using our platform.',
            ),
            const SizedBox(height: WBSpacing.md),
            _buildSection(
              '1. Acceptance of Terms',
              'By creating an account, placing an order, or using any part of the WAWUBasket '
              'platform, you confirm that you are at least 18 years old, have the legal capacity '
              'to enter into a binding contract, and agree to these Terms. If you are using the '
              'platform on behalf of an organisation, you represent that you have authority to '
              'bind that organisation to these Terms.',
            ),
            _buildSection(
              '2. Our Platform',
              'WAWUBasket is a multi-sided commerce platform that connects customers with vendors '
              'selling food, groceries, fresh produce, livestock, and household essentials. We '
              'also facilitate cross-border trade and logistics through our Agent, Trader, Rider, '
              'and Driver roles.\n\n'
              'WAWUBasket acts as a marketplace and technology provider. We are not the seller of '
              'the products listed on our platform unless explicitly stated. Individual vendors, '
              'traders, and agents are responsible for the accuracy of their listings, the quality '
              'of their products, and compliance with applicable laws.',
            ),
            _buildSection(
              '3. User Accounts',
              'You are responsible for maintaining the confidentiality of your login credentials. '
              'You agree to notify us immediately at basket@wawuafrica.com if you suspect unauthorised '
              'access to your account. WAWUBasket is not liable for losses resulting from '
              'unauthorised account use where you have failed to safeguard your credentials.\n\n'
              'We reserve the right to suspend or terminate accounts that violate these Terms, '
              'engage in fraudulent activity, or are inactive for an extended period.',
            ),
            _buildSection(
              '4. Placing Orders',
              'When you place an order through WAWUBasket, you are making a binding offer to '
              'purchase from the relevant vendor. Your order is confirmed when you receive an '
              'in-app confirmation notification. Prices are displayed in the local currency and '
              'are subject to change without notice before an order is placed.\n\n'
              'Delivery times are estimates only. Factors including traffic, weather, and vendor '
              'preparation time may affect actual delivery.',
            ),
            _buildSection(
              '5. Payments and Refunds',
              'Payments are processed through our integrated payment partners. By providing '
              'payment details, you authorise us to charge the stated amount. All transactions '
              'are subject to the payment processor\'s own terms.\n\n'
              'Refunds are issued at WAWUBasket\'s discretion in cases of non-delivery, '
              'significantly incorrect orders, or other qualifying circumstances. Requests must '
              'be made within 24 hours of the scheduled delivery time. Refunds are returned to '
              'the original payment method within 5–10 business days.',
            ),
            _buildSection(
              '6. Vendor and Operator Responsibilities',
              'Vendors, Agents, Traders, Riders, and Drivers who register on WAWUBasket agree '
              'to provide accurate business information, maintain valid licences where required, '
              'comply with all applicable food safety, trade, and transport regulations, and '
              'fulfil orders in good faith. WAWUBasket reserves the right to suspend or remove '
              'any operator found to be in breach of these obligations.',
            ),
            _buildSection(
              '7. Prohibited Conduct',
              'You agree not to:\n\n'
              '• Use the platform for any unlawful purpose\n'
              '• Circumvent, disable, or interfere with security features\n'
              '• Upload or transmit malicious code\n'
              '• Engage in fraudulent transactions or chargebacks in bad faith\n'
              '• Harass, abuse, or threaten other users, vendors, or riders\n'
              '• Attempt to gain unauthorised access to any part of the platform\n'
              '• Use automated tools to scrape or extract platform data without consent',
            ),
            _buildSection(
              '8. Intellectual Property',
              'All content on the WAWUBasket platform — including logos, designs, text, and '
              'software — is owned by or licensed to WAWUBasket Ltd and is protected by '
              'applicable intellectual property laws. You may not reproduce, distribute, or '
              'create derivative works without our prior written consent.',
            ),
            _buildSection(
              '9. Privacy',
              'Your use of WAWUBasket is also governed by our Privacy Policy, which is '
              'incorporated into these Terms by reference. By using the platform, you consent '
              'to the collection and use of your data as described in the Privacy Policy.',
            ),
            _buildSection(
              '10. Limitation of Liability',
              'To the maximum extent permitted by law, WAWUBasket, its officers, directors, '
              'employees, and affiliates shall not be liable for any indirect, incidental, '
              'special, or consequential damages arising from your use of the platform, '
              'including but not limited to loss of profit, data, or goodwill.\n\n'
              'Our total liability for any claim arising from these Terms shall not exceed the '
              'amount you paid to WAWUBasket in the 30 days preceding the event giving rise to '
              'the claim.',
            ),
            _buildSection(
              '11. Modifications to the Terms',
              'We may update these Terms from time to time. We will notify you of material '
              'changes via in-app notification or email. Continued use of the platform after '
              'the effective date of the updated Terms constitutes your acceptance.',
            ),
            _buildSection(
              '12. Governing Law',
              'These Terms are governed by and construed in accordance with the laws of the '
              'Federal Republic of Nigeria. Any disputes arising under these Terms shall be '
              'subject to the exclusive jurisdiction of the courts of Lagos State, Nigeria.',
            ),
            _buildSection(
              '13. Termination',
              'You may close your account at any time by contacting us at basket@wawuafrica.com. '
              'We may terminate or suspend your access to the platform at any time, with or '
              'without cause, with or without notice. Upon termination, your right to use the '
              'platform ceases immediately.',
            ),
            _buildSection(
              '14. Contact Us',
              'If you have questions about these Terms, please contact us:\n\n'
              'WAWUBasket Ltd\n'
              'Email: basket@wawuafrica.com\n'
              'Phone: 07050622222',
            ),
          ],
        ),
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
