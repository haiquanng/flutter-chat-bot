import 'package:flutter/material.dart';
import 'package:flutter_openai_stream/theme/colors.dart';
import 'package:flutter_openai_stream/widgets/sidebar_button.dart';

class SideBar extends StatefulWidget {
  const SideBar({super.key});

  @override
  State<SideBar> createState() => _SideBarState();
}

class _SideBarState extends State<SideBar> with TickerProviderStateMixin {
  bool isCollapsed = false;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    if (!isCollapsed) {
      _animationController.forward();
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _toggleSidebar() {
    setState(() {
      isCollapsed = !isCollapsed;
      if (isCollapsed) {
        _animationController.reverse();
      } else {
        _animationController.forward();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOut,
      width: isCollapsed ? 64 : 240,
      decoration: BoxDecoration(
        color: AppColors.sideNav,
        border: Border(
          right: BorderSide(
            // ignore: deprecated_member_use
            color: AppColors.searchBarBorder.withOpacity(0.3),
            width: 1,
          ),
        ),
      ),
      child: Column(
        children: [
          // Header Section
          Container(
            height: 64,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: [
                GestureDetector(
                  onTap: isCollapsed ? _toggleSidebar : null,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: isCollapsed
                          // ignore: deprecated_member_use
                          ? AppColors.primaryPurple.withOpacity(0.1)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.auto_awesome_mosaic,
                      color: AppColors.primaryPurple,
                      size: 24,
                    ),
                  ),
                ),
                if (!isCollapsed) ...[
                  const SizedBox(width: 12),
                  Expanded(
                    child: FadeTransition(
                      opacity: _fadeAnimation,
                      child: const Text(
                        'Chat Bot',
                        style: TextStyle(
                          color: AppColors.primaryPurple,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: _toggleSidebar,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.transparent,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Icon(
                        Icons.keyboard_arrow_left,
                        color: AppColors.iconGrey,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),

          // Divider
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 12),
            height: 1,
            color: AppColors.searchBarBorder.withOpacity(0.3),
          ),

          // Navigation Section
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (!isCollapsed)
                    FadeTransition(
                      opacity: _fadeAnimation,
                      child: const Padding(
                        padding:
                            EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: Text(
                          'Navigation',
                          style: TextStyle(
                            color: AppColors.textGrey,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ),
                  const SizedBox(height: 8),
                  SideBarButton(
                    isCollapsed: isCollapsed,
                    icon: Icons.add_circle_outline,
                    text: "New Chat",
                  ),
                  SideBarButton(
                    isCollapsed: isCollapsed,
                    icon: Icons.search_outlined,
                    text: "Search Chats",
                  ),
                  SideBarButton(
                    isCollapsed: isCollapsed,
                    icon: Icons.archive_outlined,
                    text: "Archived Chats",
                  ),
                  const SizedBox(height: 24),

                  // Recent Chats Section
                  if (!isCollapsed) ...[
                    FadeTransition(
                      opacity: _fadeAnimation,
                      child: const Padding(
                        padding:
                            EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: Row(
                          children: [
                            Text(
                              'Chats',
                              style: TextStyle(
                                color: AppColors.textGrey,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                letterSpacing: 0.5,
                              ),
                            ),
                            Spacer(),
                            Icon(
                              Icons.more_horiz,
                              color: AppColors.iconGrey,
                              size: 16,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Expanded(
                      child: FadeTransition(
                        opacity: _fadeAnimation,
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          itemCount: 2,
                          itemBuilder: (context, index) {
                            return Container(
                              margin: const EdgeInsets.only(bottom: 2),
                              child: ListTile(
                                dense: true,
                                contentPadding:
                                    const EdgeInsets.symmetric(horizontal: 8),
                                leading: Container(
                                  width: 6,
                                  height: 6,
                                  decoration: BoxDecoration(
                                    color: index == 0
                                        ? AppColors.primaryPurple
                                        : Colors.transparent,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                title: Text(
                                  index == 0 ? 'Chat 1' : 'Archived chats',
                                  style: TextStyle(
                                    color: AppColors.textGrey,
                                    fontSize: 14,
                                    fontWeight: index == 0
                                        ? FontWeight.w500
                                        : FontWeight.w400,
                                  ),
                                ),
                                trailing: Icon(
                                  Icons.more_horiz,
                                  color: AppColors.iconGrey.withOpacity(0.6),
                                  size: 16,
                                ),
                                onTap: () {
                                  // Handle chat selection
                                },
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),

          // Account Section
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(
                  color: AppColors.searchBarBorder.withOpacity(0.3),
                  width: 1,
                ),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppColors.primaryPurple,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      // ignore: deprecated_member_use
                      color: AppColors.primaryPurple.withOpacity(0.3),
                      width: 2,
                    ),
                  ),
                  child: const Icon(
                    Icons.person_outline,
                    color: AppColors.whiteColor,
                    size: 20,
                  ),
                ),
                if (!isCollapsed) ...[
                  const SizedBox(width: 12),
                  Expanded(
                    child: FadeTransition(
                      opacity: _fadeAnimation,
                      child: const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text(
                            'My Profile',
                            style: TextStyle(
                              color: AppColors.textGrey,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const Icon(
                    Icons.settings_outlined,
                    color: AppColors.iconGrey,
                    size: 18,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
