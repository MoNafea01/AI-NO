// ignore_for_file: deprecated_member_use, library_private_types_in_public_api

import 'package:ai_gen/core/translation/translation_keys.dart';
import 'package:ai_gen/core/utils/themes/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../../core/utils/app_constants.dart';

class ProjectsTableHeader extends StatelessWidget {
  final Set<int> selectedProjectIds;
  final VoidCallback toggleSelectAll;
  final Function(List<int>) showDeleteConfirmationDialog;
  final VoidCallback showDeleteEmptyProjectsDialog;

  const ProjectsTableHeader({
    required this.selectedProjectIds,
    required this.toggleSelectAll,
    required this.showDeleteConfirmationDialog,
    required this.showDeleteEmptyProjectsDialog,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
        color: Color(0xFFE6E6E6),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(8),
          topRight: Radius.circular(8),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Row(
              children: [
                // Select All / Deselect All Button
                WhatsAppBubbleTooltip(
                  message: selectedProjectIds.isEmpty
                      ? TranslationKeys.selectAllProjects.tr
                      : TranslationKeys.deselectAllProjects.tr,
                  child: Container(
                    width: 16,
                    height: 16,
                    decoration: BoxDecoration(
                      color: selectedProjectIds.isEmpty
                          ? const Color(0xFFF5F5F5)
                          : const Color(0xFF3B82F6),
                      border: Border.all(
                        color: selectedProjectIds.isEmpty
                            ? const Color(0xFFD1D5DB)
                            : const Color(0xFF3B82F6),
                      ),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: InkWell(
                      onTap: toggleSelectAll,
                      child: selectedProjectIds.isEmpty
                          ? null
                          : const Icon(
                              Icons.check,
                              size: 12,
                              color: Colors.white,
                            ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),

                // Delete Selected Button
                if (selectedProjectIds.isNotEmpty) ...[
                  WhatsAppBubbleTooltip(
                    message:
                        "${TranslationKeys.deleteSelectedProjects.tr}(${selectedProjectIds.length})",
                    child: InkWell(
                      onTap: () => showDeleteConfirmationDialog(
                          selectedProjectIds.toList()),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFDC2626),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.delete_outline,
                              size: 12,
                              color: Colors.white,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${selectedProjectIds.length}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                ],

                // Delete Empty Projects Button
                WhatsAppBubbleTooltip(
                  message: TranslationKeys.deleteAllEmptyProjects.tr,
                  child: InkWell(
                    onTap: showDeleteEmptyProjectsDialog,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF6B7280),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Icon(
                        Icons.cleaning_services_outlined,
                        size: 12,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),

                Text(
                  TranslationKeys.name.tr,
                  style: const TextStyle(
                    fontFamily: AppConstants.appFontName,
                    fontSize: 14.2,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF666666),
                  ),
                ),
                const SizedBox(width: 4),
                const Icon(
                  Icons.arrow_downward,
                  size: 16,
                  color: Color(0xFF666666),
                ),
              ],
            ),
          ),
          // ... rest of your code remains the same
          Expanded(
            flex: 2,
            child: Text(
              TranslationKeys.description.tr,
              style: const TextStyle(
                fontFamily: AppConstants.appFontName,
                fontSize: 14.2,
                fontWeight: FontWeight.w500,
                color: Color(0xFF666666),
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              TranslationKeys.dataset.tr,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: AppConstants.appFontName,
                fontSize: 14.2,
                fontWeight: FontWeight.w500,
                color: Color(0xFF666666),
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              TranslationKeys.model.tr,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: AppConstants.appFontName,
                fontSize: 14.2,
                fontWeight: FontWeight.w500,
                color: Color(0xFF666666),
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Text(
              TranslationKeys.createdAt.tr,
              style: const TextStyle(
                fontFamily: AppConstants.appFontName,
                fontSize: 14.2,
                fontWeight: FontWeight.w500,
                color: Color(0xFF666666),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class WhatsAppBubbleTooltip extends StatefulWidget {
  final String message;
  final Widget child;

  const WhatsAppBubbleTooltip({
    required this.message,
    required this.child,
    super.key,
  });

  @override
  _WhatsAppBubbleTooltipState createState() => _WhatsAppBubbleTooltipState();
}

class _WhatsAppBubbleTooltipState extends State<WhatsAppBubbleTooltip> {
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;

  @override
  void dispose() {
    _removeOverlay();
    super.dispose();
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  void _showOverlay() {
    _removeOverlay();

    final renderBox = context.findRenderObject() as RenderBox;
    final offset = renderBox.localToGlobal(Offset.zero);
    final size = renderBox.size;

    _overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        left: offset.dx -
            8, // Adjust this value to align the triangle with the icon
        top: offset.dy + size.height,
        child: CompositedTransformFollower(
          link: _layerLink,
          showWhenUnlinked: false,
          offset: Offset(
              8, size.height), // Adjust this offset to fine-tune positioning
          child: Material(
            color: Colors.transparent,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // The right-angled triangle pointer
                CustomPaint(
                  painter: _TrianglePainter(),
                  child: const SizedBox(width: 16, height: 8),
                ),
                // The bubble
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.bluePrimaryColor,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Text(
                    widget.message,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      fontFamily: AppConstants.appFontName,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    Overlay.of(context).insert(_overlayEntry!);
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _layerLink,
      child: MouseRegion(
        onEnter: (_) => _showOverlay(),
        onExit: (_) => _removeOverlay(),
        child: widget.child,
      ),
    );
  }
}

class _TrianglePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.transparent
      ..style = PaintingStyle.fill;

    final path = Path()
      ..moveTo(0, size.height)
      ..lineTo(size.width, size.height)
      ..lineTo(size.width * 0.5, 0)
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
