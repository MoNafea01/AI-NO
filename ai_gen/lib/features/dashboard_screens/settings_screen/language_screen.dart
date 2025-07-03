import 'package:ai_gen/core/translation/translation_helper.dart';
import 'package:ai_gen/core/translation/translation_keys.dart';
import 'package:ai_gen/core/utils/themes/app_colors.dart';
import 'package:ai_gen/features/dashboard_screens/settings_screen/cubits/change_language_cubit/language_cubit.dart';
import 'package:ai_gen/features/dashboard_screens/settings_screen/cubits/change_language_cubit/language_state.dart';
import 'package:ai_gen/features/dashboard_screens/settings_screen/widgets/custom_language_container.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';



class LanguageView extends StatelessWidget {
  const LanguageView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => LanguageCubit(),
      child: BlocBuilder<LanguageCubit, LanguageState>(
        builder: (context, state) {
          return Scaffold(
            body: SafeArea(
              child: Padding(
                padding: const EdgeInsetsDirectional.symmetric(
                  horizontal: 28,
                  vertical: 20,
                ),
                child: Column(
                  children: [
                 
                    
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          TranslationKeys.language.tr,
                          style: const TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 20,
                          ),
                        ),
                        Container(
                          decoration: BoxDecoration(
                            // No need for border radius here as we'll handle it in the individual containers
                            border: Border.all(color: Colors.transparent),
                          ),
                          child: Row(
                            children: [
                              GestureDetector(
                                onTap: () {
                                  LanguageCubit.get(
                                    context,
                                  ).changeLanguage(true);
                                  TranslationHelper.changeLanguage(true);
                                },
                                child: Stack(
                                  children: [
                                    CustomLanguageContainer
                                        .getCustomLanguageContainer(
                                      backgroundColor:
                                          LanguageCubit.get(context).isArabic
                                              ? AppColors.bluePrimaryColor
                                              : AppColors.textSecondary,
                                      text: TranslationKeys.arabic.tr,
                                      textColor:
                                          LanguageCubit.get(context).isArabic
                                              ? Colors.white
                                              : AppColors.black,
                                      borderRadius: LanguageCubit.get(context)
                                              .isArabic
                                          ? const BorderRadius.only(
                                              topRight: Radius.circular(5),
                                              bottomRight: Radius.circular(5),
                                            )
                                          : const BorderRadius.only(
                                              topLeft: Radius.circular(5),
                                              bottomLeft: Radius.circular(5),
                                            ),
                                    ),
                                    if (LanguageCubit.get(context).isArabic)
                                      Positioned(
                                        top: 0,
                                        right: 0,
                                        child: Container(
                                          width: 8,
                                          height: 8,
                                          decoration: const BoxDecoration(
                                            color: Colors.white,
                                            shape: BoxShape.circle,
                                          ),
                                          margin: const EdgeInsets.all(4),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  TranslationHelper.changeLanguage(false);
                                  LanguageCubit.get(
                                    context,
                                  ).changeLanguage(false);
                                },
                                child: Stack(
                                  children: [
                                    CustomLanguageContainer
                                        .getCustomLanguageContainer(
                                      backgroundColor:
                                          !LanguageCubit.get(context).isArabic
                                              ? AppColors.bluePrimaryColor
                                              : const Color(0xffD9D9D9),
                                      text: TranslationKeys.english.tr,
                                      textColor:
                                          !LanguageCubit.get(context).isArabic
                                              ? Colors.white
                                              : AppColors.black,
                                      borderRadius: LanguageCubit.get(context)
                                              .isArabic
                                          ? const BorderRadius.only(
                                              topLeft: Radius.circular(5),
                                              bottomLeft: Radius.circular(5),
                                            )
                                          : const BorderRadius.only(
                                              topRight: Radius.circular(5),
                                              bottomRight: Radius.circular(5),
                                            ),
                                    ),
                                    if (!LanguageCubit.get(context).isArabic)
                                      Positioned(
                                        top: 0,
                                        right: 0,
                                        child: Container(
                                          width: 8,
                                          height: 8,
                                          decoration: const BoxDecoration(
                                            color: AppColors.white,
                                            shape: BoxShape.circle,
                                          ),
                                          margin: const EdgeInsets.all(4),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    
                   
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
