import 'package:ai_gen/core/translation/translation_keys.dart';
import 'package:ai_gen/core/utils/app_constants.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

Widget buildFilterDropdown({
  required String title,
  required String? value,
  required List<String> items,
  required ValueChanged<String?> onChanged,
  required ValueChanged<String> onCopy,
}) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    decoration: BoxDecoration(
      color: const Color(0xffF2F2F2),
      borderRadius: BorderRadius.circular(8),
      border: Border.all(color: const Color(0xff999999)),
    ),
    child: DropdownButtonHideUnderline(
      child: DropdownButton<String>(
        isExpanded: true,
        hint: Text(
          title,
          style: const TextStyle(
            fontFamily: AppConstants.appFontName,
            fontSize: 14,
            color: Color(0xff666666),
          ),
        ),
        value: value,
        onChanged: onChanged,
        items: items.map<DropdownMenuItem<String>>((String item) {
          return DropdownMenuItem<String>(
            value: item,
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    item == 'all' ? TranslationKeys.all.tr : item,
                    style: const TextStyle(
                      fontFamily: AppConstants.appFontName,
                      fontSize: 14,
                    ),
                  ),
                ),
                if (item != 'all')
                  IconButton(
                    icon: const Icon(Icons.copy, size: 16),
                    onPressed: () => onCopy(item),
                    tooltip: TranslationKeys.copyToClipboard.tr,
                  ),
              ],
            ),
          );
        }).toList(),
      ),
    ),
  );
}
