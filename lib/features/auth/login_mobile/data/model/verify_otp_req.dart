class VerifyOtpRequest {
  final String phoneCountryCode;
  final String phone;
  final String otp;

  VerifyOtpRequest({
    required this.phoneCountryCode,
    required this.phone,
    required this.otp,
  });

  Map<String, dynamic> toJson() {
    return {
      'phone_country_code': phoneCountryCode,
      'phone': phone,
      'otp': otp,
    };
  }
}
