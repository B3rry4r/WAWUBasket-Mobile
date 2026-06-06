import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/network/api_exception.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/wb_theme_exports.dart';
import '../../../../core/utils/wb_actions.dart';
import '../../../../core/utils/wb_l10n.dart';
import '../../../../core/widgets/wb_widgets.dart';
import '../../../home/presentation/widgets/search_field.dart';
import '../../data/account_extras_api.dart';

class SupportScreen extends StatefulWidget {
  const SupportScreen({super.key});

  @override
  State<SupportScreen> createState() => _SupportScreenState();
}

const _months = [
  'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
  'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
];

class _Faq {
  const _Faq(this.q, this.a);
  final String q;
  final String a;
}

class _Ticket {
  const _Ticket({required this.subject, required this.status, required this.opened});
  final String subject;
  final String status;
  final String opened;
}

class _SupportScreenState extends State<SupportScreen> {
  List<({WBIconName icon, String label, String sub, String cta})> _contacts(BuildContext context) => [
    (
      icon: WBIconName.message,
      label: context.l10n.supportLiveChat,
      sub: context.l10n.supportLiveChatSub,
      cta: context.l10n.supportLiveChatCta,
    ),
    (
      icon: WBIconName.phone,
      label: context.l10n.supportCall,
      sub: context.l10n.supportCallSub,
      cta: context.l10n.supportCallCta,
    ),
    (
      icon: WBIconName.bell,
      label: context.l10n.supportEmail,
      sub: context.l10n.supportEmailSub,
      cta: context.l10n.supportEmailCta,
    ),
  ];

