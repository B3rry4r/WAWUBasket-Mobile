import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart' as mb;

import '../../../../core/config/secrets.dart';
import '../../../../core/theme/wb_theme_exports.dart';
import '../../../../core/utils/wb_format.dart';
import '../../../../core/utils/wb_permissions.dart';
import '../../../../core/widgets/wb_widgets.dart';
import '../../application/rider_controller.dart';

/// Centre of the rider's view, either a real Mapbox `MapWidget` when a
/// token is configured AND the platform supports it, or a stylized
/// placeholder built with `CustomPainter` otherwise.
///
/// Offer "pins" float over the map as detail pills (dot + fee + distance).
/// Tapping one calls [onTapOffer]. A recenter button snaps the camera
/// back to the rider's live GPS.
class RiderMapView extends StatelessWidget {
  const RiderMapView({
    super.key,
    required this.offers,
    required this.onTapOffer,
    this.bottomInset = 0,
  });

  final List<DeliveryOffer> offers;
  final ValueChanged<DeliveryOffer> onTapOffer;

  /// Extra space at the bottom of the map kept clear of overlays (e.g. the
  /// rider-home offer sheet). The recenter button floats above this inset.
  final double bottomInset;

  bool get _useMapbox => kMapboxConfigured && !kIsWeb;

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: _useMapbox
          ? _MapboxLayer(
              offers: offers,
              onTapOffer: onTapOffer,
              bottomInset: bottomInset,
            )
          : Stack(
              children: [
                const Positioned.fill(child: _StylizedMap()),
                for (var i = 0; i < offers.length; i++)
                  _OfferMarker(
                    offer: offers[i],
                    slot: i,
                    slotCount: offers.length,
                    onTap: () => onTapOffer(offers[i]),
                  ),
                const Center(child: _RiderPin()),
              ],
            ),
    );
  }
}

class _MapboxLayer extends StatefulWidget {
  const _MapboxLayer({
    required this.offers,
    required this.onTapOffer,
    required this.bottomInset,
  });
  final List<DeliveryOffer> offers;
  final ValueChanged<DeliveryOffer> onTapOffer;
  final double bottomInset;

  @override
  State<_MapboxLayer> createState() => _MapboxLayerState();
}

class _MapboxLayerState extends State<_MapboxLayer> {
  mb.MapboxMap? _map;
  mb.PointAnnotationManager? _pointManager;

  /// annotation id → offer, so a tapped pin maps back to its offer.
  final Map<String, DeliveryOffer> _annotationOffers = {};

  bool _locating = false;

