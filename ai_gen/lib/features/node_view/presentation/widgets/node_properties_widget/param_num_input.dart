import 'package:ai_gen/core/themes/app_colors.dart';
import 'package:flutter/material.dart';

class ParamNumInput extends StatefulWidget {
  ParamNumInput({required this.value, super.key});

  double value;
  @override
  State<ParamNumInput> createState() => _ParamNumInputState();
}

class _ParamNumInputState extends State<ParamNumInput> {
  late TextEditingController controller;
  @override
  void initState() {
    controller = TextEditingController(text: widget.value.toStringAsFixed(1));
    super.initState();
  }

  @override
  void didUpdateWidget(covariant ParamNumInput oldWidget) {
    controller = TextEditingController(text: widget.value.toStringAsFixed(1));
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _customButton(
          icon: Icons.add,
          onTap: () => widget.value += 0.1,
        ),
        _textField(),
        _customButton(
          icon: Icons.remove,
          onTap: () {
            if (widget.value > 0.1) {
              widget.value -= 0.1;
            }
          },
        ),
      ],
    );
  }

  Widget _textField() {
    return Expanded(
      child: TextField(
        controller: controller,
        style: const TextStyle(fontSize: 16),
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        decoration: const InputDecoration(
          border: InputBorder.none,
          isDense: true,
        ),
        onChanged: (value) {
          final parsedValue = double.tryParse(value);
          if (parsedValue != null) {
            setState(() {
              widget.value = parsedValue;
            });
          }
        },
      ),
    );
  }

  Widget _customButton({required IconData icon, VoidCallback? onTap}) {
    return InkWell(
      onTap: () {
        setState(() {
          onTap?.call();
          controller.text = widget.value.toStringAsFixed(1);
        });
      },
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: const BoxDecoration(
          color: AppColors.grey200,
          borderRadius: BorderRadius.all(Radius.circular(6)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          children: [
            Icon(icon, size: 20),
          ],
        ),
      ),
    );
  }
}
