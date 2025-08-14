
import 'package:flutter/material.dart';

class CustomIconTextButton extends StatelessWidget {
  final String text;
  final Color backgroundColor;
  final double textSize;
  final double iconSize;
  final Color textColor;
  final Color iconColor;
  final VoidCallback onTap;
  final String assetName;
  final double? width;
  final double? height;
  final EdgeInsets? padding;
  final bool enableResponsive;

  const CustomIconTextButton({
    required this.text,
    required this.backgroundColor,
    required this.textColor,
    required this.iconColor,
    required this.onTap,
    required this.assetName,
    super.key,
    this.textSize = 20,
    this.iconSize = 26,
    this.width,
    this.height,
    this.padding,
    this.enableResponsive = true, 
  });

  @override
  Widget build(BuildContext context) {
    if (!enableResponsive) {
     
      return _buildOriginalButton();
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        
        final availableWidth = constraints.maxWidth;
        final screenWidth = MediaQuery.of(context).size.width;

        
        final isVerySmallScreen = screenWidth < 600;
        final isSmallScreen = screenWidth < 800;
        final isNarrowButton = availableWidth < 120;
        final isVeryNarrowButton = availableWidth < 80;

        
        final responsiveTextSize = _calculateResponsiveTextSize(
            isVerySmallScreen, isSmallScreen, isNarrowButton);
        final responsiveIconSize = _calculateResponsiveIconSize(
            isVerySmallScreen, isSmallScreen, isNarrowButton);
        final responsivePadding = _calculateResponsivePadding(isVerySmallScreen,
            isSmallScreen, isNarrowButton, isVeryNarrowButton);

        return Material(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(8),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(8),
            child: Container(
              width: width,
              height: height,
              constraints: BoxConstraints(
                minWidth: isVeryNarrowButton ? 50 : (isNarrowButton ? 70 : 90),
                maxWidth: constraints.maxWidth == double.infinity
                    ? double.infinity
                    : constraints.maxWidth,
                minHeight: isVerySmallScreen ? 36 : 40,
              ),
              padding: padding ?? responsivePadding,
              decoration: BoxDecoration(
                color: backgroundColor,
                borderRadius: BorderRadius.circular(8),
              ),
              child: _buildResponsiveContent(
                isVeryNarrowButton,
                isNarrowButton,
                isSmallScreen,
                responsiveIconSize,
                responsiveTextSize,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildOriginalButton() {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: width,
        height: height,
        padding:
            padding ?? const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: iconSize,
              height: iconSize,
              child: Image.asset(
                assetName,
                color: iconColor,
                width: iconSize,
                height: iconSize,
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              text,
              style: TextStyle(
                color: textColor,
                fontSize: textSize,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResponsiveContent(
    bool isVeryNarrowButton,
    bool isNarrowButton,
    bool isSmallScreen,
    double responsiveIconSize,
    double responsiveTextSize,
  ) {
    if (isVeryNarrowButton) {
      
      return Center(
        child: _buildIcon(responsiveIconSize),
      );
    } else if (isNarrowButton) {
   
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildIcon(responsiveIconSize),
          const SizedBox(height: 4),
          Flexible(
            child: _buildText(responsiveTextSize, maxLines: 2),
          ),
        ],
      );
    } else {
      
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildIcon(responsiveIconSize),
          SizedBox(width: isSmallScreen ? 6 : 8),
          Flexible(
            child: _buildText(responsiveTextSize, maxLines: 1),
          ),
        ],
      );
    }
  }

  Widget _buildIcon(double size) {
    return SizedBox(
      width: size,
      height: size,
      child: Image.asset(
        assetName,
        color: iconColor,
        width: size,
        height: size,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) {
          
          return Icon(
            Icons.error_outline,
            color: iconColor,
            size: size,
          );
        },
      ),
    );
  }

  Widget _buildText(double fontSize, {int maxLines = 1}) {
    return FittedBox(
      fit: BoxFit.scaleDown,
      child: Text(
        text,
        style: TextStyle(
          color: textColor,
          fontSize: fontSize,
          fontWeight: FontWeight.w500,
        ),
        maxLines: maxLines,
        overflow: TextOverflow.ellipsis,
        textAlign: TextAlign.center,
      ),
    );
  }

  double _calculateResponsiveTextSize(
    bool isVerySmallScreen,
    bool isSmallScreen,
    bool isNarrowButton,
  ) {
    if (isVerySmallScreen) {
      return isNarrowButton ? 10 : 12;
    } else if (isSmallScreen) {
      return isNarrowButton ? 11 : 13;
    } else {
      return isNarrowButton ? 12 : (textSize * 0.7);
    }
  }

  double _calculateResponsiveIconSize(
    bool isVerySmallScreen,
    bool isSmallScreen,
    bool isNarrowButton,
  ) {
    if (isVerySmallScreen) {
      return isNarrowButton ? 14 : 16;
    } else if (isSmallScreen) {
      return isNarrowButton ? 16 : 18;
    } else {
      return isNarrowButton ? 18 : (iconSize * 0.7);
    }
  }

  EdgeInsets _calculateResponsivePadding(
    bool isVerySmallScreen,
    bool isSmallScreen,
    bool isNarrowButton,
    bool isVeryNarrowButton,
  ) {
    if (isVeryNarrowButton) {
      return const EdgeInsets.all(8);
    } else if (isVerySmallScreen) {
      return EdgeInsets.symmetric(
        vertical: isNarrowButton ? 6 : 8,
        horizontal: isNarrowButton ? 6 : 10,
      );
    } else if (isSmallScreen) {
      return EdgeInsets.symmetric(
        vertical: isNarrowButton ? 8 : 10,
        horizontal: isNarrowButton ? 8 : 12,
      );
    } else {
      return EdgeInsets.symmetric(
        vertical: isNarrowButton ? 8 : 10,
        horizontal: isNarrowButton ? 10 : 16,
      );
    }
  }
}


extension CustomIconTextButtonExtension on CustomIconTextButton {
  
  CustomIconTextButton compact() {
    return CustomIconTextButton(
      text: text,
      backgroundColor: backgroundColor,
      textColor: textColor,
      iconColor: iconColor,
      onTap: onTap,
      assetName: assetName,
      textSize: 12,
      iconSize: 16,
      enableResponsive: enableResponsive,
    );
  }

  //
  CustomIconTextButton fixedSize() {
    return CustomIconTextButton(
      text: text,
      backgroundColor: backgroundColor,
      textColor: textColor,
      iconColor: iconColor,
      onTap: onTap,
      assetName: assetName,
      textSize: textSize,
      iconSize: iconSize,
      enableResponsive: false,
    );
  }
}
