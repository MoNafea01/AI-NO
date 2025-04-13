import 'package:flutter/material.dart';

class ParamNumInput extends StatefulWidget {
  ParamNumInput({required this.value, super.key});

  double value;
  @override
  State<ParamNumInput> createState() => _ParamNumInputState();
}

class _ParamNumInputState extends State<ParamNumInput> {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.grey[300],
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(4),
              bottomLeft: Radius.circular(4),
            ),
          ),
          child: IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              setState(() {
                widget.value += 0.1;
              });
            },
          ),
        ),
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            alignment: Alignment.center,
            color: Colors.white,
            height: 40,
            child: Text(
              widget.value.toStringAsFixed(1),
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.grey[300],
            borderRadius: const BorderRadius.only(
              topRight: Radius.circular(4),
              bottomRight: Radius.circular(4),
            ),
          ),
          child: IconButton(
            icon: const Icon(Icons.remove),
            onPressed: () {
              setState(() {
                if (widget.value > 0.1) {
                  widget.value -= 0.1;
                }
              });
            },
          ),
        ),
      ],
    );
  }
}
