// import 'package:ai_gen/core/themes/app_colors.dart';

// import 'package:flutter/material.dart';

// class CustomPrimaryButton extends StatelessWidget {
//   final String? buttonName;
//   final Color? buttonBackgroundColor;
//   final double? width, height;
//   final double? borderButtonRadius;
//   final Color? textButtonColor;
//   final VoidCallback? onPressed;
//   final double? fontSize;

//   const CustomPrimaryButton(
//       {super.key,
//       this.buttonName,
//       this.buttonBackgroundColor,
//       this.width,
//       this.height,
//       this.borderButtonRadius,
//       this.textButtonColor,
//       this.onPressed,
//       this.fontSize});

//   @override
//   Widget build(BuildContext context) {
//     return ElevatedButton(
//       style: ElevatedButton.styleFrom(
//         backgroundColor: buttonBackgroundColor,
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(borderButtonRadius ?? 8),
//         ),
//         fixedSize: Size(width ?? 331, height ?? 45),
//       ),
//       onPressed: onPressed,
//       child: Text(
//         buttonName ?? " ",
//         style: TextStyle(
//             color: textButtonColor ?? AppColors.primaryColor,
//             fontSize: fontSize ?? 16,
//             fontWeight: FontWeight.bold),
//       ),
//     );
//   }
// }

// for more better user experience

// import 'package:ai_gen/core/themes/app_colors.dart';
// import 'package:flutter/material.dart';

// class CustomPrimaryButton extends StatelessWidget {
//   final String? buttonName;
//   final Color? buttonBackgroundColor;
//   final double? width, height;
//   final double? borderButtonRadius;
//   final Color? textButtonColor;
//   final VoidCallback? onPressed;
//   final double? fontSize;
//   final bool isLoading;

//   const CustomPrimaryButton({
//     super.key,
//     this.buttonName,
//     this.buttonBackgroundColor,
//     this.width,
//     this.height,
//     this.borderButtonRadius,
//     this.textButtonColor,
//     this.onPressed,
//     this.fontSize,
//     this.isLoading = false,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return ElevatedButton(
//       style: ElevatedButton.styleFrom(
//         backgroundColor: buttonBackgroundColor,
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(borderButtonRadius ?? 8),
//         ),
//         fixedSize: Size(width ?? 331, height ?? 45),
//       ),
//       onPressed: isLoading ? null : onPressed,
//       child: isLoading
//           ? const SizedBox(
//               height: 20,
//               width: 20,
//               child: CircularProgressIndicator(
//                 strokeWidth: 2,
//                 valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
//               ),
//             )
//           : Text(
//               buttonName ?? " ",
//               style: TextStyle(
//                 color: textButtonColor ?? AppColors.primaryColor,
//                 fontSize: fontSize ?? 16,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//     );
//   }
// }

import 'package:ai_gen/core/themes/app_colors.dart';
import 'package:flutter/material.dart';

class CustomPrimaryButton extends StatefulWidget {
  final Color buttonBackgroundColor;
  final String buttonName;
  final Color textButtonColor;
  final VoidCallback onPressed;
  final bool isLoading;
  final EdgeInsetsGeometry? padding;
  final double? width;
  final double? height;
  final double? borderRadius;
  final double? elevation;

  const CustomPrimaryButton({
    required this.buttonBackgroundColor,
    required this.buttonName,
    required this.textButtonColor,
    required this.onPressed,
    super.key,
    this.isLoading = false,
    this.padding,
    this.width,
    this.height,
    this.borderRadius,
    this.elevation,
  });

  @override
  State<CustomPrimaryButton> createState() => _CustomPrimaryButtonState();
}

class _CustomPrimaryButtonState extends State<CustomPrimaryButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    if (!widget.isLoading) {
      setState(() {
        _isPressed = true;
      });
      _animationController.forward();
    }
  }

  void _onTapUp(TapUpDetails details) {
    setState(() {
      _isPressed = false;
    });
    _animationController.reverse();
  }

  void _onTapCancel() {
    setState(() {
      _isPressed = false;
    });
    _animationController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              width: widget.width,
              height: widget.height ?? 50,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(widget.borderRadius ?? 8),
                boxShadow: [
                  BoxShadow(
                    color: widget.buttonBackgroundColor.withOpacity(0.3),
                    blurRadius: widget.elevation ?? 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: widget.isLoading ? null : widget.onPressed,
                  borderRadius: BorderRadius.circular(widget.borderRadius ?? 8),
                  child: Ink(
                    decoration: BoxDecoration(
                      color: widget.isLoading || _isPressed
                          ? widget.buttonBackgroundColor.withOpacity(0.8)
                          : widget.buttonBackgroundColor,
                      borderRadius:
                          BorderRadius.circular(widget.borderRadius ?? 8),
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          widget.buttonBackgroundColor,
                          widget.buttonBackgroundColor.withOpacity(0.8),
                        ],
                      ),
                    ),
                    child: Padding(
                      padding: widget.padding ??
                          const EdgeInsets.symmetric(
                              vertical: 12, horizontal: 16),
                      child: Center(
                        child: widget.isLoading
                            ? SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    widget.textButtonColor,
                                  ),
                                ),
                              )
                            : Text(
                                widget.buttonName,
                                style: TextStyle(
                                  color: widget.textButtonColor,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.5,
                                ),
                              ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
