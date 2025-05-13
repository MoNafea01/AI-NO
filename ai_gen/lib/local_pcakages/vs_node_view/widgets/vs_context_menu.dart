import 'package:ai_gen/core/utils/themes/app_colors.dart';
import 'package:ai_gen/core/utils/themes/textstyles.dart';
import 'package:flutter/material.dart';

import '../data/vs_node_data_provider.dart';

/// A context menu widget for creating new nodes in the visual scripting interface.
///
/// This widget displays a hierarchical menu of available node types that can be
/// created. It supports both direct node creation and nested submenus for
/// organizing node types into categories.
class VSContextMenu extends StatefulWidget {
  /// Creates a new [VSContextMenu] instance.
  ///
  /// [nodeBuilders] is required and contains the map of available node builders.
  /// [vsNodeDataProvider] is optional and used to create new nodes.
  const VSContextMenu({
    required this.nodeBuilders,
    this.vsNodeDataProvider,
    super.key,
  });

  /// The provider used to create new nodes and manage the context menu state
  final VSNodeDataProvider? vsNodeDataProvider;

  /// A map of node builders organized in a hierarchical structure:
  /// ```dart
  /// {
  ///   'Subgroup': {
  ///     'nodeName': NodeBuilder
  ///   },
  ///   'nodeName': NodeBuilder
  /// }
  /// ```
  final Map<String, dynamic> nodeBuilders;

  @override
  State<VSContextMenu> createState() => _VSContextMenuState();
}

/// The state for the [VSContextMenu] widget.
///
/// This state class manages the menu's navigation state and item building.
class _VSContextMenuState extends State<VSContextMenu> {
  /// The current level of node builders being displayed
  late Map<String, dynamic> _currentNodeBuilders;

  /// The padding around menu items
  static const EdgeInsets _menuPadding = EdgeInsets.all(8.0);

  /// The spacing between menu items
  static const double _menuItemSpacing = 12.0;

  /// The size of the submenu arrow icon
  static const double _arrowIconSize = 12.0;

  @override
  void initState() {
    super.initState();
    _currentNodeBuilders =
        widget.vsNodeDataProvider?.nodeBuildersMap ?? widget.nodeBuilders;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {}, // Prevents tap from propagating to background
      child: Card(
        color: AppColors.grey100,
        surfaceTintColor: AppColors.grey100,
        elevation: 8,
        child: Padding(
          padding: _menuPadding,
          child: IntrinsicWidth(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: _buildMenuItems(),
            ),
          ),
        ),
      ),
    );
  }

  /// Builds the list of menu items based on the current node builders
  List<Widget> _buildMenuItems() {
    final List<Widget> items = [];
    final entries = _currentNodeBuilders.entries;

    for (final entry in entries) {
      items.add(_buildMenuItem(entry));

      // Add divider between items, but not after the last one
      if (entry.key != entries.last.key) {
        items.add(const Divider());
      }
    }

    return items;
  }

  /// Builds a single menu item based on whether it's a submenu or a node builder
  Widget _buildMenuItem(MapEntry<String, dynamic> entry) {
    if (entry.value is Map) {
      return _buildSubmenuItem(entry);
    } else {
      return _buildNodeItem(entry);
    }
  }

  /// Builds a submenu item that navigates to a deeper level of node builders
  Widget _buildSubmenuItem(MapEntry<String, dynamic> entry) {
    return TextButton(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.blackText,
        iconColor: AppColors.blackText,
      ),
      onPressed: () => setState(() {
        _currentNodeBuilders = entry.value;
      }),
      child: Row(
        children: [
          const Icon(
            Icons.arrow_forward_ios_rounded,
            size: _arrowIconSize,
            color: Colors.black,
          ),
          const SizedBox(width: _menuItemSpacing),
          Text(entry.key, style: AppTextStyles.black14Normal),
        ],
      ),
    );
  }

  /// Builds a node item that creates a new node when pressed
  Widget _buildNodeItem(MapEntry<String, dynamic> entry) {
    return TextButton(
      onPressed: () {
        final dataProvider =
            widget.vsNodeDataProvider ?? VSNodeDataProvider.of(context);
        dataProvider.createNodeFromContext(entry.value);
        dataProvider.closeContextMenu();
      },
      child: Text(entry.key, style: AppTextStyles.black14Normal),
    );
  }
}
