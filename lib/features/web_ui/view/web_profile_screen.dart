import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tool_bocs/features/login_and_signup/controller/auth_controller.dart';
import 'package:tool_bocs/util/colors.dart';
import 'package:tool_bocs/util/font_family.dart';
import 'package:tool_bocs/core/widgets/app_cached_image.dart';
import 'package:tool_bocs/routes/app_routes.dart';
import 'package:tool_bocs/features/profile/controller/profile_controller.dart';

class WebProfileScreen extends StatelessWidget {
  const WebProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authController = context.watch<AuthController>();
    final user = authController.currentUser;
    final profileController = context.watch<ProfileController>();
    final profileUser = profileController.ownProfile?.userDetails;

    if (user == null) {
      return const Center(child: Text("Please log in to view your profile."));
    }

    final String fullName = profileUser?.fullName ?? user.fullName;
    final String bioText = profileUser?.bio ??
        "Passionate about buying & selling new and used products\nExploring the best deals and connecting with trusted sellers on TryIt Marketplace.";

    final Color cardBgColor = Theme.of(context).brightness == Brightness.dark
        ? Colors.grey.shade900
        : const Color(0xFFF3F4F6);

    final Color innerCardBgColor = Theme.of(context).cardColor;
    final bool isNarrow = MediaQuery.of(context).size.width < 1100;
    final bool isMobile = MediaQuery.of(context).size.width < 700;

    return SingleChildScrollView(
      padding: EdgeInsets.all(isMobile ? 16 : 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "My Profile",
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              fontFamily: FontFamily.openSans,
            ),
          ),
          SizedBox(height: isMobile ? 16 : 24),

