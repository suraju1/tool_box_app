import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tool_bocs/util/colors.dart';
import 'package:tool_bocs/util/font_family.dart';

class HelpSupportScreen extends StatefulWidget {
  const HelpSupportScreen({super.key});

  @override
  State<HelpSupportScreen> createState() => _HelpSupportScreenState();
}

class _HelpSupportScreenState extends State<HelpSupportScreen> {
  final TextEditingController _feedbackController = TextEditingController();
  bool _showFeedbackField = false;

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
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20.w),
        child: Column(
          children: [
            _buildFAQItem(
              context,
              question: 'How does Give & Take work?',
              answer:
                  'You can give items you no longer need or take items offered by others. You can exchange items for price or another item based on mutual agreement.',
              initiallyExpanded: true,
            ),
            _buildFAQItem(
              context,
              question: 'How do I create a new post?',
              answer:
                  'To create a new post, navigate to the "Give" tab and click on the "Make a New Post" button at the bottom of the screen.',
            ),
            _buildFAQItem(
              context,
              question: 'Is it safe to trade with other users?',
              answer:
                  'We encourage users to review profiles and ratings before trading. Always meet in safe, public places for physical exchanges.',
            ),
            _buildFAQItem(
              context,
              question: 'How do ratings and reviews work?',
              answer:
                  'After a trade is completed, both parties can rate each other and leave a review based on their experience.',
            ),
            _buildFAQItem(
              context,
              question: 'What happens if I face a problem during a trade?',
              answer:
                  'If you encounter any issues, you can report the user through their profile or contact our support team for assistance.',
            ),
            SizedBox(height: 30.h),
            _buildFeedbackSection(),
          ],
        ),
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
            child: Icon(Icons.help_outline, color: context.primaryColor, size: 18.sp),
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

  Widget _buildFeedbackSection() {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(12.r),
          decoration: BoxDecoration(
            color: context.primaryColor.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(Icons.chat_bubble_outline, color: context.primaryColor, size: 24.sp),
        ),
        SizedBox(height: 15.h),
        Text(
          "Didn't find what you were looking for ?",
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
            "We're here to help you with any questions or issues you might have with the community",
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
              hintText: 'Share Your Feedback',
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
              onPressed: () {
                // Submit logic here
                if (_feedbackController.text.isNotEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Feedback submitted successfully')),
                  );
                  setState(() {
                    _showFeedbackField = false;
                    _feedbackController.clear();
                  });
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please enter some feedback')),
                  );
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
              child: Text(
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
