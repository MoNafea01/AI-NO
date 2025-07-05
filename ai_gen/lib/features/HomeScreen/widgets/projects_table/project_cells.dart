import 'package:ai_gen/core/translation/translation_keys.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

Widget buildDatasetCell(String? dataset) {
  if (dataset == null || dataset.isEmpty) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xffF2F2F2),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: const Color(0xff666666)),
      ),
      child: Text(
        TranslationKeys.noDataset.tr,
        style: const TextStyle(
          fontSize: 12,
          color: Color(0xff666666),
          fontStyle: FontStyle.italic,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
     margin: const EdgeInsets.symmetric(horizontal: 16),
    decoration: BoxDecoration(
      color: const Color(0xffF2F2F2),
      borderRadius: BorderRadius.circular(4),
      border: Border.all(color: const Color(0xff666666)),
    ),
    child: Text(
      dataset,
      style: const TextStyle(
        fontSize: 12,
        color: Color(0xff666666),
        fontWeight: FontWeight.w500,
      ),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      textAlign: TextAlign.center,
    ),
  );
}

Widget buildModelCell(String? model) {
  if (model == null || model.isEmpty) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: const Color(0xffF2F2F2),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: const Color(0xff666666)),
      ),
      child: Text(
        TranslationKeys.noModel.tr,
        style: const TextStyle(
          fontSize: 12,
          color: Color(0xff666666),
          fontStyle: FontStyle.italic,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
     margin: const EdgeInsets.symmetric(horizontal: 20),
    decoration: BoxDecoration(
      color: const Color(0xffF2F2F2),
      borderRadius: BorderRadius.circular(4),
      border: Border.all(color: const Color(0xff666666)),
    ),
    child: Text(
      model,
      style: const TextStyle(
        fontSize: 12,
        color: Color(0xff666666),
        fontWeight: FontWeight.w500,
      ),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      textAlign: TextAlign.center,
    ),
  );
}

Widget highlightSearchText(
    String text, String searchQuery, TextStyle baseStyle) {
  if (searchQuery.isEmpty || text.isEmpty) {
    return Text(
      text,
      style: baseStyle,
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }

  final List<TextSpan> spans = [];
  final String lowerText = text.toLowerCase();
  final String lowerQuery = searchQuery.toLowerCase();

  int start = 0;
  int index = lowerText.indexOf(lowerQuery);

  while (index != -1) {
    if (index > start) {
      spans.add(TextSpan(
        text: text.substring(start, index),
        style: baseStyle,
      ));
    }

    spans.add(TextSpan(
      text: text.substring(index, index + searchQuery.length),
      style: baseStyle.copyWith(
        backgroundColor: Colors.yellow.shade100,
        fontWeight: FontWeight.bold,
      ),
    ));

    start = index + searchQuery.length;
    index = lowerText.indexOf(lowerQuery, start);
  }

  if (start < text.length) {
    spans.add(TextSpan(
      text: text.substring(start),
      style: baseStyle,
    ));
  }

  return RichText(
    text: TextSpan(
      children: spans,
    ),
    maxLines: 2,
    overflow: TextOverflow.ellipsis,
  );
}