          // TOP CARD
          Container(
            padding: EdgeInsets.all(isMobile ? 16 : 32),
            decoration: BoxDecoration(
              color: cardBgColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: greyColor.withOpacity(0.2)),
            ),
            child: isNarrow
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildProfileDetails(context, profileUser, fullName, isMobile),
                      const SizedBox(height: 32),
                      _buildBioBox(bioText, innerCardBgColor),
                    ],
                  )
                : Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Left profile details
                      Expanded(
                        flex: 5,
                        child: _buildProfileDetails(context, profileUser, fullName, isMobile),
                      ),
                      const SizedBox(width: 32),
                      // Right Bio box
                      Expanded(
                        flex: 4,
                        child: _buildBioBox(bioText, innerCardBgColor),
                      ),
                    ],
                  ),
          ),

          SizedBox(height: isMobile ? 16 : 24),

          isNarrow
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildMarksOfSuraj(fullName, innerCardBgColor, cardBgColor, isMobile),
                    SizedBox(height: isMobile ? 16 : 24),
                    _buildTradeHistory(innerCardBgColor, cardBgColor, isMobile),
                  ],
                )
              : Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 5,
                      child: _buildMarksOfSuraj(fullName, innerCardBgColor, cardBgColor, isMobile),
                    ),
                    const SizedBox(width: 24),
                    Expanded(
                      flex: 4,
                      child: _buildTradeHistory(innerCardBgColor, cardBgColor, isMobile),
                    ),
                  ],
                ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildProfileDetails(BuildContext context, dynamic profileUser, String fullName, bool isMobile) {
    return isMobile
        ? Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _buildAvatar(profileUser, fullName, isMobile),
              const SizedBox(height: 24),
              _buildProfileTextAndButtons(context, profileUser, fullName, isMobile),
            ],
          )
        : Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _buildAvatar(profileUser, fullName, isMobile),
              const SizedBox(width: 32),
              Expanded(
                child: _buildProfileTextAndButtons(context, profileUser, fullName, isMobile),
              ),
            ],
          );
  }

  Widget _buildAvatar(dynamic profileUser, String fullName, bool isMobile) {
    final double size = isMobile ? 100 : 140;
    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(size / 2),
        child: AppCachedImage(
          imageUrl: profileUser?.image ?? '',
          userName: fullName,
          width: size,
          height: size,
          fit: BoxFit.cover,
          radius: size / 2,
        ),
      ),
    );
  }

  Widget _buildProfileTextAndButtons(BuildContext context, dynamic profileUser, String fullName, bool isMobile) {
    return Column(
      crossAxisAlignment: isMobile ? CrossAxisAlignment.center : CrossAxisAlignment.start,
      children: [
        Text(
          fullName,
          textAlign: isMobile ? TextAlign.center : TextAlign.start,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            fontFamily: FontFamily.openSans,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          [profileUser?.giverType, profileUser?.takerType]
                  .where((e) => e != null && e.isNotEmpty)
                  .join(' - ')
                  .isEmpty
              ? "Good Giver - Money Taker"
              : [profileUser?.giverType, profileUser?.takerType]
                  .where((e) => e != null && e.isNotEmpty)
                  .join(' - '),
          textAlign: isMobile ? TextAlign.center : TextAlign.start,
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey.shade600,
            fontFamily: FontFamily.openSans,
          ),
        ),
        const SizedBox(height: 24),
        Wrap(
          spacing: 16,
          runSpacing: 16,
          alignment: isMobile ? WrapAlignment.center : WrapAlignment.start,
          children: [
            SizedBox(
              height: 54,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.pushNamed(context, AppRoutes.editProfile);
                },
                icon: const Icon(Icons.edit, size: 16),
                label: const Text("Edit Profile"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  elevation: 0,
                ),
              ),
            ),
            Container(
              height: 54,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black, width: 1.5),
                borderRadius: BorderRadius.circular(30),
                color: Colors.transparent,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.credit_card, size: 18, color: Colors.black),
                  const SizedBox(width: 8),
                  Text(
                    "Credit Balance: ${profileUser?.remainingBalance ?? '50.00'}",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),
          ],
        )
      ],
    );
  }

  Widget _buildBioBox(String bioText, Color innerCardBgColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Bio",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: innerCardBgColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: greyColor.withOpacity(0.2)),
          ),
          child: Text(
            bioText,
            style: TextStyle(
              fontSize: 15,
              color: Colors.grey.shade600,
              height: 1.5,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMarksOfSuraj(String fullName, Color innerCardBgColor, Color cardBgColor, bool isMobile) {
    return Container(
      padding: EdgeInsets.all(isMobile ? 16 : 32),
      decoration: BoxDecoration(
        color: cardBgColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: greyColor.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Text(
                  "Marks of ${fullName.split(' ').first}",
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Icon(Icons.thumb_up_alt_outlined, size: 24),
                  SizedBox(width: 8),
                  Text("23", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  SizedBox(width: 24),
                  Icon(Icons.thumb_down_alt_outlined, size: 24),
                  SizedBox(width: 8),
                  Text("23", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                ],
              )
            ],
          ),
          const SizedBox(height: 24),
          // List of hardcoded marks
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: 4,
            separatorBuilder: (_, __) => const SizedBox(height: 16),
            itemBuilder: (context, index) {
              return Container(
                padding: EdgeInsets.all(isMobile ? 12 : 20),
                decoration: BoxDecoration(
                  color: innerCardBgColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: greyColor.withOpacity(0.2)),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: const BoxDecoration(
                        color: Color(0xFF65B741),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.check, color: Colors.white, size: 28),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Professional",
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "- Best cook ever!!",
                            style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
                          ),
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.black,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Text("True:2",
                                    style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  border: Border.all(color: Colors.black),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Text("False: 6",
                                    style: TextStyle(color: Colors.black, fontSize: 10, fontWeight: FontWeight.bold)),
                              ),
                            ],
                          )
                        ],
                      ),
                    )
                  ],
                ),
              );
            },
          )
        ],
      ),
    );
  }

  Widget _buildTradeHistory(Color innerCardBgColor, Color cardBgColor, bool isMobile) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isMobile ? 16 : 32),
      decoration: BoxDecoration(
        color: cardBgColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: greyColor.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Trade History",
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          LayoutBuilder(
            builder: (context, constraints) {
              final double cardWidth = isMobile ? constraints.maxWidth : (constraints.maxWidth - 32) / 3;
              return Wrap(
                spacing: 16,
                runSpacing: 16,
                children: [
                  SizedBox(
                      width: cardWidth,
                      child: _buildTradeHistoryCard(Icons.sync, Colors.greenAccent.shade700, "100", "Total Trades", innerCardBgColor)),
                  SizedBox(
                      width: cardWidth,
                      child: _buildTradeHistoryCard(Icons.thumb_up_alt_outlined, Colors.orange, "100", "Total Like", innerCardBgColor)),
                  SizedBox(
                      width: cardWidth,
                      child: _buildTradeHistoryCard(Icons.thumb_down_alt_outlined, Colors.red, "100", "Total Dislike", innerCardBgColor)),
                ],
              );
            },
          ),
          const SizedBox(height: 48),
          Center(
            child: ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.bookmark_border, size: 24),
              label: const Text("Save Profile"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 24),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Center(
            child: Text(
              "Your profile is saved by 22 users",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade800,
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildTradeHistoryCard(IconData icon, Color iconColor, String value, String title, Color bgColor) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 8),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.withOpacity(0.2)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: iconColor, size: 36),
          const SizedBox(height: 16),
          Text(
            value,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.grey.shade800),
          ),
        ],
      ),
    );
  }
}
