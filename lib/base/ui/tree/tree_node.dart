import 'dart:math' show pi;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

import '../../theme.dart';
import 'tree_view.dart';
import 'tree_view_theme.dart';
import 'expander_theme_data.dart';
import 'models/script_data.dart';

const double _kBorderWidth = 0.75;

/// Defines the [TreeNode] widget.
///
/// This widget is used to display a tree node and its children. It requires
/// a single [ScriptData] value. It uses this node to display the state of the
/// widget. It uses the [TreeViewTheme] to handle the appearance and the
/// [TreeView] properties to handle to user actions.
///
/// __This class should not be used directly!__
/// The [TreeView] and [TreeViewController] handlers the data and rendering
/// of the nodes.
class TreeNode extends ConsumerStatefulWidget {
  /// The node object used to display the widget state
  final ScriptData node;

  const TreeNode({Key? key, required this.node}) : super(key: key);

  @override
  _TreeNodeState createState() => _TreeNodeState();
}

class _TreeNodeState extends ConsumerState<TreeNode> with SingleTickerProviderStateMixin {
  static final Animatable<double> _easeInTween = CurveTween(curve: Curves.easeIn);

  late AnimationController _controller;
  late Animation<double> _heightFactor;
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: Duration(milliseconds: 200), vsync: this);
    _heightFactor = _controller.drive(_easeInTween);
    _isExpanded = widget.node.expanded;
    if (_isExpanded) _controller.value = 1.0;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    TreeView? _treeView = TreeView.of(context);
    _controller.duration = _treeView!.theme.expandSpeed;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(TreeNode oldWidget) {
    if (widget.node.expanded != oldWidget.node.expanded) {
      setState(() {
        _isExpanded = widget.node.expanded;
        if (_isExpanded) {
          _controller.forward();
        } else {
          _controller.reverse().then<void>((void value) {
            if (!mounted) return;
            setState(() {});
          });
        }
      });
    } else if (widget.node != oldWidget.node) {
      setState(() {});
    }
    super.didUpdateWidget(oldWidget);
  }

  void _handleExpand() {
    TreeView? _treeView = TreeView.of(context);
    assert(_treeView != null, 'TreeView must exist in context');
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _controller.forward();
      } else {
        _controller.reverse().then<void>((void value) {
          if (!mounted) return;
          setState(() {});
        });
      }
    });
    if (_treeView!.onExpansionChanged != null) _treeView.onExpansionChanged!(widget.node.key, _isExpanded);
  }

  void _handleDeleteSelf() {
    TreeView? _treeView = TreeView.of(context);
    if (_treeView!.onDeleteSelfClick != null) _treeView.onDeleteSelfClick!(widget.node);
  }

  void _handleTap() {
    TreeView? _treeView = TreeView.of(context);
    assert(_treeView != null, 'TreeView must exist in context');
    if (_treeView!.onNodeTap != null) {
      _treeView.onNodeTap!(widget.node.key);
    }
  }

  void _handleDoubleTap() {
    TreeView? _treeView = TreeView.of(context);
    assert(_treeView != null, 'TreeView must exist in context');
    if (_treeView!.onNodeDoubleTap != null) {
      _treeView.onNodeDoubleTap!(widget.node.key);
    }
  }

  Widget _buildNodeExpander() {
    TreeView? _treeView = TreeView.of(context);
    assert(_treeView != null, 'TreeView must exist in context');
    TreeViewTheme _theme = _treeView!.theme;
    if (_theme.expanderTheme.type == ExpanderType.none) return Container();
    return widget.node.isParent
        ? GestureDetector(
            onTap: () => _handleExpand(),
            child: _TreeNodeExpander(
              speed: _controller.duration!,
              expanded: widget.node.expanded,
              themeData: _theme.expanderTheme,
            ),
          )
        : Container(width: _theme.expanderTheme.size);
  }

  Widget _buildNodeIcon() {
    TreeView? _treeView = TreeView.of(context);
    assert(_treeView != null, 'TreeView must exist in context');
    TreeViewTheme _theme = _treeView!.theme;
    bool isSelected = _treeView.controller.selectedKey != null && _treeView.controller.selectedKey == widget.node.key;
    return Container(
      alignment: Alignment.center,
      width: _theme.iconTheme.size! + _theme.iconPadding,
      child: widget.node.isParent
          ? Icon(
              widget.node.expanded ? CupertinoIcons.folder_badge_minus : CupertinoIcons.folder_badge_plus,
              size: _theme.iconTheme.size,
              color: isSelected ? ref.watch(themeProvider).primaryColor : ref.watch(themeProvider).themeColor.titleColor(),
            )
          : const SizedBox.shrink(),
    );
  }

  Widget _buildNodeLabel() {
    TreeView? _treeView = TreeView.of(context);
    assert(_treeView != null, 'TreeView must exist in context');
    TreeViewTheme _theme = _treeView!.theme;
    final icon = _buildNodeIcon();
    return Container(
      padding: EdgeInsets.symmetric(
        vertical: _theme.verticalSpacing ?? (_theme.dense ? 10 : 15),
        horizontal: 0,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          icon,
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                vertical: 5,
              ),
              child: Text(
                widget.node.title,
                style: widget.node.isParent
                    ? TextStyle(
                        fontSize: 16,
                        color: ref.watch(themeProvider).themeColor.titleColor(),
                      )
                    : TextStyle(
                        fontSize: 16,
                        color: ref.watch(themeProvider).themeColor.titleColor(),
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNodeWidget() {
    TreeView? _treeView = TreeView.of(context);
    assert(_treeView != null, 'TreeView must exist in context');
    TreeViewTheme _theme = _treeView!.theme;
    bool isSelected = _treeView.controller.selectedKey != null && _treeView.controller.selectedKey == widget.node.key;
    bool canSelectParent = _treeView.allowParentSelect;
    final arrowContainer = _buildNodeExpander();
    final labelContainer = _treeView.nodeBuilder != null ? _treeView.nodeBuilder!(context, widget.node) : _buildNodeLabel();
    Widget _tappable = _treeView.onNodeDoubleTap != null
        ? GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: _handleTap,
            onDoubleTap: _handleDoubleTap,
            child: labelContainer,
          )
        : GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: _handleTap,
            child: labelContainer,
          );
    if (widget.node.isParent) {
      if (_treeView.supportParentDoubleTap && canSelectParent) {
        _tappable = GestureDetector(
          onTap: canSelectParent ? _handleTap : _handleExpand,
          behavior: HitTestBehavior.opaque,
          onDoubleTap: () {
            _handleExpand();
            _handleDoubleTap();
          },
          child: labelContainer,
        );
      } else if (_treeView.supportParentDoubleTap) {
        _tappable = GestureDetector(
          onTap: _handleExpand,
          onDoubleTap: _handleDoubleTap,
          behavior: HitTestBehavior.opaque,
          child: labelContainer,
        );
      } else {
        _tappable = GestureDetector(
          onTap: canSelectParent ? _handleTap : _handleExpand,
          behavior: HitTestBehavior.opaque,
          child: labelContainer,
        );
      }
    }
    return Container(
      color: isSelected ? _theme.colorScheme.primary : null,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: _theme.expanderTheme.position == ExpanderPosition.end
            ? <Widget>[
                Expanded(
                  child: _tappable,
                ),
                arrowContainer,
              ]
            : <Widget>[
                const SizedBox(
                  width: 10,
                ),
                Expanded(
                  child: _tappable,
                ),
              ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    TreeView? _treeView = TreeView.of(context);
    assert(_treeView != null, 'TreeView must exist in context');
    final bool closed = (!_isExpanded || !widget.node.expanded) && _controller.isDismissed;
    final nodeWidget = _buildNodeWidget();
    return widget.node.isParent
        ? AnimatedBuilder(
            animation: _controller.view,
            builder: (BuildContext context, Widget? child) {
              return Slidable(
                enabled: closed,
                key: ValueKey(widget.node.key),
                endActionPane: ActionPane(
                  motion: const StretchMotion(),
                  extentRatio: 0.15,
                  children: [
                    SlidableAction(
                      backgroundColor: const Color(0xffEA4D3E),
                      onPressed: (_) {
                        WidgetsBinding.instance.endOfFrame.then((timeStamp) {
                          _handleDeleteSelf();
                        });
                      },
                      foregroundColor: Colors.white,
                      icon: CupertinoIcons.delete,
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    nodeWidget,
                    ClipRect(
                      child: Align(
                        heightFactor: _heightFactor.value,
                        child: child,
                      ),
                    ),
                  ],
                ),
              );
            },
            child: closed
                ? null
                : Container(
                    margin: EdgeInsets.only(left: _treeView!.theme.horizontalSpacing ?? _treeView.theme.iconTheme.size!),
                    child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: widget.node.children.map((ScriptData node) {
                          return TreeNode(node: node);
                        }).toList()),
                  ),
          )
        : Slidable(
            enabled: true,
            key: ValueKey(widget.node.key),
            endActionPane: ActionPane(
              motion: const StretchMotion(),
              extentRatio: 0.15,
              children: [
                SlidableAction(
                  backgroundColor: const Color(0xffEA4D3E),
                  onPressed: (_) {
                    WidgetsBinding.instance.endOfFrame.then((timeStamp) {
                      _handleDeleteSelf();
                    });
                  },
                  foregroundColor: Colors.white,
                  icon: CupertinoIcons.delete,
                ),
              ],
            ),
            child: nodeWidget);
  }
}

class _TreeNodeExpander extends StatefulWidget {
  final ExpanderThemeData themeData;
  final bool expanded;
  final Duration _expandSpeed;

  const _TreeNodeExpander({
    required Duration speed,
    required this.themeData,
    required this.expanded,
  }) : _expandSpeed = speed;

  @override
  _TreeNodeExpanderState createState() => _TreeNodeExpanderState();
}

class _TreeNodeExpanderState extends State<_TreeNodeExpander> with SingleTickerProviderStateMixin {
  late Animation<double> animation;
  late AnimationController controller;

  @override
  void initState() {
    bool isEnd = widget.themeData.position == ExpanderPosition.end;
    if (widget.themeData.type != ExpanderType.plusMinus) {
      controller = AnimationController(
        duration: widget.themeData.animated
            ? isEnd
                ? widget._expandSpeed * 0.625
                : widget._expandSpeed
            : Duration(milliseconds: 0),
        vsync: this,
      );
      animation = Tween<double>(
        begin: 0,
        end: isEnd ? 180 : 90,
      ).animate(controller);
    } else {
      controller = AnimationController(duration: Duration(milliseconds: 0), vsync: this);
      animation = Tween<double>(begin: 0, end: 0).animate(controller);
    }
    super.initState();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(_TreeNodeExpander oldWidget) {
    if (widget.themeData != oldWidget.themeData || widget.expanded != oldWidget.expanded) {
      bool isEnd = widget.themeData.position == ExpanderPosition.end;
      setState(() {
        if (widget.themeData.type != ExpanderType.plusMinus) {
          controller.duration = widget.themeData.animated
              ? isEnd
                  ? widget._expandSpeed * 0.625
                  : widget._expandSpeed
              : Duration(milliseconds: 0);
          animation = Tween<double>(
            begin: 0,
            end: isEnd ? 180 : 90,
          ).animate(controller);
        } else {
          controller.duration = Duration(milliseconds: 0);
          animation = Tween<double>(begin: 0, end: 0).animate(controller);
        }
      });
    }
    super.didUpdateWidget(oldWidget);
  }

  Color? _onColor(Color? color) {
    if (color != null) {
      if (color.computeLuminance() > 0.6) {
        return Colors.black;
      } else {
        return Colors.white;
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    IconData _arrow;
    double _iconSize = 16;
    double _borderWidth = 0;
    BoxShape _shapeBorder = BoxShape.rectangle;
    Color _backColor = Colors.transparent;
    Color? _iconColor = widget.themeData.color ?? Theme.of(context).iconTheme.color;
    switch (widget.themeData.modifier) {
      case ExpanderModifier.none:
        break;
      case ExpanderModifier.circleFilled:
        _shapeBorder = BoxShape.circle;
        _backColor = widget.themeData.color ?? Colors.black;
        _iconColor = _onColor(_backColor);
        break;
      case ExpanderModifier.circleOutlined:
        _borderWidth = _kBorderWidth;
        _shapeBorder = BoxShape.circle;
        break;
      case ExpanderModifier.squareFilled:
        _backColor = widget.themeData.color ?? Colors.black;
        _iconColor = _onColor(_backColor);
        break;
      case ExpanderModifier.squareOutlined:
        _borderWidth = _kBorderWidth;
        break;
    }
    // case ExpanderType.chevron:
    // _arrow = Icons.expand_more;
    // break;
    // case ExpanderType.arrow:
    //   _arrow = Icons.arrow_downward;
    //   _iconSize = widget.themeData.size > 20 ? widget.themeData.size - 8 : widget.themeData.size;
    //   break;
    // case ExpanderType.none:
    // case ExpanderType.caret:
    //   _arrow = Icons.arrow_drop_down;
    //   break;
    // case ExpanderType.plusMinus:
    _arrow = widget.expanded ? Icons.remove : Icons.add;
    //   break;
    // }

    Icon _icon = Icon(
      _arrow,
      size: _iconSize,
      color: _iconColor,
    );

    if (widget.expanded) {
      controller.reverse();
    } else {
      controller.forward();
    }
    return Container(
      width: widget.themeData.size + 2,
      height: widget.themeData.size + 2,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: _shapeBorder,
        border: _borderWidth == 0
            ? null
            : Border.all(
                width: _borderWidth,
                color: widget.themeData.color ?? Colors.black,
              ),
        color: _backColor,
      ),
      child: AnimatedBuilder(
        animation: controller,
        child: _icon,
        builder: (context, child) {
          return Transform.rotate(
            angle: animation.value * (-pi / 180),
            child: child,
          );
        },
      ),
    );
  }
}
