import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tree_expert/core/styles/app_colors.dart';

import '../controller/profile_controller.dart';

/*class FaqPage extends StatelessWidget {
  const FaqPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: Get.back,
          icon: Icon(Icons.arrow_back),
        ),
        title: Text(
          "FAQ",
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
                Icons.help_outline,
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
                "Frequently Asked Questions",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade700,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 12),
              Text(
                "We're working on compiling the most helpful answers to your questions. Check back soon!",
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}*/



/*class FaqPage extends StatefulWidget {
  const FaqPage({super.key});

  @override
  State<FaqPage> createState() => _FAQScreenState();
}

class _FAQScreenState extends State<FaqPage> {
  int? _selectedIndex;

  // final List<FAQItem> _faqList = [
  //   FAQItem(
  //     question: "What is Flutter and why should I use it?",
  //     answer: "Flutter is Google's UI toolkit for building natively compiled applications for mobile, web, and desktop from a single codebase. It uses the Dart programming language and provides a rich set of pre-designed widgets that help create beautiful, fast applications with expressive and flexible UI.",
  //   ),
  //   FAQItem(
  //     question: "How does Flutter handle different screen sizes?",
  //     answer: "Flutter uses a responsive design approach with MediaQuery and LayoutBuilder widgets to adapt to different screen sizes. You can create responsive layouts by checking the screen dimensions, orientation, and pixel density, then adjusting your UI accordingly.",
  //   ),
  //   FAQItem(
  //     question: "What is the difference between Stateless and Stateful widgets?",
  //     answer: "Stateless widgets are immutable, meaning their properties can't change. They're used for static content. Stateful widgets maintain state that might change during the lifetime of the widget. When the state changes, the widget rebuilds its UI to reflect the new state.",
  //   ),
  //   FAQItem(
  //     question: "Can I use native Android/iOS code with Flutter?",
  //     answer: "Yes, Flutter provides platform channels that allow you to communicate between Dart code and native Kotlin/Java (Android) or Swift/Objective-C (iOS) code. This allows you to access platform-specific APIs and features not available in Flutter.",
  //   ),
  //   FAQItem(
  //     question: "How does Flutter achieve high performance?",
  //     answer: "Flutter compiles to native ARM code for mobile devices, which gives it performance close to native apps. It also uses Skia for rendering, which allows it to bypass the OEM widget system and draw directly to the canvas, reducing performance overhead.",
  //   ),
  //   FAQItem(
  //     question: "What are the best practices for state management in Flutter?",
  //     answer: "Flutter offers multiple state management approaches. For simple apps, setState works well. For complex apps, Provider, Riverpod, Bloc, GetX, or Redux are popular choices. The best approach depends on your app's complexity and team preferences.",
  //   ),
  //   FAQItem(
  //     question: "Is Flutter suitable for web and desktop applications?",
  //     answer: "Yes, Flutter supports web, Windows, macOS, and Linux in addition to mobile platforms. While web and desktop support are stable, some plugins might not be available for all platforms, so you may need to write platform-specific code for certain features.",
  //   ),
  // ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        leading: IconButton(
          onPressed: Get.back,
          icon: Icon(Icons.arrow_back),
        ),
        title: Text(
          "FAQ",
          style: context.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Section
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColors.primaryLight,
                      //[800]!,
                      AppColors.primary
                      //[900]!,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primaryDark.withOpacity(0.3),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.help_outline,
                      size: 30,
                      color: Colors.white,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      "Have Questions?",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Find answers to commonly asked questions about Flutter development",
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white.withOpacity(0.9),
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.info_outline,
                            size: 16,
                            color: Colors.white.withOpacity(0.9),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            "${_faqList.length} Questions Available",
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.white.withOpacity(0.9),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              // FAQ Section Title
              Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: Text(
                  "Common Questions",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[800],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // FAQ Items
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _faqList.length,
                separatorBuilder: (context, index) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  return FAQCard(
                    faqItem: _faqList[index],
                    isExpanded: _selectedIndex == index,
                    onTap: () {
                      setState(() {
                        if (_selectedIndex == index) {
                          // If clicking the same item, close it
                          _selectedIndex = null;
                        } else {
                          // Open the clicked item
                          _selectedIndex = index;
                        }
                      });
                    },
                    index: index,
                  );
                },
              ),

              // const SizedBox(height: 40),
              //
              // // Footer Note
              // Container(
              //   width: double.infinity,
              //   padding: const EdgeInsets.all(16),
              //   decoration: BoxDecoration(
              //     color: Colors.blue[50],
              //     borderRadius: BorderRadius.circular(12),
              //     border: Border.all(color: Colors.blue[100]!),
              //   ),
              //   child: Row(
              //     children: [
              //       Icon(
              //         Icons.email_outlined,
              //         color: Colors.blue[700],
              //       ),
              //       const SizedBox(width: 12),
              //       Expanded(
              //         child: Text(
              //           "Still have questions? Contact our support team at support@example.com",
              //           style: TextStyle(
              //             color: Colors.blue[800],
              //             fontSize: 14,
              //           ),
              //         ),
              //       ),
              //     ],
              //   ),
              // ),
            ],
          ),
        ),
      ),
    );
  }
}

class FAQItem {
  final String question;
  final String answer;

  FAQItem({
    required this.question,
    required this.answer,
  });
}

class FAQCard extends StatelessWidget {
  final FAQItem faqItem;
  final bool isExpanded;
  final VoidCallback onTap;
  final int index;

  const FAQCard({
    super.key,
    required this.faqItem,
    required this.isExpanded,
    required this.onTap,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
        border: Border.all(
          color: isExpanded ? AppColors.primaryLight! : Colors.grey[200]!,
          width: 1.5,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Question Row
                Row(
                  children: [
                    // Number indicator
                    Container(
                      width: 28,
                      height: 28,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: isExpanded ? AppColors.primaryDark : Colors.grey[300],
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        '${index + 1}',
                        style: TextStyle(
                          color: isExpanded ? Colors.white : Colors.grey[700],
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ),

                    const SizedBox(width: 16),

                    // Question text
                    Expanded(
                      child: Text(
                        faqItem.question,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: isExpanded ? AppColors.primaryDark : Colors.grey[800],
                        ),
                      ),
                    ),

                    // Expand/collapse icon
                    Icon(
                      isExpanded
                          ? Icons.keyboard_arrow_up_rounded
                          : Icons.keyboard_arrow_down_rounded,
                      color: isExpanded ? AppColors.primaryDark : Colors.grey[500],
                      size: 24,
                    ),
                  ],
                ),

                // Answer (shown when expanded)
                if (isExpanded) ...[
                  const SizedBox(height: 16),
                  Container(
                    height: 1,
                    color: Colors.grey[300],
                  ),
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.only(left: 44.0),
                    child: Text(
                      faqItem.answer,
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.grey[700],
                        height: 1.6,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.only(left: 44.0),
                    child: Row(
                      children: [
                        Icon(
                          Icons.check_circle_outline,
                          size: 16,
                          color: Colors.green[600],
                        ),
                        const SizedBox(width: 6),
                        Text(
                          "Answered",
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.green[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}*/




