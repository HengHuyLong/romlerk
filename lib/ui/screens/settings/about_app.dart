import 'package:flutter/material.dart';
import '../../../core/constants/app_assets.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';

class AboutAppScreen extends StatefulWidget {
  const AboutAppScreen({super.key});

  @override
  State<AboutAppScreen> createState() => _AboutAppScreenState();
}

class _AboutAppScreenState extends State<AboutAppScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                const SizedBox(height: 80),

                // Image (no Hero, no fade)
                Center(
                  child: Image.asset(
                    AppAssets.splashBg,
                    width: MediaQuery.of(context).size.width * 0.4,
                    fit: BoxFit.cover,
                  ),
                ),

                const SizedBox(height: 16),

                // Captions row
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          'Smart',
                          style: AppTypography.bodyBold.copyWith(
                            color: AppColors.black,
                          ),
                          textAlign: TextAlign.left,
                        ),
                      ),
                      Expanded(
                        child: Text(
                          'Family-Friendly Management',
                          style: AppTypography.bodyBold.copyWith(
                            color: AppColors.black,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      Expanded(
                        child: Text(
                          'Secure',
                          style: AppTypography.bodyBold.copyWith(
                            color: AppColors.black,
                          ),
                          textAlign: TextAlign.right,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Scrollable long content
                Expanded(
                  child: Scrollbar(
                    thumbVisibility: true,
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            'Romlerk គឺជាកម្មវិធីគ្រប់គ្រងឯកសារខ្មែរ​ដែលមានគោលបំណងជួយគ្រួសារកម្ពុជាឲ្យអាចរក្សាទុក និងរៀបចំឯកសារសំខាន់ៗដូចជា អត្តសញ្ញាណប័ណ្ណ ប័ណ្ណបើកបរ ឬលិខិតឆ្លងដែន នៅក្នុងកន្លែងតែមួយ។ កម្មវិធីនេះបង្កើតឡើងដោយគោលគំនិតសាមញ្ញ សុវត្ថិភាព និងងាយស្រួលប្រើ ដើម្បីឲ្យអ្នកអាចទុកចិត្តបានថាឯកសាររបស់អ្នកមានសុវត្ថិភាព។\n\n'
                            'Romlerk ផ្តល់នូវការជូនដំណឹងមុនពេលឯកសារផុតកំណត់ ការបង្កើតប្រវត្តិរូបសមាជិកគ្រួសារ និងការចែករំលែកឯកសារជាមួយសមាជិកផ្សេងៗបានយ៉ាងងាយស្រួល។ កម្មវិធីនេះរចនាឡើងជាពិសេសសម្រាប់អ្នកប្រើជនជាតិខ្មែរ មានអត្ថបទជាភាសាខ្មែរ និងការរចនាដែលសាមញ្ញ បែបគ្រួសារ។\n\n'
                            'Romlerk ត្រូវបានអភិវឌ្ឍដោយក្រុមអ្នកបច្ចេកវិទ្យាកម្ពុជា ដែលមានបំណងជំរុញការផ្លាស់ប្តូរទៅជាសង្គមឌីជីថល។ ឯកសាររបស់អ្នកត្រូវបានអ៊ិនគ្រីប និងរក្សាទុកនៅក្នុង Cloud ដោយមានសុវត្ថិភាពខ្ពស់។ Romlerk គឺជាដៃគូដែលអ្នកអាចទុកចិត្តបានសម្រាប់គ្រួសាររបស់អ្នក។',
                            style: AppTypography.bodyKh.copyWith(
                              color: AppColors.black,
                              fontSize: 15,
                              height: 1.5,
                            ),
                            textAlign: TextAlign.justify,
                          ),

                          const SizedBox(height: 32),

                          // Center logo at the bottom
                          Center(
                            child: Image.asset(
                              AppAssets.logo,
                              width: 160,
                            ),
                          ),

                          const SizedBox(height: 16),

                          // Version info
                          Center(
                            child: Text(
                              "Version 1.0.0 — Developed by Heng HuyLong",
                              style: AppTypography.body.copyWith(
                                color:
                                    AppColors.darkGray.withValues(alpha: 0.7),
                                fontSize: 13,
                              ),
                            ),
                          ),

                          const SizedBox(height: 30),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),

            // Back arrow
            Positioned(
              top: 12,
              left: 8,
              child: IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back_ios_new_rounded),
                color: AppColors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
