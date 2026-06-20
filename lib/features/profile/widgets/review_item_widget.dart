import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:tool_bocs/core/widgets/app_cached_image.dart';
import 'package:tool_bocs/features/profile/controller/profile_controller.dart';
import 'package:tool_bocs/features/profile/model/user_profile_model.dart';
import 'package:tool_bocs/util/colors.dart';

class ReviewItemWidget extends StatelessWidget {
  final Review review;
  const ReviewItemWidget({super.key, required this.review});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child: InkWell(
        onTap: () {
          if (review.reviewerId != null) {
            ProfileController.navigateToUserProfile(context, review.reviewerId!);
          }
        },
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                    color: context.primaryColor.withOpacity(0.1), width: 1),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(25.r),
                child: AppCachedImage(
                  imageUrl: review.reviewerImage ?? '',
                  userName: review.reviewerName,
                  width: 50.r,
                  height: 50.r,
                  fit: BoxFit.cover,
                  radius: 25.r,
                ),
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    review.reviewerName ?? 'User',
                    style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.bold,
                        color: context.textColor),
                  ),
                  Row(
                    children: [
                      if (review.feedbackLabel != null) ...[
                        Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 6.w, vertical: 2.h),
                          decoration: BoxDecoration(
                            color: context.primaryColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4.r),
                          ),
                          child: Text(
                            review.feedbackLabel!,
                            style: TextStyle(
                              fontSize: 10.sp,
                              color: context.primaryColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  SizedBox(height: 4.h),
                  if (review.comment != null && review.comment!.isNotEmpty)
                    Text(
                      review.comment!,
                      style: TextStyle(
                          fontSize: 12.sp, color: context.subTextColor),
                    ),
                  SizedBox(height: 8.h),
                  Row(
                    children: [
                      _buildReactionButton(
                        context: context,
                        icon: review.userReaction == 'like' ? Icons.thumb_up : Icons.thumb_up_alt_outlined,
                        label: 'True',
                        count: review.likesCount,
                        reactionType: 'like',
                        isActive: review.userReaction == 'like',
                        activeColor: Colors.blue,
                      ),
                      SizedBox(width: 16.w),
                      _buildReactionButton(
                        context: context,
                        icon: review.userReaction == 'dislike' ? Icons.thumb_down : Icons.thumb_down_alt_outlined,
                        label: 'False',
                        count: review.dislikesCount,
                        reactionType: 'dislike',
                        isActive: review.userReaction == 'dislike',
                        activeColor: Colors.red,
                      ),
                    ],
                  ),
                  SizedBox(height: 4.h),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReactionButton({
    required BuildContext context,
    required IconData icon,
    required String label,
    required int count,
    required String reactionType,
    required bool isActive,
    required Color activeColor,
  }) {
    return InkWell(
      onTap: () {
        context.read<ProfileController>().toggleReviewReaction(review.id, reactionType);
      },
      borderRadius: BorderRadius.circular(20.r),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 4.h),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16.sp,
              color: isActive ? activeColor : context.subTextColor,
            ),
            SizedBox(width: 6.w),
            Text(
              count > 0 ? '$label ($count)' : label,
              style: TextStyle(
                fontSize: 12.sp,
                color: isActive ? activeColor : context.subTextColor,
                fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
