import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../../../../core/styles/app_decoration.dart';
import '../../../../../widgets/custom_buttons.dart';
import '../controller/company_login_controller.dart';

class EmailOtpVerificationPage extends StatefulWidget {
  final CompanyLoginController controller;

  const EmailOtpVerificationPage({super.key, required this.controller});

  @override
  State<EmailOtpVerificationPage> createState() =>
      _EmailOtpVerificationPageState();

  static show(CompanyLoginController c) {
    Get.to(
          () => EmailOtpVerificationPage(controller: c),
      transition: Transition.rightToLeft,
    );
  }
}

class _EmailOtpVerificationPageState extends State<EmailOtpVerificationPage> {
  final List<TextEditingController> otpControllers = List.generate(
    6,
        (_) => TextEditingController(),
  );

  final List<FocusNode> otpFocusNodes = List.generate(6, (_) => FocusNode());

  final RxInt countdown = 30.obs;
  final RxBool isResendEnabled = false.obs;

  @override
  void initState() {
    super.initState();
    startCountdown();
  }

  void startCountdown() {
    Future.delayed(const Duration(seconds: 1), () {
      if (!mounted) return;
      if (countdown.value > 0) {
        countdown.value--;
        startCountdown();
      } else {
        isResendEnabled.value = true;
      }
    });
  }

  void resetTimer() {
    countdown.value = 30;
    isResendEnabled.value = false;
    startCountdown();
    widget.controller.resendEmailOtp();
  }

  String getOtp() {
    return otpControllers.map((c) => c.text).join();
  }

  @override
  void dispose() {
    for (var controller in otpControllers) {
      controller.dispose();
    }
    for (var focusNode in otpFocusNodes) {
      focusNode.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.theme.primaryColorLight,
      extendBody: true,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Container(
            decoration: AppDecorations.bottomSheetDecoration(context),
            child: Padding(
              padding: EdgeInsets.only(
                left: 24,
                right: 24,
                top: 24,
                bottom: context.mediaQueryPadding.bottom + 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  /// Handle bar
                  Container(
                    width: 50,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),

                  const SizedBox(height: 32),

                  /// Icon
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: context.theme.primaryColor.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.email_outlined,
                      size: 52,
                      color: context.theme.primaryColor,
                    ),
                  ),

                  const SizedBox(height: 24),

                  /// Title
                  Text(
                    "Verify Your Email",
                    style: context.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 8),

                  /// Subtext
                  Text(
                    "Enter the 6-digit code sent to\n${widget.controller.forgotEmailController.text}",
                    textAlign: TextAlign.center,
                    style: context.textTheme.bodyMedium?.copyWith(
                      color: Colors.grey.shade600,
                      height: 1.4,
                    ),
                  ),

                  const SizedBox(height: 40),

                  /// OTP Boxes
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: List.generate(6, (index) {
                      return TextFormField(
                        controller: otpControllers[index],
                        focusNode: otpFocusNodes[index],
                        textAlign: TextAlign.center,
                        keyboardType: TextInputType.number,
                        maxLength: 1,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                        cursorHeight: 20,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly
                        ],
                        decoration: InputDecoration(
                          contentPadding: EdgeInsets.zero,
                          counterText: '',
                          constraints: const BoxConstraints.tightFor(
                            height: 50,
                            width: 50,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onChanged: (value) {
                          if (value.isNotEmpty && index < 5) {
                            otpFocusNodes[index + 1].requestFocus();
                          } else if (value.isEmpty && index > 0) {
                            otpFocusNodes[index - 1].requestFocus();
                          }
                        },
                      );
                    }),
                  ),

                  const SizedBox(height: 32),

                  /// Resend Text
                  Obx(() {
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Didn't receive code? ",
                          style: TextStyle(color: Colors.grey.shade600),
                        ),
                        GestureDetector(
                          onTap: isResendEnabled.value ? resetTimer : null,
                          child: Text(
                            isResendEnabled.value
                                ? "Resend OTP"
                                : "Resend in ${countdown.value}s",
                            style: TextStyle(
                              color: isResendEnabled.value
                                  ? context.theme.primaryColor
                                  : Colors.grey.shade500,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    );
                  }),

                  const SizedBox(height: 40),

                  /// Verify Button
                  Obx(
                        () => CustomButton(
                      onPressed: () {
                        widget.controller.verifyEmailOtp(getOtp());
                      },
                      title: "VERIFY & CONTINUE",
                      isLoading: widget.controller.isLoading.value,
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Back button
                  Center(
                    child: TextButton(
                      onPressed: () {
                        Get.back();
                      },
                      child: Text(
                        "Back to Forgot Password",
                        style: TextStyle(
                          color: context.theme.primaryColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}