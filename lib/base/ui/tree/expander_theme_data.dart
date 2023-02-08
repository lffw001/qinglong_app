import 'package:flutter/widgets.dart';

const double _kDefaultExpanderSize = 30.0;

/// Defines whether expander icon is shown on the
/// left or right side of the parent node label.
enum ExpanderPosition {
  start,
  end,
}

/// Defines the type expander icon displayed. All
/// types except the plus-minus type will be animated
enum ExpanderType {
  none,
  caret,
  arrow,
  chevron,
  plusMinus,
}

/// Defines whether expander icon has a circle or square shape
/// and whether it is outlined or filled.
enum ExpanderModifier {
  none,
  circleFilled,
  circleOutlined,
  squareFilled,
  squareOutlined,
}

/// Defines the appearance of the expander icons.
///
/// Used by [TreeViewTheme] to control the appearance of the expander icons for a
/// parent tree node in the [TreeView] widget.
class ExpanderThemeData {
  /// The [ExpanderPosition] for expander icon.
  final ExpanderPosition position;

  /// The [ExpanderType] for expander icon.
  final ExpanderType type;

  /// The size for expander icon.
  final double size;

  /// The color for expander icon.
  final Color? color;

  /// The [ExpanderModifier] for expander icon.
  final ExpanderModifier modifier;

  /// The animation state for expander icon. It determines whether
  /// the icon animates when changing states
  final bool animated;

  const ExpanderThemeData({
    this.color,
    this.position: ExpanderPosition.start,
    this.type: ExpanderType.caret,
    this.size: _kDefaultExpanderSize,
    this.modifier: ExpanderModifier.none,
    this.animated: true,
  });

  /// Creates an expander icon theme with some reasonable default values.
  ///
  /// The [color] is black,
  /// the [position] is [ExpanderPosition.start],
  /// the [type] is [ExpanderType.caret],
  /// the [modifier] is [ExpanderModifier.none],
  /// the [animated] property is true,
  /// and the [size] is 30.0.
  const ExpanderThemeData.fallback()
      : color = const Color(0xFF000000),
        position = ExpanderPosition.start,
        type = ExpanderType.caret,
        modifier = ExpanderModifier.none,
        animated = true,
        size = _kDefaultExpanderSize;

  /// Creates a copy of this theme but with the given fields replaced with
  /// the new values.
  ExpanderThemeData copyWith({
    Color? color,
    ExpanderType? type,
    ExpanderPosition? position,
    ExpanderModifier? modifier,
    bool? animated,
    double? size,
  }) {
    return ExpanderThemeData(
      color: color ?? this.color,
      type: type ?? this.type,
      position: position ?? this.position,
      modifier: modifier ?? this.modifier,
      size: size ?? this.size,
      animated: animated ?? this.animated,
    );
  }

  /// Returns a new theme that matches this expander theme but with some values
  /// replaced by the non-null parameters of the given icon theme. If the given
  /// expander theme is null, simply returns this theme.
  ExpanderThemeData merge(ExpanderThemeData? other) {
    if (other == null) return this;
    return copyWith(
      color: other.color,
      type: other.type,
      position: other.position,
      modifier: other.modifier,
      animated: other.animated,
      size: other.size,
    );
  }

  ExpanderThemeData resolve(BuildContext context) => this;

  @override
  bool operator ==(Object other) {
    if (other.runtimeType != runtimeType) return false;
    return other is ExpanderThemeData &&
        other.color == color &&
        other.position == position &&
        other.type == type &&
        other.modifier == modifier &&
        other.animated == animated &&
        other.size == size;
  }

  @override
  int get hashCode =>
      hashValues(color, position, type, size, modifier, animated);
}
