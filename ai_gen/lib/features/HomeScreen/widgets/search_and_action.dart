// Search and Actions Row Widget
// Search and Actions Row Widget - Fixed Border Issue
import 'dart:async';

import 'package:ai_gen/core/translation/translation_keys.dart';
import 'package:ai_gen/core/utils/app_constants.dart';
import 'package:ai_gen/features/HomeScreen/cubit/home_cubit/home_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';

class SearchAndActionsRow extends StatefulWidget {
  const SearchAndActionsRow({super.key});

  @override
  State<SearchAndActionsRow> createState() => _SearchAndActionsRowState();
}

class _SearchAndActionsRowState extends State<SearchAndActionsRow> {
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounceTimer;

  @override
  void dispose() {
    _searchController.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    // Cancel previous timer
    _debounceTimer?.cancel();

    // Create new timer for debouncing (wait 300ms after user stops typing)
    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      context.read<HomeCubit>().searchProjects(query);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      spacing: 10,
      children: [
        SizedBox(
          width: 300,
          height: 48,
          child: TextField(
            controller: _searchController,
            onChanged: _onSearchChanged,
            decoration: InputDecoration(
              // Fixed: Added borderRadius to both enabledBorder and focusedBorder
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(
                  color: Color(0xff999999),
                  width: 1,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(
                  color: Color(0xff999999),
                  width: 1.5, // Slightly thicker when focused
                ),
              ),

              hintText: TranslationKeys.searchHint.tr,
              hintStyle: const TextStyle(
                color: Color(0xff999999),
                fontFamily: AppConstants.appFontName,
                fontWeight: FontWeight.w700,
              ),
              prefixIcon: const Icon(Icons.search, color: Color(0xff999999)),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear, color: Color(0xff999999)),
                      onPressed: () {
                        _searchController.clear();
                        context.read<HomeCubit>().searchProjects('');
                        setState(() {}); // Rebuild to hide clear button
                      },
                    )
                  : null,
              filled: true,
              fillColor: const Color(0xffF2F2F2),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
