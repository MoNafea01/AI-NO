import 'package:ai_gen/core/themes/app_colors.dart';
import 'package:ai_gen/core/themes/textstyles.dart';
import 'package:flutter/material.dart';

class CustomDialog extends StatefulWidget {
  const CustomDialog({
    required this.dialogTitle,
    required this.child,
    this.submitButtonText,
    this.cancelButtonText,
    this.onSubmit,
    this.onCancel,
    super.key,
  });

  final String dialogTitle;
  final Widget child;
  final String? submitButtonText;
  final String? cancelButtonText;
  final VoidCallback? onSubmit;
  final VoidCallback? onCancel;

  @override
  State<CustomDialog> createState() => _CustomDialogState();
}

class _CustomDialogState extends State<CustomDialog> {
  late final GlobalKey<FormState> _formKey;

  @override
  void initState() {
    super.initState();
    _formKey = GlobalKey<FormState>();
  }

  @override
  void dispose() {
    _formKey.currentState?.dispose();
    super.dispose();
  }

  void _onSubmitPressed() {
    if (!mounted) return;
    if (!_formKey.currentState!.validate()) return;
    widget.onSubmit?.call();
  }

  void _onCancelPressed() {
    if (!mounted) return;
    widget.onCancel?.call();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 350,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(24),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 24,
          children: [
            Text(widget.dialogTitle, style: AppTextStyles.title24),
            widget.child,
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              spacing: 16,
              children: [_cancelButton(), _submitButton()],
            ),
          ],
        ),
      ),
    );
  }

  ElevatedButton _submitButton() {
    return ElevatedButton(
      onPressed: _onSubmitPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(
          horizontal: 24,
          vertical: 12,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      child: Text(
        widget.submitButtonText ?? 'Submit',
        style: AppTextStyles.black16w400.copyWith(color: Colors.white),
      ),
    );
  }

  TextButton _cancelButton() {
    return TextButton(
      onPressed: _onCancelPressed,
      child: Text(
        widget.cancelButtonText ?? 'Cancel',
        style: AppTextStyles.black16w400
            .copyWith(color: AppColors.bluePrimaryColor),
      ),
    );
  }
}
