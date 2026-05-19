import 'package:flutter/material.dart';

import '../../../../core/widgets/wb_widgets.dart';
import '../../application/vendor_orders_controller.dart';

/// Maps an [OrderStage] to the WBStatusPill kind/label so order cards and
/// the order-detail screen never re-derive the mapping inline.
class VendorOrderStatusPill extends StatelessWidget {
  const VendorOrderStatusPill({super.key, required this.stage});
  final OrderStage stage;

  @override
  Widget build(BuildContext context) {
    final kind = switch (stage) {
      OrderStage.pending => WBStatusKind.warning,
      OrderStage.preparing => WBStatusKind.info,
      OrderStage.ready => WBStatusKind.success,
      OrderStage.handover => WBStatusKind.info,
      OrderStage.done => WBStatusKind.success,
      OrderStage.declined => WBStatusKind.error,
    };
    return WBStatusPill(label: stage.label, kind: kind);
  }
}
