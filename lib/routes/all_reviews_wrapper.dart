import 'package:flutter/material.dart';
import 'package:tool_bocs/l10n/generated/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:tool_bocs/core/widgets/responsive_layout.dart';
import 'package:tool_bocs/features/profile/controller/profile_controller.dart';
import 'package:tool_bocs/features/profile/model/user_profile_model.dart';
import 'package:tool_bocs/features/profile/view/all_reviews_screen.dart';
import 'package:tool_bocs/features/web_ui/view/web_all_reviews_screen.dart';

class AllReviewsWrapper extends StatefulWidget {
  final UserProfileModel? initialProfile;

  const AllReviewsWrapper({super.key, this.initialProfile});

  @override
  State<AllReviewsWrapper> createState() => _AllReviewsWrapperState();
}

class _AllReviewsWrapperState extends State<AllReviewsWrapper> {
  @override
  void initState() {
    super.initState();
    if (widget.initialProfile == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        // Fetch the current user's profile if no profile was passed
        context.read<ProfileController>().getUserProfile(null, isOwnProfile: true);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.initialProfile != null) {
      return ResponsiveLayout(
        mobileScreen: AllReviewsScreen(profile: widget.initialProfile!),
        webScreen: WebAllReviewsScreen(profile: widget.initialProfile!),
      );
    }

    return Consumer<ProfileController>(
      builder: (context, controller, child) {
        if (controller.isLoading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final profile = controller.userProfile;
        if (profile != null) {
          return ResponsiveLayout(
            mobileScreen: AllReviewsScreen(profile: profile),
            webScreen: WebAllReviewsScreen(profile: profile),
          );
        }

        return Scaffold(
          appBar: AppBar(title: Text(AppLocalizations.of(context)!.reviews)),
          body: Center(child: Text(AppLocalizations.of(context)!.errorProfileNotFound)),
        );
      },
    );
  }
}
