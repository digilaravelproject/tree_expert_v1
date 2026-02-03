import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tree_expert/core/styles/app_colors.dart';

/*
class NotificationPage extends StatelessWidget {
  const NotificationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(onPressed: Get.back, icon: Icon(Icons.arrow_back)),
        title: Text(
          "Notifications",
          style: context.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),
        centerTitle: true,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(40.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.notifications_none,
                size: 100,
                color: Colors.grey.shade300,
              ),
              SizedBox(height: 30),
              Text(
                "Coming Soon",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: context.theme.primaryColor,
                ),
              ),
              SizedBox(height: 16),
              Text(
                "Notifications",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade700,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 12),
              Text(
                "Stay updated with important alerts and updates. This feature will be available soon!",
                style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
*/

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  State<NotificationPage> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationPage> {
  // Notification data list
  final List<NotificationItem> _notifications = [
    NotificationItem(
      title: "Welcome to Our App!",
      description:
          "Thank you for installing our application. We hope you have a great experience.",
      time: "10:30 AM",
      date: "Today",
    ),
    NotificationItem(
      title: "New Message Received",
      description: "You have received a new message from John. Tap to read it.",
      time: "9:45 AM",
      date: "Today",
    ),
    NotificationItem(
      title: "App Update Available",
      description:
          "A new version of the app is available. Update now for new features and bug fixes.",
      time: "Yesterday",
      date: "8:15 PM",
    ),
    NotificationItem(
      title: "Payment Successful",
      description: "Your payment of ₹999 has been processed successfully.",
      time: "Yesterday",
      date: "3:20 PM",
    ),
    NotificationItem(
      title: "Reminder: Meeting at 2 PM",
      description:
          "Don't forget about your scheduled meeting with the team today at 2 PM.",
      time: "Mar 15",
      date: "11:00 AM",
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        leading: IconButton(onPressed: Get.back, icon: Icon(Icons.arrow_back)),
        title: Text(
          "Notifications",
          style: context.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Header with stats
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 4),
                    Text(
                      "All your alerts in one place",
                      style: TextStyle(fontSize: 16, color: Colors.grey[600],fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                // Container(
                //   padding: const EdgeInsets.symmetric(
                //     horizontal: 12,
                //     vertical: 6,
                //   ),
                //   decoration: BoxDecoration(
                //     color: Colors.blue[50],
                //     borderRadius: BorderRadius.circular(20),
                //   ),
                //   child: Row(
                //     children: [
                //       Icon(
                //         Icons.notifications_active,
                //         size: 16,
                //         color: Colors.blue[700],
                //       ),
                //       const SizedBox(width: 6),
                //       Text(
                //         "Recent",
                //         style: TextStyle(
                //           fontSize: 14,
                //           fontWeight: FontWeight.w500,
                //           color: Colors.blue[700],
                //         ),
                //       ),
                //     ],
                //   ),
                // ),
              ],
            ),
          ),

          // Notifications List
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: _notifications.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                return NotificationCard(notification: _notifications[index]);
              },
            ),
          ),

          // Bottom action bar
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.fromBorderSide(
                BorderSide(color: Colors.grey[200]!),
              ),
              // Border.top: BorderSide(color: Colors.grey[200]!),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton.icon(
                  onPressed: () {
                    // Clear all notifications
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text("Clear All Notifications"),
                        content: const Text(
                          "Are you sure you want to clear all notifications?",
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text("Cancel"),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text("All notifications cleared"),
                                  duration: Duration(seconds: 2),
                                ),
                              );
                            },
                            child: const Text(
                              "Clear All",
                              style: TextStyle(color: Colors.red),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                  icon: const Icon(Icons.delete_outline, size: 20),
                  label: const Text(
                    "Clear All",
                    style: TextStyle(fontSize: 14),
                  ),
                ),
                // ElevatedButton.icon(
                //   onPressed: () {
                //     // Settings action
                //     ScaffoldMessenger.of(context).showSnackBar(
                //       const SnackBar(
                //         content: Text("Notification settings opened"),
                //         duration: Duration(seconds: 2),
                //       ),
                //     );
                //   },
                //   icon: const Icon(Icons.settings, size: 18),
                //   label: const Text("Settings", style: TextStyle(fontSize: 14)),
                //   style: ElevatedButton.styleFrom(
                //     backgroundColor: Colors.blue[600],
                //     foregroundColor: Colors.white,
                //     padding: const EdgeInsets.symmetric(
                //       horizontal: 16,
                //       vertical: 10,
                //     ),
                //   ),
                // ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class NotificationItem {
  final String title;
  final String description;
  final String time;
  final String date;

  NotificationItem({
    required this.title,
    required this.description,
    required this.time,
    required this.date,
  });
}

class NotificationCard extends StatelessWidget {
  final NotificationItem notification;

  const NotificationCard({super.key, required this.notification});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(color: Colors.grey[200]!, width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon - Same for all notifications as requested
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: AppColors.primaryLight.withOpacity(0.3),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.notifications,
                color: AppColors.primary,
                size: 24,
              ),
            ),

            const SizedBox(width: 16),

            // Notification content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title and time
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          notification.title,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        notification.time,
                        style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                      ),
                    ],
                  ),

                  const SizedBox(height: 6),

                  // Description
                  Text(
                    notification.description,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[700],
                      height: 1.4,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),

                  const SizedBox(height: 10),

                  // Date and actions
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          notification.date,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      //
                      // Row(
                      //   children: [
                      //     IconButton(
                      //       onPressed: () {
                      //         // Mark as read/unread
                      //         ScaffoldMessenger.of(context).showSnackBar(
                      //           SnackBar(
                      //             content: Text(
                      //               "Marked '${notification.title}' as read",
                      //             ),
                      //             duration: const Duration(seconds: 2),
                      //           ),
                      //         );
                      //       },
                      //       icon: Icon(
                      //         Icons.check_circle_outline,
                      //         size: 20,
                      //         color: Colors.green[600],
                      //       ),
                      //       padding: EdgeInsets.zero,
                      //       constraints: const BoxConstraints(),
                      //     ),
                      //     const SizedBox(width: 12),
                      //     IconButton(
                      //       onPressed: () {
                      //         // Delete notification
                      //         ScaffoldMessenger.of(context).showSnackBar(
                      //           SnackBar(
                      //             content: Text(
                      //               "Deleted '${notification.title}'",
                      //             ),
                      //             duration: const Duration(seconds: 2),
                      //           ),
                      //         );
                      //       },
                      //       icon: Icon(
                      //         Icons.delete_outline,
                      //         size: 20,
                      //         color: Colors.red[400],
                      //       ),
                      //       padding: EdgeInsets.zero,
                      //       constraints: const BoxConstraints(),
                      //     ),
                      //   ],
                      // ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
