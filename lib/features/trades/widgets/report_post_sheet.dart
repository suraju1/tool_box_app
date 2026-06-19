import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tool_bocs/core/services/toast_service.dart';
import 'package:tool_bocs/features/trades/controller/trade_controller.dart';
import 'package:tool_bocs/features/trades/model/report_reason_model.dart';
import 'package:tool_bocs/util/colors.dart';

class ReportPostSheet extends StatefulWidget {
  final int postId;

  const ReportPostSheet({Key? key, required this.postId}) : super(key: key);

  static Future<void> show(BuildContext context, int postId) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 500),
          child: Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            child: ReportPostSheet(postId: postId),
          ),
        ),
      ),
    );
  }

  @override
  State<ReportPostSheet> createState() => _ReportPostSheetState();
}

class _ReportPostSheetState extends State<ReportPostSheet> {
  ReportReasonModel? _selectedReason;
  final TextEditingController _descriptionController = TextEditingController();
  bool _isOtherSelected = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TradeController>().fetchReportReasons();
    });
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  void _submitReport() async {
    if (_selectedReason == null) {
      ToastService.showErrorToast(context, 'Please select a reason');
      return;
    }

    if (_isOtherSelected && _descriptionController.text.trim().isEmpty) {
      ToastService.showErrorToast(
          context, 'Please provide a description for the reason');
      return;
    }

    final controller = context.read<TradeController>();
    final success = await controller.reportPost(
      postId: widget.postId,
      reasonId: _selectedReason!.id,
      description: _descriptionController.text.trim(),
    );

    if (mounted) {
      if (success) {
        ToastService.showSuccessToast(context, 'Post reported successfully');
        Navigator.pop(context);
      } else {
        ToastService.showErrorToast(
            context, controller.errorMessage ?? 'Failed to report post');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.surfaceColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: Consumer<TradeController>(
        builder: (context, controller, child) {
          if (controller.isReportReasonsLoading &&
              controller.reportReasons.isEmpty) {
            return const SizedBox(
              height: 200,
              child: Center(child: CircularProgressIndicator()),
            );
          }

          return Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Report Post',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: context.textColor,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(Icons.close, color: context.textColor),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                'Why are you reporting this post?',
                style: TextStyle(
                  fontSize: 14,
                  color: context.textColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  border: Border.all(color: context.dividerColor),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<ReportReasonModel>(
                    isExpanded: true,
                    hint: const Text(
                      'Select a reason',
                      style: TextStyle(color: Colors.grey, fontSize: 14),
                    ),
                    value: _selectedReason,
                    dropdownColor: context.surfaceColor,
                    items: controller.reportReasons.map((reason) {
                      return DropdownMenuItem<ReportReasonModel>(
                        value: reason,
                        child: Text(
                          reason.title,
                          style: TextStyle(
                            color: context.textColor,
                            fontSize: 14,
                          ),
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedReason = value;
                        _isOtherSelected =
                            value?.title.toLowerCase().contains('other') ??
                                false;
                        if (!_isOtherSelected) {
                          _descriptionController.clear();
                        }
                      });
                    },
                  ),
                ),
              ),
              if (_isOtherSelected) ...[
                const SizedBox(height: 16),
                TextField(
                  controller: _descriptionController,
                  maxLines: 3,
                  style: TextStyle(color: context.textColor, fontSize: 14),
                  decoration: InputDecoration(
                    hintText: 'Please provide more details...',
                    hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: context.dividerColor),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: context.dividerColor),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: context.primaryColor),
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: controller.isLoading ? null : _submitReport,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.shade600,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: controller.isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text(
                        'Submit Report',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}
