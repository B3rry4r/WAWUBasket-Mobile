import 'dart:math' as math;

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart' as mb;

import '../../../../core/config/secrets.dart';
import '../../../../core/theme/wb_theme_exports.dart';
import '../../../../core/utils/wb_format.dart';
import '../../../../core/widgets/wb_widgets.dart';
import '../../application/rider_controller.dart';

/// Centre of the rider's view, either a real Mapbox `MapWidget` when a
/// token is configured AND the platform supports it, or a stylized
/// placeholder built with `CustomPainter` otherwise.
///
/// Offer "pins" float over the map. Tapping one calls [onTapOffer].
class RiderMapView extends StatelessWidget {
  const RiderMapView({
    super.key,
    required this.offers,
    required this.onTapOffer,
  });

  final List<DeliveryOffer> offers;
  final ValueChanged<DeliveryOffer> onTapOffer;

  bool get _useMapbox => kMapboxConfigured && !kIsWeb;

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: Stack(
        children: [
          Positioned.fill(
            child: _useMapbox
                ? _MapboxLayer()
                : const _StylizedMap(),
          ),
            // Offer markers, positioned proportionally on the map.
            for (var i = 0; i < offers.length; i++)
              _OfferMarker(
                offer: offers[i],
                slot: i,
                slotCount: offers.length,
                onTap: () => onTapOffer(offers[i]),
              ),
          // Rider's own pin sits at dead-centre.
          const Center(child: _RiderPin()),
        ],
      ),
    );
  }
}

class _MapboxLayer extends StatelessWidget {
  /// Hides the default Mapbox scale-bar + compass + attribution chrome
  /// so the top-left and top-right corners stay clean. We re-surface
  /// attribution in the offer drawer footer instead.
  void _onMapCreated(mb.MapboxMap map) {
    map.scaleBar.updateSettings(mb.ScaleBarSettings(enabled: false));
    map.compass.updateSettings(mb.CompassSettings(enabled: false));
    map.attribution.updateSettings(mb.AttributionSettings(
      position: mb.OrnamentPosition.BOTTOM_RIGHT,
    ));
    map.logo.updateSettings(
      mb.LogoSettings(position: mb.OrnamentPosition.BOTTOM_LEFT),
    );
  }

  @override
  Widget build(BuildContext context) {
    return mb.MapWidget(
      // `cameraOptions` is still the public knob in mapbox_maps_flutter
      // 2.x. The `viewport`/CameraViewportState replacement isn't fully
      // landed yet, so we keep the working API and silence the warning.
      // ignore: deprecated_member_use
      cameraOptions: mb.CameraOptions(
        center: mb.Point(
          coordinates: mb.Position(
            RiderController.riderLng,
            RiderController.riderLat,
          ),
        ),
        zoom: 13.2,
      ),
      styleUri: mb.MapboxStyles.LIGHT,
      onMapCreated: _onMapCreated,
    );
  }
}

/// Calm faux-map for web / no-token. Greybeard radial gradient + a few
/// curved "roads" so the rider pin and offer markers feel grounded.
class _StylizedMap extends StatelessWidget {
  const _StylizedMap();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: RadialGradient(
          radius: 1.1,
          colors: [
            Color(0xFFF1F1F0),
            Color(0xFFE5E5E4),
          ],
        ),
      ),
      child: CustomPaint(painter: _RoadsPainter()),
    );
  }
}

class _RoadsPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final road = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 12
      ..strokeCap = StrokeCap.round;
    final accent = Paint()
      ..color = const Color(0xFFEDEDEB)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round;

    final w = size.width;
    final h = size.height;

    // Three soft curves, the eye sees city roads.
    final p1 = Path()
      ..moveTo(-10, h * 0.78)
      ..cubicTo(w * 0.25, h * 0.62, w * 0.55, h * 0.74, w + 10, h * 0.58);
    final p2 = Path()
      ..moveTo(w * 0.18, -10)
      ..cubicTo(w * 0.26, h * 0.3, w * 0.42, h * 0.55, w * 0.34, h + 10);
    final p3 = Path()
      ..moveTo(w * 0.62, -10)
      ..cubicTo(w * 0.7, h * 0.25, w * 0.78, h * 0.6, w * 0.86, h + 10);

    for (final p in [p1, p2, p3]) {
      canvas.drawPath(p, road);
      canvas.drawPath(p, accent);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _RiderPin extends StatelessWidget {
  const _RiderPin();
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: WBColors.surfaceDark,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 3),
        boxShadow: const [
          BoxShadow(
            color: Color(0x33000000),
            blurRadius: 14,
            offset: Offset(0, 4),
          ),
        ],
      ),
      alignment: Alignment.center,
      child: const WBIcon(
        WBIconName.bike,
        size: 16,
        color: Colors.white,
      ),
    );
  }
}

class _OfferMarker extends StatelessWidget {
  const _OfferMarker({
    required this.offer,
    required this.slot,
    required this.slotCount,
    required this.onTap,
  });
  final DeliveryOffer offer;
  final int slot;
  final int slotCount;
  final VoidCallback onTap;

  /// Deterministic positioning around the centre, close offers nearer
  /// the rider, far ones at the edge. Avoids overlapping the rider pin
  /// and the bottom sheet handle.
  Alignment _slotAlignment() {
    // Fan markers across the top hemisphere of the map so the bottom
    // sheet (~38% of the height) doesn't cover any of them.
    final t = slotCount == 1 ? 0.5 : slot / (slotCount - 1);
    final angle = (math.pi + math.pi * t) * 0.9 + math.pi * 0.05; // 162° → 342°
    final r = 0.55 + (slot.isOdd ? -0.05 : 0.05);
    final dx = r * math.cos(angle);
    final dy = r * math.sin(angle) * 0.85; // squash vertically
    return Alignment(dx.clamp(-0.9, 0.9), dy.clamp(-0.9, 0.4));
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: _slotAlignment(),
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(WBRadius.pill),
            border: Border.all(color: WBColors.bgDivider),
            boxShadow: const [
              BoxShadow(
                color: Color(0x1F000000),
                blurRadius: 12,
                offset: Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 6,
                height: 6,
                decoration: const BoxDecoration(
                  color: WBColors.surfaceDark,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                wbNaira(offer.feeNaira),
                style: WBTypography.caption.copyWith(
                  color: WBColors.fgHeader,
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                '· ${offer.distanceKm.toStringAsFixed(1)}km',
                style: WBTypography.caption.copyWith(
                  color: WBColors.fgSecondary,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
