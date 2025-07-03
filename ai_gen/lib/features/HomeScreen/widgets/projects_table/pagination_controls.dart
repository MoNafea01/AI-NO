import 'package:ai_gen/core/translation/translation_keys.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:math' as math;
import '../../../../../core/utils/app_constants.dart';

class PaginationControls extends StatelessWidget {
  final int currentPage;
  final int totalPages;
  final VoidCallback goToPreviousPage;
  final VoidCallback goToNextPage;
  final Function(int) goToPage;

  const PaginationControls({
    required this.currentPage, required this.totalPages, required this.goToPreviousPage, required this.goToNextPage, required this.goToPage, super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
        color: Color(0xFFF5F5F5),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(8),
          bottomRight: Radius.circular(8),
        ),
        border: Border(
          top: BorderSide(
            color: Color(0xFFE5E7EB),
            width: 1,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Previous Button
          InkWell(
            onTap: currentPage > 1 ? goToPreviousPage : null,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: currentPage > 1 ? Colors.white : const Color(0xFFF9FAFB),
                border: Border.all(
                  color: currentPage > 1
                      ? const Color(0xFFD1D5DB)
                      : const Color(0xFFE5E7EB),
                ),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.arrow_back_sharp,
                    size: 18,
                    color: currentPage > 1
                        ? const Color(0xFF374151)
                        : const Color(0xFF9CA3AF),
                  ),
                  const SizedBox(width: 4),
                  Text(
                     TranslationKeys.previous.tr,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: AppConstants.appFontName,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: currentPage > 1
                          ? const Color(0xFF374151)
                          : const Color(0xFF9CA3AF),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Page Numbers
          Row(
            children: _buildPageNumbers(),
          ),
          // Next Button
          InkWell(
            onTap: currentPage < totalPages ? goToNextPage : null,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: currentPage < totalPages
                    ? const Color(0xffFFFFFF)
                    : const Color(0xFFF9FAFB),
                border: Border.all(
                  color: currentPage < totalPages
                      ? const Color(0xFFD1D5DB)
                      : const Color(0xFFE5E7EB),
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    TranslationKeys.next.tr,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: AppConstants.appFontName,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: currentPage < totalPages
                          ? const Color(0xFF1A1A1A)
                          : const Color(0xFF9CA3AF),
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    Icons.arrow_forward_sharp,
                    size: 18,
                    color: currentPage < totalPages
                        ? const Color(0xFF1A1A1A)
                        : const Color(0xFF9CA3AF),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildPageNumbers() {
    List<Widget> pageNumbers = [];

    int startPage = math.max(1, currentPage - 2);
    int endPage = math.min(totalPages, currentPage + 2);

    if (endPage - startPage < 4) {
      if (startPage == 1) {
        endPage = math.min(totalPages, startPage + 4);
      } else if (endPage == totalPages) {
        startPage = math.max(1, endPage - 4);
      }
    }

    if (startPage > 1) {
      pageNumbers.add(_buildPageButton(1));
      if (startPage > 2) {
        pageNumbers.add(_buildEllipsis());
      }
    }

    for (int i = startPage; i <= endPage; i++) {
      pageNumbers.add(_buildPageButton(i));
    }

    if (endPage < totalPages) {
      if (endPage < totalPages - 1) {
        pageNumbers.add(_buildEllipsis());
      }
      pageNumbers.add(_buildPageButton(totalPages));
    }

    return pageNumbers;
  }

  Widget _buildPageButton(int pageNumber) {
    final isCurrentPage = pageNumber == currentPage;

    return GestureDetector(
      onTap: () => goToPage(pageNumber),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 2),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color:
              isCurrentPage ? const Color(0xFFCCCCCC) : const Color(0x0ff2f2f2),
          border: Border.all(
              color: isCurrentPage
                  ? const Color(0xFF666666)
                  : const Color.fromARGB(15, 181, 4, 4)),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          pageNumber.toString(),
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: isCurrentPage
                ? const Color(0xff1A1A1A)
                : const Color(0xFF666666),
          ),
        ),
      ),
    );
  }

  Widget _buildEllipsis() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 2),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      child: const Text(
        "...",
        style: TextStyle(
          fontSize: 14,
          color: Color(0xFF9CA3AF),
        ),
      ),
    );
  }
}
