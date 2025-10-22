import 'package:flutter/material.dart';
import 'package:romlerk/ui/widgets/app_background.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';

class FaqScreen extends StatefulWidget {
  const FaqScreen({super.key});

  @override
  State<FaqScreen> createState() => _FaqScreenState();
}

class _FaqScreenState extends State<FaqScreen> {
  int? expandedIndex;

  final List<Map<String, String>> faqs = [
    {
      "question": "What is Romlerk?",
      "answer":
          "Romlerk is a Khmer document management app that helps Cambodian families store, track, and get reminders for important documents in one secure place."
    },
    {
      "question": "Do I need an account to use it?",
      "answer":
          "Yes, signing in with your phone number helps link your documents securely and enables expiry reminders for you and your family."
    },
    {
      "question": "Is my data secure?",
      "answer":
          "Romlerk uses Firebase Authentication and encrypted cloud storage. Only you and your chosen family members can access your data."
    },
    {
      "question": "Can I share documents with my family?",
      "answer":
          "Yes, Romlerk supports multi-profile and family sharing. You can manage parents’, children’s, or grandparents’ documents easily."
    },
  ];

  @override
  Widget build(BuildContext context) {
    return AppBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          iconTheme: const IconThemeData(color: AppColors.black),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Questions",
                style: AppTypography.bodyBold.copyWith(color: AppColors.black),
              ),
              Text(
                "Frequently Asked",
                style: AppTypography.body.copyWith(
                  color: AppColors.darkGray.withValues(alpha: 0.6),
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: faqs.length,
                  itemBuilder: (context, index) {
                    final item = faqs[index];
                    final isExpanded = expandedIndex == index;

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        InkWell(
                          onTap: () {
                            setState(() {
                              expandedIndex = isExpanded ? null : index;
                            });
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    item['question']!,
                                    style: AppTypography.bodyBold.copyWith(
                                      fontSize: 15,
                                      color: AppColors.black,
                                    ),
                                  ),
                                ),
                                Icon(
                                  isExpanded
                                      ? Icons.remove_rounded
                                      : Icons.add_rounded,
                                  color:
                                      AppColors.darkGray.withValues(alpha: 0.7),
                                  size: 20,
                                ),
                              ],
                            ),
                          ),
                        ),
                        AnimatedCrossFade(
                          firstChild: Padding(
                            padding:
                                const EdgeInsets.only(bottom: 12, right: 8),
                            child: Text(
                              item['answer']!,
                              style: AppTypography.body.copyWith(
                                fontSize: 14,
                                color:
                                    AppColors.darkGray.withValues(alpha: 0.9),
                                height: 1.5,
                              ),
                            ),
                          ),
                          secondChild: const SizedBox.shrink(),
                          crossFadeState: isExpanded
                              ? CrossFadeState.showFirst
                              : CrossFadeState.showSecond,
                          duration: const Duration(milliseconds: 200),
                        ),
                        Divider(
                          color: AppColors.darkGray.withValues(alpha: 0.1),
                          height: 0,
                        ),
                      ],
                    );
                  },
                ),
              ),
              const SizedBox(height: 20),
              Center(
                child: Text.rich(
                  TextSpan(
                    text:
                        "Can’t find an answer to your questions? Feel free to contact us at ",
                    style: AppTypography.body.copyWith(
                      fontSize: 13,
                      color: AppColors.darkGray.withValues(alpha: 0.8),
                    ),
                    children: [
                      TextSpan(
                        text: "support@romlerk.app",
                        style: AppTypography.body.copyWith(
                          color: AppColors.green,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ],
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
