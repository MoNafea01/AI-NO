import 'package:flutter/material.dart';

class ParamTextField extends StatefulWidget {
  ParamTextField({required this.paramValue, super.key});

  String paramValue;
  @override
  State<ParamTextField> createState() => _ParamTextFieldState();
}

class _ParamTextFieldState extends State<ParamTextField> {
  late final TextEditingController controller;
  @override
  void initState() {
    // TODO: implement initState
    controller = TextEditingController(text: widget.paramValue);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      decoration: const InputDecoration(
        border: InputBorder.none,
        isDense: true,
        contentPadding: EdgeInsets.symmetric(horizontal: 0, vertical: 5),
      ),
      onChanged: (value) {
        setState(() {
          widget.paramValue = value;
        });
      },
    );
  }
}