  @override
  void didUpdateWidget(covariant _MapboxLayer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.offers != oldWidget.offers) _syncAnnotations();
  }

  Future<void> _onMapCreated(mb.MapboxMap map) async {
    _map = map;
    map.scaleBar.updateSettings(mb.ScaleBarSettings(enabled: false));
    map.compass.updateSettings(mb.CompassSettings(enabled: false));
    map.attribution.updateSettings(mb.AttributionSettings(
      position: mb.OrnamentPosition.BOTTOM_RIGHT,
    ));
    map.logo.updateSettings(
      mb.LogoSettings(position: mb.OrnamentPosition.BOTTOM_LEFT),
    );

    // Show the user's location puck if we have permission. Pulsing is off
    // so the puck reads as a steady marker — GPS already jitters the
    // position on its own and a pulse ring on top looks like extra motion.
    final granted = await WBPermissions.hasLocation();
    if (granted) {
      await map.location.updateSettings(
        mb.LocationComponentSettings(enabled: true, pulsingEnabled: false),
      );
      _centerOnCurrent();
    }

    _pointManager = await map.annotations.createPointAnnotationManager();
    // ignore: deprecated_member_use
    _pointManager!.addOnPointAnnotationClickListener(
      _OfferClickListener((id) {
        final offer = _annotationOffers[id];
        if (offer != null) widget.onTapOffer(offer);
      }),
    );
    _syncAnnotations();
  }

  /// Read the device's current GPS and re-centre the camera on the rider.
  /// Called once on map create and again every time the recenter button
  /// is tapped, so the rider can always snap back to themselves.
  Future<void> _centerOnCurrent() async {
    if (_locating) return;
    setState(() => _locating = true);
    try {
      final granted = await WBPermissions.requestLocation();
      if (!granted) return;
      final pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );
      RiderController.instance.updatePosition(pos.latitude, pos.longitude);
      if (!mounted || _map == null) return;
      await _map!.flyTo(
        mb.CameraOptions(
          center: mb.Point(
            coordinates: mb.Position(pos.longitude, pos.latitude),
          ),
          zoom: 15,
        ),
        mb.MapAnimationOptions(duration: 700),
      );
    } catch (_) {
      // Service disabled or fix unavailable — keep the current camera.
    } finally {
      if (mounted) setState(() => _locating = false);
    }
  }

  Future<void> _syncAnnotations() async {
    final mgr = _pointManager;
    if (mgr == null) return;
    await mgr.deleteAll();
    _annotationOffers.clear();

    for (final o in widget.offers) {
      final image = await _buildPillImage(o);
      final ann = await mgr.create(
        mb.PointAnnotationOptions(
          geometry: mb.Point(
            coordinates: mb.Position(o.vendorLng, o.vendorLat),
          ),
          image: image,
          // LEFT anchor → the dot at the pill's left edge sits exactly on
          // the vendor coordinate; the detail pill extends to the side.
          iconAnchor: mb.IconAnchor.LEFT,
          iconSize: 1.0,
        ),
      );
      _annotationOffers[ann.id] = o;
    }
  }

  /// Renders an offer detail pill (dark dot + "₦600 · 4.2km") to PNG bytes
  /// for use as a Mapbox marker image. Drawn at 3× for retina crispness.
  Future<Uint8List> _buildPillImage(DeliveryOffer offer) async {
    const scale = 3.0;
    const h = 30.0;
    const padL = 9.0;
    const padR = 12.0;
    const dot = 8.0;
    const gap = 7.0;
    const radius = h / 2;

    final feeText = wbNaira(offer.feeNaira);
    final distText = ' · ${offer.distanceKm.toStringAsFixed(1)}km';

    // Lay out the two-tone label to measure its width.
    final builder = ui.ParagraphBuilder(ui.ParagraphStyle(
      fontSize: 12.5,
      textAlign: TextAlign.left,
    ))
      ..pushStyle(ui.TextStyle(
        color: WBColors.fgHeader,
        fontWeight: FontWeight.w700,
        fontSize: 12.5,
      ))
      ..addText(feeText)
      ..pushStyle(ui.TextStyle(
        color: WBColors.fgSecondary,
        fontWeight: FontWeight.w500,
        fontSize: 11.5,
      ))
      ..addText(distText);
    final paragraph = builder.build()
      ..layout(const ui.ParagraphConstraints(width: 400));
    final textW = paragraph.longestLine;

    final w = padL + dot + gap + textW + padR;
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    canvas.scale(scale);

    final pillRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, w, h),
      const Radius.circular(radius),
    );

    // Soft drop shadow.
    canvas.drawRRect(
      pillRect.shift(const Offset(0, 2)),
      Paint()
        ..color = const Color(0x22000000)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
    );
    // White pill body + hairline border.
    canvas.drawRRect(pillRect, Paint()..color = Colors.white);
    canvas.drawRRect(
      pillRect.deflate(0.5),
      Paint()
        ..color = WBColors.bgDivider
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );
    // The dark locator dot at the left.
    canvas.drawCircle(
      Offset(padL + dot / 2, h / 2),
      dot / 2,
      Paint()..color = WBColors.surfaceDark,
    );
    // The fee + distance label.
    canvas.drawParagraph(
      paragraph,
      Offset(padL + dot + gap, (h - paragraph.height) / 2),
    );

    final picture = recorder.endRecording();
    final img = await picture.toImage(
      (w * scale).ceil(),
      (h * scale).ceil(),
    );
    final bytes = await img.toByteData(format: ui.ImageByteFormat.png);
    return bytes!.buffer.asUint8List();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        mb.MapWidget(
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
        ),
        Positioned(
          right: 14,
          bottom: 14 + widget.bottomInset,
          child: _RecenterButton(
            busy: _locating,
            onTap: _centerOnCurrent,
          ),
        ),
      ],
    );
  }
}

/// Circular white button that snaps the camera to the rider's live GPS.
class _RecenterButton extends StatelessWidget {
  const _RecenterButton({required this.busy, required this.onTap});
  final bool busy;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: busy ? null : onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: 46,
        height: 46,
        decoration: BoxDecoration(
          color: WBColors.surfaceCard,
          shape: BoxShape.circle,
          boxShadow: const [
            BoxShadow(
              color: Color(0x26000000),
              blurRadius: 14,
              offset: Offset(0, 5),
            ),
          ],
        ),
        alignment: Alignment.center,
        child: busy
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation(WBColors.surfaceDark),
                ),
              )
            : const WBIcon(
                WBIconName.pin,
                size: 20,
                color: WBColors.surfaceDark,
              ),
      ),
    );
  }
}

// ignore: deprecated_member_use
class _OfferClickListener extends mb.OnPointAnnotationClickListener {
  _OfferClickListener(this._onTap);
  final void Function(String annotationId) _onTap;

  @override
  void onPointAnnotationClick(mb.PointAnnotation annotation) {
    _onTap(annotation.id);
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
    final t = slotCount == 1 ? 0.5 : slot / (slotCount - 1);
    final angle = (math.pi + math.pi * t) * 0.9 + math.pi * 0.05;
    final r = 0.55 + (slot.isOdd ? -0.05 : 0.05);
    final dx = r * math.cos(angle);
    final dy = r * math.sin(angle) * 0.85;
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
