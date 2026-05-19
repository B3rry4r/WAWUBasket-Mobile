import 'package:flutter/foundation.dart';

/// State machine an order moves through from the vendor's perspective.
/// Mirrors the lifecycle in the build-guide order service (pending →
/// confirmed → preparing → ready → picked_up → en_route → delivered).
enum OrderStage {
  pending,
  preparing,
  ready,
  handover,
  done,
  declined,
}

extension OrderStageX on OrderStage {
  String get label => switch (this) {
        OrderStage.pending => 'Pending',
        OrderStage.preparing => 'Preparing',
        OrderStage.ready => 'Ready',
        OrderStage.handover => 'Picked up',
        OrderStage.done => 'Delivered',
        OrderStage.declined => 'Declined',
      };

  /// What the next forward action does. `null` for terminal stages.
  ({String label, OrderStage next})? get advance => switch (this) {
        OrderStage.pending =>
          (label: 'Accept order', next: OrderStage.preparing),
        OrderStage.preparing =>
          (label: 'Mark ready', next: OrderStage.ready),
        OrderStage.ready =>
          (label: 'Handover to rider', next: OrderStage.handover),
        OrderStage.handover =>
          (label: 'Mark delivered', next: OrderStage.done),
        OrderStage.done || OrderStage.declined => null,
      };
}

/// One line item inside a [VendorOrder]. `mods` is the free-text summary of
/// the modifiers the customer chose (e.g., "Hot · extra plantain").
class OrderItem {
  const OrderItem({
    required this.name,
    required this.qty,
    required this.priceNaira,
    this.mods = const [],
    this.note = '',
  });
  final String name;
  final int qty;
  final int priceNaira;
  final List<String> mods;
  final String note;

  int get lineTotal => qty * priceNaira;
}

class VendorOrder {
  VendorOrder({
    required this.id,
    required this.customerName,
    required this.customerPhone,
    required this.address,
    required this.items,
    required this.placedMinsAgo,
    required this.stage,
    this.riderName,
    this.riderEta,
    this.specialInstructions = '',
    this.serviceFee = 200,
    this.deliveryFee = 600,
  });

  final String id;
  final String customerName;
  final String customerPhone;
  final String address;
  final List<OrderItem> items;
  final int placedMinsAgo;
  OrderStage stage;
  String? riderName;
  String? riderEta;
  final String specialInstructions;
  final int serviceFee;
  final int deliveryFee;

  int get subtotal => items.fold(0, (s, i) => s + i.lineTotal);
  int get total => subtotal + serviceFee + deliveryFee;
}

/// In-memory state for the vendor's live order board. Lets the screens
/// share progress through the stage machine instead of every card
/// resetting after a snackbar.
class VendorOrdersController {
  VendorOrdersController._() : orders = ValueNotifier<List<VendorOrder>>([]) {
    orders.value = _seed();
  }
  static final VendorOrdersController instance = VendorOrdersController._();

  final ValueNotifier<List<VendorOrder>> orders;

  VendorOrder? byId(String id) {
    for (final o in orders.value) {
      if (o.id == id) return o;
    }
    return null;
  }

  /// Advance an order to the next stage. No-op if it's already terminal.
  void advance(String id) {
    final o = byId(id);
    final next = o?.stage.advance;
    if (o == null || next == null) return;
    o.stage = next.next;
    if (next.next == OrderStage.handover && o.riderName == null) {
      o.riderName = 'Tunde Adeyemi';
      o.riderEta = '12 min to drop off';
    }
    _bump();
  }

  void decline(String id) {
    final o = byId(id);
    if (o == null) return;
    o.stage = OrderStage.declined;
    _bump();
  }

  void _bump() => orders.value = List.of(orders.value);

  List<VendorOrder> _seed() => [
        VendorOrder(
          id: 'WAWU-8821',
          customerName: 'Adunni',
          customerPhone: '+234 803 421 1820',
          address: '12 Adeola Odeku St, Victoria Island · Lekki gate, blue door',
          placedMinsAgo: 4,
          stage: OrderStage.pending,
          specialInstructions:
              'No onions please. Extra suya pepper on the side. Call when you arrive — security needs to escort.',
          items: const [
            OrderItem(
              name: 'Jollof rice & grilled chicken',
              qty: 2,
              priceNaira: 4500,
              mods: ['Medium spice', 'Add plantain'],
              note: 'No onions',
            ),
            OrderItem(
              name: 'Suya platter',
              qty: 1,
              priceNaira: 4800,
              mods: ['Hot', 'Extra peppers'],
            ),
          ],
        ),
        VendorOrder(
          id: 'WAWU-8822',
          customerName: 'Tobi',
          customerPhone: '+234 802 988 0421',
          address: '7B Awolowo Rd, Ikoyi · Apt 12',
          placedMinsAgo: 7,
          stage: OrderStage.pending,
          items: const [
            OrderItem(
              name: 'Egusi & pounded yam',
              qty: 1,
              priceNaira: 5200,
              mods: ['Add stockfish'],
            ),
          ],
        ),
        VendorOrder(
          id: 'WAWU-8820',
          customerName: 'Kemi',
          customerPhone: '+234 805 117 7032',
          address: '24 Glover Rd, Ikoyi',
          placedMinsAgo: 12,
          stage: OrderStage.preparing,
          items: const [
            OrderItem(
              name: 'Plantain & beans',
              qty: 2,
              priceNaira: 3200,
              mods: ['Mild spice'],
            ),
          ],
        ),
        VendorOrder(
          id: 'WAWU-8819',
          customerName: 'Daniel',
          customerPhone: '+234 802 244 9911',
          address: '3 Bourdillon Rd, Ikoyi',
          placedMinsAgo: 18,
          stage: OrderStage.preparing,
          items: const [
            OrderItem(
              name: 'Suya platter',
              qty: 1,
              priceNaira: 4800,
              mods: ['Extra hot'],
            ),
          ],
        ),
        VendorOrder(
          id: 'WAWU-8817',
          customerName: 'Funke',
          customerPhone: '+234 808 110 4200',
          address: '12 Akin Adesola St, V/I',
          placedMinsAgo: 24,
          stage: OrderStage.ready,
          riderName: 'Tunde Adeyemi',
          riderEta: '5 min to pickup',
          items: const [
            OrderItem(
              name: 'Small chops platter',
              qty: 1,
              priceNaira: 3500,
            ),
          ],
        ),
        VendorOrder(
          id: 'WAWU-8810',
          customerName: 'Yemi',
          customerPhone: '+234 803 511 7099',
          address: '1 Glover Rd, Ikoyi',
          placedMinsAgo: 62,
          stage: OrderStage.done,
          riderName: 'Bola Okoye',
          riderEta: 'Delivered',
          items: const [
            OrderItem(
              name: 'Jollof rice & grilled chicken',
              qty: 1,
              priceNaira: 4500,
            ),
          ],
        ),
      ];
}
