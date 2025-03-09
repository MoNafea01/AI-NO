class VSSubgroup {
  ///Small data class
  ///
  ///Used to create a sub group in contextMenu
  ///
  ///Creates contextNodeBuilders and _nodeBuilders inside VSNodeSerializationManager
  VSSubgroup({
    required this.name,
    required this.subgroup,
  });

  final String name;
  final List<dynamic> subgroup;
}
