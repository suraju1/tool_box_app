import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:tool_bocs/l10n/generated/app_localizations.dart';
import 'package:tool_bocs/util/colors.dart';
import 'package:tool_bocs/util/font_family.dart';
import 'package:tool_bocs/features/profile/controller/profile_controller.dart';
import 'package:tool_bocs/core/services/toast_service.dart';

class HelpSupportScreen extends StatefulWidget {
  const HelpSupportScreen({super.key});

  @override
  State<HelpSupportScreen> createState() => _HelpSupportScreenState();
}

class _HelpSupportScreenState extends State<HelpSupportScreen> {
  final TextEditingController _feedbackController = TextEditingController();
  bool _showFeedbackField = false;

  @override
  void initState() {
    super.initState();
    // Fetch FAQs when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProfileController>().getFaqs();
    });
  }

  @override
  void dispose() {
    _feedbackController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.scaffoldBg,
      appBar: AppBar(
        backgroundColor: context.scaffoldBg,
        elevation: 0,
        leading: IconButton(
          icon:
              Icon(Icons.arrow_back_ios, color: context.textColor, size: 20.sp),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Help & Support',
          style: TextStyle(
            color: context.textColor,
            fontSize: 18.sp,
            fontWeight: FontWeight.w700,
            fontFamily: FontFamily.openSans,
          ),
        ),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(10),
          child: Divider(height: 1, color: context.dividerColor),
        ),
      ),
      body: Consumer<ProfileController>(
        builder: (context, controller, child) {
          return SingleChildScrollView(
            padding: EdgeInsets.all(20.w),
            child: Column(
              children: [
                if (controller.isLoading && controller.faqs.isEmpty)
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 40.h),
                    child: const Center(child: CircularProgressIndicator()),
                  )
                else if (controller.faqs.isEmpty)
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 20.h),
                    child: Text(
                      'No FAQs available at the moment.',
                      style: TextStyle(
                        color: context.subTextColor,
                        fontSize: 14.sp,
                        fontFamily: FontFamily.openSans,
                      ),
                    ),
                  )
                else
                  ...controller.faqs.map((faq) => _buildFAQItem(
                        context,
                        question: faq.question,
                        answer: faq.answer,
                        initiallyExpanded: controller.faqs.indexOf(faq) == 0,
                      )),
                SizedBox(height: 30.h),
                _buildFeedbackSection(controller),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildFAQItem(
    BuildContext context, {
    required String question,
    required String answer,
    bool initiallyExpanded = false,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      decoration: BoxDecoration(
        color: context.surfaceColor,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: context.dividerColor),
        boxShadow: context.isDarkMode
            ? []
            : [
                BoxShadow(
                  color: greyColorWithOpacity0_4,
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
      ),
      child: Theme(
        data: Theme.of(context).copyWith(
          dividerColor: Colors.transparent,
        ),
        child: ExpansionTile(
          initiallyExpanded: initiallyExpanded,
          leading: Container(
            padding: EdgeInsets.all(8.r),
            decoration: BoxDecoration(
              color: context.primaryColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.help_outline,
                color: context.primaryColor, size: 18.sp),
          ),
          title: Text(
            question,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: context.textColor,
              fontFamily: FontFamily.openSans,
            ),
          ),
          trailing: Icon(
            initiallyExpanded
                ? Icons.keyboard_arrow_up
                : Icons.keyboard_arrow_down,
            color: context.textColor.withOpacity(0.5),
          ),
          childrenPadding: EdgeInsets.fromLTRB(50.w, 0, 20.w, 15.h),
          children: [
            Text(
              answer,
              style: TextStyle(
                fontSize: 12.sp,
                color: context.subTextColor,
                height: 1.5,
                fontFamily: FontFamily.openSans,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeedbackSection(ProfileController controller) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(12.r),
          decoration: BoxDecoration(
            color: context.primaryColor.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(Icons.chat_bubble_outline,
              color: context.primaryColor, size: 24.sp),
        ),
        SizedBox(height: 15.h),
        Text(
          AppLocalizations.of(context)!.didNotFindWhatYouWereLookingFor,
          style: TextStyle(
            fontSize: 15.sp,
            fontWeight: FontWeight.w700,
            fontFamily: FontFamily.openSans,
            color: context.textColor,
          ),
        ),
        SizedBox(height: 8.h),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          child: Text(
            AppLocalizations.of(context)!.wereHereToHelpYouWithAnyQuestions,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12.sp,
              color: Colors.grey,
              fontFamily: FontFamily.openSans,
            ),
          ),
        ),
        SizedBox(height: 25.h),
        if (!_showFeedbackField)
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                setState(() {
                  _showFeedbackField = true;
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: context.primaryColor,
                padding: EdgeInsets.symmetric(vertical: 14.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.r),
                ),
                elevation: 0,
              ),
              child: Text(
                'Add Feedback',
                style: TextStyle(
                  color: context.onPrimaryColor,
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        if (_showFeedbackField) ...[
          SizedBox(height: 25.h),

          // show below text field when user click on add feedback button
          TextField(
            controller: _feedbackController,
            maxLines: 5,
            decoration: InputDecoration(
              hintText: AppLocalizations.of(context)!.shareYourFeedback,
              hintStyle: TextStyle(
                  color: context.isDarkMode
                      ? Colors.white30
                      : Colors.grey.shade400,
                  fontSize: 13.sp),
              filled: true,
              fillColor: context.surfaceColor,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: BorderSide(color: context.dividerColor),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: BorderSide(color: context.dividerColor),
              ),
            ),
          ),
          SizedBox(height: 20.h),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: controller.isLoading
                  ? null
                  : () async {
                      if (_feedbackController.text.isNotEmpty) {
                        final response = await controller
                            .submitFeedback(_feedbackController.text);

                        if (mounted) {
                          if (response.success) {
                            ToastService.showSuccessToast(
                                context, response.message);
                            setState(() {
                              _showFeedbackField = false;
                              _feedbackController.clear();
                            });
                          } else {
                            ToastService.showErrorToast(
                                context, response.message);
                          }
                        }
                      } else {
                        ToastService.showErrorToast(
                            context, 'Please enter some feedback');
                      }
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: context.primaryColor,
                padding: EdgeInsets.symmetric(vertical: 14.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.r),
                ),
                elevation: 0,
              ),
              child: controller.isLoading
                  ? SizedBox(
                      height: 20.h,
                      width: 20.h,
                      child: CircularProgressIndicator(
                        color: context.onPrimaryColor,
                        strokeWidth: 2,
                      ),
                    )
                  : Text(
                      'Submit',
                      style: TextStyle(
                        color: context.onPrimaryColor,
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
            ),
          ),
        ],
      ],
    );
  }
}