  List<_Faq>? _faqs;
  final Set<int> _expandedFaqs = {};
  _Ticket? _ticket;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final faqs = await AccountExtrasApi.instance.faqs();
      if (mounted) {
        setState(() => _faqs = [
              for (final f in faqs)
                _Faq(
                  ((f as Map)['question'] ?? '').toString(),
                  (f['answer'] ?? '').toString(),
                ),
            ]);
      }
    } on ApiException {
      if (mounted) setState(() => _faqs = const []);
    }
    try {
      final tickets = await AccountExtrasApi.instance.tickets();
      if (tickets.isNotEmpty && mounted) {
        final t = (tickets.first as Map).cast<String, dynamic>();
        final created = DateTime.tryParse('${t['createdAt'] ?? ''}');
        setState(() => _ticket = _Ticket(
              subject: (t['subject'] ?? 'Support ticket').toString(),
              status: (t['status'] ?? 'open').toString(),
              opened: created == null
                  ? ''
                  : 'Opened ${created.day} ${_months[created.month - 1]}. '
                      'Our team will respond within 24 hrs.',
            ));
      }
    } on ApiException {
      // No ticket card when the fetch fails.
    }
  }

  @override
  Widget build(BuildContext context) {
    final faqs = _faqs;
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
                Text(context.l10n.supportTitle, style: WBTypography.page),
              ],
            ),
            const SizedBox(height: WBSpacing.lg),
            // FAQ search
            Container(
              height: 52,
              padding: const EdgeInsets.symmetric(horizontal: 18),
              decoration: BoxDecoration(
                color: WBColors.surfaceCard,
                borderRadius: BorderRadius.circular(WBRadius.input),
                boxShadow: WBShadows.card,
              ),
              child: Row(
                children: [
                  const WBIcon(
                    WBIconName.search,
                    size: 20,
                    color: WBColors.fgPlaceholder,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    context.l10n.supportSearchPlaceholder,
                    style: WBTypography.body.copyWith(
                      color: WBColors.fgPlaceholder,
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: WBSpacing.lg),
            Text(
              context.l10n.supportContactUs,
              style: WBTypography.label.copyWith(
                fontWeight: FontWeight.w600,
                color: WBColors.fgPlaceholder,
                letterSpacing: 0.66,
              ),
            ),
            const SizedBox(height: 10),
            for (final c in _contacts(context)) ...[
              Container(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
                decoration: BoxDecoration(
                  color: WBColors.surfaceCard,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: WBShadows.card,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: const BoxDecoration(
                        color: WBColors.bgSoft,
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: WBIcon(c.icon, size: 18),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            c.label,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: WBTypography.body.copyWith(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            c.sub,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: WBTypography.caption.copyWith(
                              color: WBColors.fgSecondary,
                            ),
                          ),
                          const SizedBox(height: 10),
                          WBButton(
                            label: c.cta,
                            size: WBButtonSize.sm,
                            onPressed: () {
                              if (c.icon == WBIconName.message) {
                                context.push(AppRoutes.chatSupport);
                              } else if (c.icon == WBIconName.phone) {
                                wbCallPhone(context, '07050622222');
                              } else {
                                wbLaunchEmail(context, 'support@wawubasket.com');
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
            ],
            const SizedBox(height: WBSpacing.md),
            SectionHeader(title: context.l10n.supportCommonQuestions, action: context.l10n.actionSeeAll),
            const SizedBox(height: WBSpacing.sm + 2),
            if (faqs == null)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 32),
                child: Center(
                  child: SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.4,
                      valueColor:
                          AlwaysStoppedAnimation(WBColors.surfaceDark),
                    ),
                  ),
                ),
              )
            else if (faqs.isNotEmpty)
              Container(
                decoration: BoxDecoration(
                  color: WBColors.surfaceCard,
                  borderRadius: BorderRadius.circular(WBRadius.card),
                  boxShadow: WBShadows.card,
                ),
                clipBehavior: Clip.antiAlias,
                child: Column(
                  children: [
                    for (var i = 0; i < faqs.length; i++) ...[
                      GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () => setState(() {
                          if (_expandedFaqs.contains(i)) {
                            _expandedFaqs.remove(i);
                          } else {
                            _expandedFaqs.add(i);
                          }
                        }),
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: Text(
                                      faqs[i].q,
                                      style: WBTypography.body.copyWith(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                        height: 1.4,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  AnimatedRotation(
                                    turns: _expandedFaqs.contains(i) ? 0.25 : 0,
                                    duration: WBMotion.base,
                                    child: const WBIcon(
                                      WBIconName.chevronRight,
                                      size: 16,
                                      color: WBColors.fgPlaceholder,
                                    ),
                                  ),
                                ],
                              ),
                              AnimatedSize(
                                duration: WBMotion.base,
                                curve: WBMotion.easeSoft,
                                alignment: Alignment.topCenter,
                                child: _expandedFaqs.contains(i)
                                    ? Padding(
                                        padding: const EdgeInsets.only(top: 8),
                                        child: Text(
                                          faqs[i].a,
                                          style: WBTypography.caption.copyWith(
                                            color: WBColors.fgSecondary,
                                            fontSize: 13,
                                            height: 1.5,
                                          ),
                                        ),
                                      )
                                    : const SizedBox(width: double.infinity),
                              ),
                            ],
                          ),
                        ),
                      ),
                      if (i != faqs.length - 1) const WBDivider(),
                    ],
                  ],
                ),
              ),
            if (_ticket != null) ...[
              const SizedBox(height: WBSpacing.md),
              Container(
                padding: const EdgeInsets.all(WBSpacing.md + 2),
                decoration: BoxDecoration(
                  color: WBColors.surfaceCard,
                  borderRadius: BorderRadius.circular(WBRadius.card),
                  boxShadow: WBShadows.card,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          context.l10n.supportOpenTicket,
                          style: WBTypography.label.copyWith(
                            fontWeight: FontWeight.w600,
                            color: WBColors.fgPlaceholder,
                            letterSpacing: 0.66,
                          ),
                        ),
                        WBStatusPill(
                          label: _ticket!.status,
                          kind: _ticket!.status.toLowerCase() == 'resolved' ||
                                  _ticket!.status.toLowerCase() == 'closed'
                              ? WBStatusKind.success
                              : WBStatusKind.warning,
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      _ticket!.subject,
                      style: WBTypography.body.copyWith(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _ticket!.opened,
                      style: WBTypography.caption.copyWith(
                        color: WBColors.fgSecondary,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 12),
                    WBButton(
                      label: context.l10n.supportViewTicket,
                      variant: WBButtonVariant.secondary,
                      size: WBButtonSize.sm,
                      onPressed: () => context.push(AppRoutes.chatSupport),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
