import 'dart:async';

import 'package:ai_gen/node_package/data/standard_interfaces/vs_dynamic_interface.dart';
import 'package:ai_gen/node_package/data/vs_node_data.dart';
import 'package:flutter/material.dart';

///Base interface class
///Used for base input and output interface
abstract class VSInterfaceData {
  VSInterfaceData({
    required this.type,
    this.interfaceIconBuilder,
    String? title,
    this.toolTip,
  }) : _title = title;

  ///The color this interface will display in the UI
  Color get interfaceColor;

  ///Can be used to insert you own interfaceIcon widget
  ///
  ///You need to pass anchor as the widget key for the lines to work correctly
  Widget Function(
    BuildContext context,
    GlobalKey anchor,
    VSInterfaceData data,
  )? interfaceIconBuilder;

  ///The type of this interface
  ///
  ///Important for deserialization
  final String type;

  ///The title displayed on the interface
  ///
  ///Usefull for localization
  String get title => _title ?? type;
  set title(String data) => _title = data;
  String? _title;

  ///A tooltip displayed on the widget
  final String? toolTip;

  ///The parent node of this interface
  VSNodeData? nodeData;

  ///The current offset of the interface relative to the origin of the parent (Top-Left corner)
  Offset? widgetOffset;
}

///Base input interface
///
///Makes sure only correct types can be connected
abstract class VSInputData extends VSInterfaceData {
  VSInputData({
    required super.type,
    super.interfaceIconBuilder,
    super.title,
    super.toolTip,
    VSOutputData? initialConnection,
  }) {
    connectedInterface = initialConnection;
  }

  ///The Icon displayed for this interface
  ///
  ///Will use [interfaceColor] by default
  ///
  ///Will switch between [Icons.radio_button_unchecked] and [Icons.radio_button_checked] depending on if a node is connected to this interface
  Widget getInterfaceIcon({
    required BuildContext context,
    required GlobalKey anchor,
  }) {
    if (interfaceIconBuilder != null) {
      return interfaceIconBuilder!(context, anchor, this);
    }

    final icon = connectedInterface == null
        ? Icons.radio_button_unchecked
        : Icons.radio_button_checked;

    return Icon(
      icon,
      key: anchor,
      color: interfaceColor,
      size: 15,
    );
  }

  ///The currently connected interface of this input
  ///
  ///Returns null if no interface is connected
  VSOutputData? get connectedInterface => _connectedInterface;
  VSOutputData? _connectedInterface;
  set connectedInterface(VSOutputData? data) {
    if (data == null || acceptInput(data)) {
      _connectedInterface = data;
      nodeData?.onUpdatedConnection?.call(this);
    }
  }

  ///The list of types this input will interface with
  ///
  ///The supplied type needs to extend [VSOutputData]
  List<Type> get acceptedTypes;
  bool acceptInput(VSOutputData data) {
    return acceptedTypes.contains(data.runtimeType) ||
        data.runtimeType == VSDynamicOutputData;
  }

  Map<String, dynamic> toJson() {
    return {
      "name": type,
      "connectedNode": connectedInterface?.toJson(),
    };
  }
}

///Base output interface
abstract class VSOutputData<T> extends VSInterfaceData {
  VSOutputData({
    required super.type,
    super.interfaceIconBuilder,
    super.title,
    super.toolTip,
    this.outputFunction,
  });

  ///The Icon displayed for this interface
  ///
  ///Will use [interfaceColor] and [Icons.circle] by default
  Widget getInterfaceIcon({
    required BuildContext context,
    required GlobalKey anchor,
  }) {
    if (interfaceIconBuilder != null) {
      return interfaceIconBuilder!(context, anchor, this);
    }

    return Icon(
      Icons.square,  //-----------------
      key: anchor,
      color: interfaceColor,
      size: 15,
    );
  }

  ///The function this interface will execute on evaluation
  final FutureOr<T> Function(Map<String, dynamic>)? outputFunction;

  Map<String, dynamic> toJson() {
    return {
      "name": type,
      "nodeData": nodeData?.id,
    };
  }
}
