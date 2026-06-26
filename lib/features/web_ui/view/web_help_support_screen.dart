import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tool_bocs/features/profile/controller/profile_controller.dart';
import 'package:tool_bocs/core/services/toast_service.dart';
import 'package:tool_bocs/l10n/generated/app_localizations.dart';
import 'package:tool_bocs/util/font_family.dart';

class WebHelpSupportScreen extends StatefulWidget {
  const WebHelpSupportScreen({super.key});

  @override
  State<WebHelpSupportScreen> createState() => _WebHelpSupportScreenState();
}

class _WebHelpSupportScreenState extends State<WebHelpSupportScreen> {
  final TextEditingController _feedbackController = TextEditingController();
  bool _showFeedbackField = false;

  @override
  void initState() {
    super.initState();
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
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: Column(
            children: [
              _buildHeader(context),
              const Divider(height: 1),
              Expanded(
                child: Consumer<ProfileController>(
                  builder: (context, controller, child) {
                    return SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 32, vertical: 40),
                      child: Column(
                        children: [
                          if (controller.isLoading && controller.faqs.isEmpty)
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 40),
                              child: Center(child: CircularProgressIndicator()),
                            )
                          else if (controller.faqs.isEmpty)
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 40),
                              child: Text(
                                'No FAQs available at the moment.',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontFamily: FontFamily.openSans,
                                  color: Colors.grey,
                                ),
                              ),
                            )
                          else
                            ...controller.faqs.map((faq) => _buildFAQItem(
                                  context,
                                  question: faq.question,
                                  answer: faq.answer,
                                  initiallyExpanded:
                                      controller.faqs.indexOf(faq) == 0,
                                )),
                          const SizedBox(height: 60),
                          _buildFeedbackSection(context, controller),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24.0, horizontal: 32.0),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back, size: 24),
            splashRadius: 24,
          ),
          const SizedBox(width: 16),
          const Text(
            'Help & Support',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              fontFamily: FontFamily.openSans,
            ),
          ),
        ],
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
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Theme.of(context).dividerColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          initiallyExpanded: initiallyExpanded,
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.help_outline,
                color: Theme.of(context).primaryColor, size: 20),
          ),
          title: Text(
            question,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              fontFamily: FontFamily.openSans,
            ),
          ),
          childrenPadding: const EdgeInsets.fromLTRB(60, 0, 24, 20),
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                answer,
                style: const TextStyle(
                  fontSize: 14,
                  height: 1.5,
                  color: Colors.grey,
                  fontFamily: FontFamily.openSans,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeedbackSection(
      BuildContext context, ProfileController controller) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).dividerColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.chat_bubble_outline,
                color: Theme.of(context).primaryColor, size: 32),
          ),
          const SizedBox(height: 24),
          Text(
            AppLocalizations.of(context)!.didNotFindWhatYouWereLookingFor,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              fontFamily: FontFamily.openSans,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            AppLocalizations.of(context)!.wereHereToHelpYouWithAnyQuestions,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey,
              fontFamily: FontFamily.openSans,
            ),
          ),
          const SizedBox(height: 32),
          if (!_showFeedbackField)
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () {
                  setState(() {
                    _showFeedbackField = true;
                  });
                },
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  AppLocalizations.of(context)!.addFeedback,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          if (_showFeedbackField) ...[
            TextField(
              controller: _feedbackController,
              maxLines: 5,
              decoration: InputDecoration(
                hintText: AppLocalizations.of(context)!.shareYourFeedback,
                filled: true,
                fillColor: Theme.of(context).scaffoldBackgroundColor,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Theme.of(context).dividerColor),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Theme.of(context).dividerColor),
                ),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: controller.isLoading
                    ? null
                    : () async {
                        if (_feedbackController.text.trim().isNotEmpty) {
                          final response = await controller
                              .submitFeedback(_feedbackController.text.trim());
                          if (!context.mounted) return;
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
                        } else {
                          ToastService.showErrorToast(
                              context, 'Please enter some feedback');
                        }
                      },
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  elevation: 0,
                ),
                child: controller.isLoading
                    ? const SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text(
                        'Submit Feedback',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
