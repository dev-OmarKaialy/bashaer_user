import 'package:flutter/widgets.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

/// Renders a category's `icon` value from the question bank.
///
/// The current contract stores a single emoji glyph (e.g. `🚦`), which is drawn
/// as monochrome [color] so it stays readable on the gradient badge. Rows written
/// before the picker hold Font Awesome style names (`oil-can`) and keep using the
/// vector icon; anything unrecognised falls back to a car.
class CategoryIcon extends StatelessWidget {
  const CategoryIcon({super.key, required this.name, required this.size, required this.color});

  final String? name;
  final double size;
  final Color color;

  static const Map<String, FaIconData> _icons = {
    'snowflake': FontAwesomeIcons.snowflake,
    'oil-can': FontAwesomeIcons.oilCan,
    'engine': FontAwesomeIcons.gear,
    'gas-pump': FontAwesomeIcons.gasPump,
    'bolt': FontAwesomeIcons.bolt,
    'car-battery': FontAwesomeIcons.carBattery,
    'gears': FontAwesomeIcons.gears,
    'wrench': FontAwesomeIcons.wrench,
    'road': FontAwesomeIcons.road,
    'traffic-light': FontAwesomeIcons.trafficLight,
    'gauge-high': FontAwesomeIcons.gaugeHigh,
  };

  static const FaIconData _fallback = FontAwesomeIcons.carSide;

  /// Letters and digits mean the value is an icon name, not a glyph.
  static final RegExp _notAGlyph = RegExp('[A-Za-z0-9]');

  @override
  Widget build(BuildContext context) {
    final FaIconData? icon = _icons[name];
    if (icon != null) return FaIcon(icon, size: size, color: color);

    final glyph = name?.trim() ?? '';
    if (glyph.isEmpty || _notAGlyph.hasMatch(glyph)) {
      return FaIcon(_fallback, size: size, color: color);
    }

    return SizedBox.square(
      dimension: size,
      child: ColorFiltered(
        colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
        child: FittedBox(
          fit: BoxFit.contain,
          child: Text(glyph, style: TextStyle(fontSize: size)),
        ),
      ),
    );
  }
}
