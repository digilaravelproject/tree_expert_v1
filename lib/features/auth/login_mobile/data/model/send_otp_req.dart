class SendOtpRequest {
  final String phoneCountryCode;
  final String phone;

  SendOtpRequest({
    required this.phoneCountryCode,
    required this.phone,
  });

  Map<String, dynamic> toJson() {
    return {
      'phone_country_code': phoneCountryCode,
      'phone': phone,
    };
  }
}
