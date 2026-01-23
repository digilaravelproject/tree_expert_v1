class ApiConstants {
    ApiConstants._();

    static const String baseUrl = "https://darkorange-baboon-922736.hostingersite.com/public";
    static const String apiBaseUrl = "$baseUrl/api/";

    static const String xApiKey = "X-API-KEY";
    static const String xApiValue = "vov5_EpoeWDnr0YSMZ83VTY4c39oi09HXhkrz";
    static const String authorization = "Authorization";

    // User Auth Endpoints
    static const String loginWithOtp = "login-with-otp"; //missing
    static const String otpVerify = "otp-verify";  //missing
    static const String userRegister = "user_register";

    static const String loginEmailWithPassward = "login";
    static const String logout = "logout";
    static const String userProfile = "users"; // users/{id}
    static const String uploadProfileImage = "upload-profile-image";

    // Password Reset Endpoints
    static const String sendOtp = "password/send-otp";
    static const String verifyOtp = "password/verify-otp";
    static const String resetPassword = "password/reset";

    static const String dashboard = "dashboard";
    static const String userRating = "user/rating";
    static const String contacts = "contacts";
    static const String notes = "notes";
    static const String privacyPolicy = "privacy-policy";





}
