import 'dart:convert';
import 'dart:ui';

import 'package:flutter/widgets.dart';
import 'package:json_conversion_annotation/json_conversion_annotation.dart';

import '../tree_node.dart';
import '../utilities.dart';

/// Defines the data used to display a [TreeNode].
///
/// Used by [TreeView] to display a [TreeNode].
///
/// This object allows the creation of key, label and icon to display
/// a node on the [TreeView] widget. The key and label properties are
/// required. The key is needed for events that occur on the generated
/// [TreeNode]. It should always be unique.
@JsonConversion()
class ScriptData {
  final String key;

  final String title;
  final String type;

  final bool expanded;

  final List<ScriptData> children;

  final String parent;

  ScriptData({
    required this.key,
    required this.title,
    required this.type,
    this.children = const [],
    this.expanded = false,
    this.parent = "",
  });

  static ScriptData jsonConversion(Map<String, dynamic> json) {
    return ScriptData.fromMap(json);
  }

  /// Creates a [ScriptData] from a Map<String, dynamic> map. The map
  /// should contain a "label" value. If the key value is
  /// missing, it generates a unique key.
  /// If the expanded value, if present, can be any 'truthful'
  /// value. Excepted values include: 1, yes, true and their
  /// associated string values.
  static ScriptData fromMap(Map<String, dynamic> map) {
    String? _key = map['key'];
    String? title = map['title'];

    String? parent = map['parent'];
    List<ScriptData> _children = [];

    // if (map['icon'] != null) {
    // int _iconData = int.parse(map['icon']);
    // if (map['icon'].runtimeType == String) {
    //   _iconData = int.parse(map['icon']);
    // } else if (map['icon'].runtimeType == double) {
    //   _iconData = (map['icon'] as double).toInt();
    // } else {
    //   _iconData = map['icon'];
    // }
    // _icon = const IconData(_iconData);
    // }
    if (map['children'] != null) {
      List<Map<String, dynamic>> _childrenMap = List.from(map['children']);
      _children = _childrenMap.map((Map<String, dynamic> child) => ScriptData.fromMap(child)).toList();
    }
    String? type = map['type'];

    if (type == null || type.isEmpty) {
      if (_children.isNotEmpty) {
        type = "directory";
      } else {
        type = "file";
      }
    }

    return ScriptData(
      key: '$_key',
      title: title ?? "",
      type: type ?? "",
      expanded: false,
      parent: parent ?? "",
      children: _children,
    );
  }

  /// Creates a copy of this object but with the given fields
  /// replaced with the new values.
  ScriptData copyWith({
    String? key,
    String? title,
    String? type,
    List<ScriptData>? children,
    bool? expanded,
    String? parent,
    IconData? icon,
    Color? iconColor,
    Color? selectedIconColor,
  }) =>
      ScriptData(
        key: key ?? this.key,
        title: title ?? this.title,
        type: type ?? this.type,
        expanded: expanded ?? this.expanded,
        parent: parent ?? this.parent,
        children: children ?? this.children,
      );

  /// Whether this object has children [ScriptData].
  bool get isParent => type == "directory";

  @override
  String toString() {
    return "";
  }

  @override
  int get hashCode {
    return hashValues(
      key,
      title,
      expanded,
      parent,
      children,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other.runtimeType != runtimeType) return false;
    return other is ScriptData &&
        other.key == key &&
        other.title == title &&
        other.expanded == expanded &&
        other.parent == parent &&
        other.children.length == children.length;
  }
}
