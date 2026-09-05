class ApiConstants {
    ApiConstants._();

 //   static const String baseUrl = "https://darkorange-baboon-922736.hostingersite.com/public";
    static const String baseUrl = "https://basilenv.in";
    static const String apiBaseUrl = "$baseUrl/api/";

    static const String xApiKey = "X-API-KEY";
    static const String xApiValue = "vov5_EpoeWDnr0YSMZ83VTY4c39oi09HXhkrz";
    static const String authorization = "Authorization";

    // User Auth Endpoints
    static const String sendLoginOtp = "send-login-otp";
    static const String otpVerify = "verify-otp";
    static const String userRegister = "user_register";

    static const String loginEmailWithPassward = "login";
    static const String logout = "logout";
    static const String getSingleUserData = "users"; // users/{id}
    static const String uploadProfileImage = "upload-profile-image";
    static const String updateProfileData = "upload-profile-image";
    static const String getTreeRequirements = "get_tree_requirements";

    // Password Reset Endpoints
    static const String sendOtp = "password/send-otp";
    static const String verifyOtp = "password/verify-otp";
    static const String resetPassword = "password/reset";
    static const String dashboard = "dashboard";
    static const String userRating = "user/rating";
    static const String contacts = "contacts";
    static const String notes = "notes";
    static const String privacyPolicy = "privacy-policy";
    static const String getStates = "states";
    static const String projectList = "project/list";
    static const String projectAssignOfficer = "project_assign_officer";
    static const String faqs = "faqs";
    static const String videos = "videos";
    static const String userSubscriptions = "user-subscriptions";
    static const String createProject = "customer/create-project";
    static const String updateProject = "customer/projects";
    static const String treeList = "tree-list";
    static const String treeDetails = "tree"; // tree/{id}
    static const String treeMeasure = "tree/measure";
    static const String saveTrees = "trees-add";
    static const String treeInProject = "tree_in_project";
    static const String addTree = "tree/add";
    static const String getProjectExportLinks = "get_project_export_links";
    static const String checkPhotoRequired = "customer/check-photo-required";


    // Payment
    static const String createPaymentOrder = "payment/create-order";
    static const String paymentVerify = "payment/verify";


}
