import 'package:flutter/material.dart';

import 'expander_theme_data.dart';
import 'tree_node.dart';

const double _kDefaultLevelPadding = 20;
const int _kExpandSpeed = 130;

/// Defines the appearance of the [TreeView].
///
/// Used by [TreeView] to control the appearance of the sub-widgets
/// in the [TreeView] widget.
class TreeViewTheme {
  /// The [ColorScheme] for [TreeView] widget.
  final ColorScheme colorScheme;

  /// The horizontal padding for the children of a [TreeNode] parent.
  final double levelPadding;

  /// Whether the [TreeNode] is vertically dense.
  ///
  /// If this property is null then its value is based on [ListTileTheme.dense].
  ///
  /// A dense [TreeNode] defaults to a smaller height.
  final bool dense;

  /// Vertical spacing between tabs.
  /// If this property is null then [dense] attribute will work and vice versa.
  final double? verticalSpacing;

  /// Horizontal spacing between tabs.
  /// If this property is null then horizontal spacing between tabs is default [_treeView.theme.iconTheme.size + 5]
  final double? horizontalSpacing;

  /// Horizontal padding for node icons.
  final double iconPadding;

  /// The default appearance theme for [TreeNode] icons.
  final IconThemeData iconTheme;

  /// The appearance theme for [TreeNode] expander icons.
  final ExpanderThemeData expanderTheme;

  /// The text style for child [TreeNode] text.
  final TextStyle labelStyle;

  /// The text style for parent [TreeNode] text.
  final TextStyle parentLabelStyle;

  /// The text overflow for child [TreeNode] text.
  /// If this property is null then [softWrap] is true;
  final TextOverflow? labelOverflow;

  /// The text overflow for parent [TreeNode] text.
  /// If this property is null then [softWrap] is true;
  final TextOverflow? parentLabelOverflow;

  /// the speed at which expander icon animates.
  final Duration expandSpeed;

  const TreeViewTheme({
    this.colorScheme: const ColorScheme.light(),
    this.iconTheme: const IconThemeData.fallback(),
    this.expanderTheme: const ExpanderThemeData.fallback(),
    this.labelStyle: const TextStyle(),
    this.parentLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
    this.labelOverflow,
    this.parentLabelOverflow,
    this.levelPadding: _kDefaultLevelPadding,
    this.dense: true,
    this.verticalSpacing,
    this.horizontalSpacing,
    this.iconPadding: 8,
    this.expandSpeed: const Duration(milliseconds: _kExpandSpeed),
  });

  /// Creates a [TreeView] theme with some reasonable default values.
  ///
  /// The [colorScheme] is [ColorScheme.light],
  /// the [iconTheme] is [IconThemeData.fallback],
  /// the [expanderTheme] is [ExpanderThemeData.fallback],
  /// the [labelStyle] is the default [TextStyle],
  /// the [parentLabelStyle] is the default [TextStyle] with bold weight,
  /// and the default [levelPadding] is 20.0.
  const TreeViewTheme.fallback()
      : colorScheme = const ColorScheme.light(),
        iconTheme = const IconThemeData.fallback(),
        expanderTheme = const ExpanderThemeData.fallback(),
        labelStyle = const TextStyle(),
        parentLabelStyle = const TextStyle(fontWeight: FontWeight.bold),
        labelOverflow = null,
        parentLabelOverflow = null,
        dense = true,
        verticalSpacing = null,
        horizontalSpacing = null,
        iconPadding = 8,
        levelPadding = _kDefaultLevelPadding,
        expandSpeed = const Duration(milliseconds: _kExpandSpeed);

  /// Creates a copy of this theme but with the given fields replaced with
  /// the new values.
  TreeViewTheme copyWith({
    ColorScheme? colorScheme,
    IconThemeData? iconTheme,
    ExpanderThemeData? expanderTheme,
    TextStyle? labelStyle,
    TextStyle? parentLabelStyle,
    TextOverflow? labelOverflow,
    TextOverflow? parentLabelOverflow,
    bool? dense,
    double? verticalSpacing,
    double? horizontalSpacing,
    double? iconPadding,
    double? levelPadding,
  }) {
    return TreeViewTheme(
        colorScheme: colorScheme ?? this.colorScheme,
        levelPadding: levelPadding ?? this.levelPadding,
        iconPadding: iconPadding ?? this.iconPadding,
        iconTheme: iconTheme ?? this.iconTheme,
        expanderTheme: expanderTheme ?? this.expanderTheme,
        labelStyle: labelStyle ?? this.labelStyle,
        dense: dense ?? this.dense,
        verticalSpacing: verticalSpacing ?? this.verticalSpacing,
        horizontalSpacing: horizontalSpacing ?? this.horizontalSpacing,
        parentLabelStyle: parentLabelStyle ?? this.parentLabelStyle,
        labelOverflow: labelOverflow ?? this.labelOverflow,
        parentLabelOverflow: parentLabelOverflow ?? this.parentLabelOverflow);
  }

  /// Returns a new theme that matches this [TreeView] theme but with some values
  /// replaced by the non-null parameters of the given icon theme. If the given
  /// [TreeViewTheme] is null, simply returns this theme.
  TreeViewTheme merge(TreeViewTheme other) {
    return copyWith(
        colorScheme: other.colorScheme,
        levelPadding: other.levelPadding,
        iconPadding: other.iconPadding,
        iconTheme: other.iconTheme,
        expanderTheme: other.expanderTheme,
        labelStyle: other.labelStyle,
        dense: other.dense,
        verticalSpacing: other.verticalSpacing,
        horizontalSpacing: other.horizontalSpacing,
        parentLabelStyle: other.parentLabelStyle,
        labelOverflow: other.labelOverflow,
        parentLabelOverflow: other.parentLabelOverflow);
  }

  TreeViewTheme resolve(BuildContext context) => this;

  Duration get quickExpandSpeed =>
      Duration(milliseconds: (expandSpeed.inMilliseconds * 1.6).toInt());

  @override
  int get hashCode {
    return hashValues(
        colorScheme,
        levelPadding,
        iconPadding,
        iconTheme,
        expanderTheme,
        labelStyle,
        dense,
        verticalSpacing,
        horizontalSpacing,
        parentLabelStyle,
        labelOverflow,
        parentLabelOverflow);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other.runtimeType != runtimeType) return false;
    return other is TreeViewTheme &&
        other.colorScheme == colorScheme &&
        other.levelPadding == levelPadding &&
        other.iconPadding == iconPadding &&
        other.iconTheme == iconTheme &&
        other.expanderTheme == expanderTheme &&
        other.labelStyle == labelStyle &&
        other.dense == dense &&
        other.verticalSpacing == verticalSpacing &&
        other.horizontalSpacing == horizontalSpacing &&
        other.parentLabelStyle == parentLabelStyle &&
        other.labelOverflow == labelOverflow &&
        other.parentLabelOverflow == parentLabelOverflow;
  }
}