class FaqPage extends GetView<ProfileController> {
  const FaqPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        leading: IconButton(
          onPressed: Get.back,
          icon: const Icon(Icons.arrow_back),
        ),
        title: Text(
          "FAQ",
          style: context.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),
        centerTitle: true,
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        else if(controller.faqs.isEmpty){
          Center(
            child: Padding(
              padding: const EdgeInsets.all(40.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.help_outline,
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
                    "Frequently Asked Questions",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade700,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 12),
                  Text(
                    "We're working on compiling the most helpful answers to your questions. Check back soon!",
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        }
        return SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// HEADER
                _header(context),

                const SizedBox(height: 30),

                Text(
                  "Common Questions",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[800],
                  ),
                ),

                const SizedBox(height: 16),

                /// FAQ LIST FROM API
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: controller.faqs.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final faq = controller.faqs[index];

                    return Obx(() {
                      final isExpanded =
                          controller.selectedFaqIndex.value == index;

                      return FAQCard(
                        question: faq.question,
                        answer: faq.answer,
                        index: index,
                        isExpanded: isExpanded,
                        onTap: () {
                          controller.selectedFaqIndex.value =
                          isExpanded ? -1 : index;
                        },
                      );
                    });
                  },
                ),
              ],
            ),
          ),
        );
      }),
    );
  }

  /// HEADER WIDGET
  Widget _header(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primaryLight!,
            AppColors.primary!,
          ],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Obx(() {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.help_outline, size: 30, color: Colors.white),
            const SizedBox(height: 16),
            const Text(
              "Have Questions?",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "${controller.faqs.length} Questions Available",
              style: TextStyle(
                fontSize: 14,
                color: Colors.white.withOpacity(0.9),
              ),
            ),
          ],
        );
      }),
    );
  }
}




class FAQCard extends StatelessWidget {
  final String question;
  final String answer;
  final bool isExpanded;
  final VoidCallback onTap;
  final int index;

  const FAQCard({
    super.key,
    required this.question,
    required this.answer,
    required this.isExpanded,
    required this.onTap,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isExpanded ? AppColors.primaryLight! : Colors.grey[200]!,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 14,
                    backgroundColor:
                    isExpanded ? AppColors.primary : Colors.grey[300],
                    child: Text(
                      '${index + 1}',
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      question,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: isExpanded
                            ? AppColors.primaryDark
                            : Colors.grey[800],
                      ),
                    ),
                  ),
                  Icon(
                    isExpanded
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                  ),
                ],
              ),
              if (isExpanded) ...[
                const SizedBox(height: 16),
                Divider(color: Colors.grey[300]),
                const SizedBox(height: 8),
                Text(
                  answer,
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.grey[700],
                    height: 1.6,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

