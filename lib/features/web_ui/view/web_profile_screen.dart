import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tool_bocs/features/login_and_signup/controller/auth_controller.dart';
import 'package:tool_bocs/util/colors.dart';
import 'package:tool_bocs/core/widgets/app_cached_image.dart';
import 'package:tool_bocs/features/web_ui/view/web_logout_dialog.dart';
import 'package:tool_bocs/routes/app_routes.dart';

class WebProfileScreen extends StatelessWidget {
  const WebProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authController = context.watch<AuthController>();
    final user = authController.currentUser;

    if (user == null) {
      return const Center(child: Text("Please log in to view your profile."));
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "My Profile",
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),

          // Profile Header Card
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                )
              ]
            ),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(50),
                  child: Container(
                    width: 100,
                    height: 100,
                    color: context.primaryColor.withOpacity(0.1),
                    child: Icon(Icons.person, size: 50, color: context.primaryColor),
                  ),
                ),
                const SizedBox(width: 32),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user.fullName,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        user.email,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          ElevatedButton.icon(
                            onPressed: () {
                              Navigator.pushNamed(context, AppRoutes.editProfile);
                            },
                            icon: const Icon(Icons.edit, size: 16),
                            label: const Text("Edit Profile"),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
                
                // Stats Box
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Theme.of(context).scaffoldBackgroundColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      Text(
                        "4.8",
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: context.primaryColor,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: List.generate(5, (index) => Icon(
                          Icons.star,
                          size: 16,
                          color: index < 4 ? Colors.amber : Colors.grey.shade300,
                        )),
                      ),
                      const SizedBox(height: 4),
                      Text("User Rating", style: TextStyle(color: Colors.grey.shade600)),
                    ],
                  ),
                )
              ],
            ),
          ),
          
          const SizedBox(height: 40),
          
          // Action Grid
          const Text(
            "Account Options",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          GridView.count(
            crossAxisCount: 3,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 2.5,
            children: [
              _buildOptionCard(
                context, 
                icon: Icons.history, 
                title: "Trade History", 
                onTap: () => Navigator.pushNamed(context, AppRoutes.tradeHistory)
              ),
              _buildOptionCard(
                context, 
                icon: Icons.list_alt, 
                title: "My Posts", 
                onTap: () => Navigator.pushNamed(context, AppRoutes.myPosts)
              ),
              _buildOptionCard(
                context, 
                icon: Icons.star_border, 
                title: "All Reviews", 
                onTap: () => Navigator.pushNamed(context, AppRoutes.allReviews)
              ),
              _buildOptionCard(
                context, 
                icon: Icons.bookmark_border, 
                title: "Saved Users", 
                onTap: () => Navigator.pushNamed(context, AppRoutes.savedUsers)
              ),
              _buildOptionCard(
                context, 
                icon: Icons.block, 
                title: "Blocked Users", 
                onTap: () => Navigator.pushNamed(context, AppRoutes.blockedUsers)
              ),
              _buildOptionCard(
                context, 
                icon: Icons.settings, 
                title: "Settings & Preferences", 
                onTap: () => Navigator.pushNamed(context, AppRoutes.settings)
              ),
              _buildOptionCard(
                context, 
                icon: Icons.logout, 
                title: "Logout", 
                isDestructive: true,
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (context) => const WebLogoutDialog(),
                  );
                }
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildOptionCard(BuildContext context, {
    required IconData icon, 
    required String title, 
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isDestructive ? Colors.red.withOpacity(0.3) : greyColor.withOpacity(0.2)),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Row(
          children: [
            Icon(icon, color: isDestructive ? Colors.red : context.primaryColor, size: 28),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                  color: isDestructive ? Colors.red : null,
                ),
              ),
            ),
            Icon(Icons.chevron_right, color: Colors.grey.shade400),
          ],
        ),
      ),
    );
  }
}
