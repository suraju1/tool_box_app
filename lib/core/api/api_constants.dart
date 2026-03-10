class ApiConstants {
  // Base URL
  static const String baseUrl = 'https://toolbocs.apluscrm.in/api/';
  static const String baseUrl2 = 'https://toolbocs.apluscrm.in/';

//----------------------------------API Endpoints-------------------------------------//

  //1. Auth/login/complete-profile/verify-otp
  static const String completeProfile = 'complete-profile'; //post
  static const String login = 'login'; //post
  static const String verifyOtp = 'verify-otp'; //post

  //2. Categories types
  static const String getCategoryTypes = 'get_categories'; //get

  //3. give post- getAll/getbyid/create/update/delete
  static const String createGiveTakePost = 'create_post'; //post
  static const String getAllGiveTakePost = 'get_posts'; //post
  static const String getGiveTakePostById = 'get_post_by_id/{{postid}}'; //get
  static const String updateGiveTakePost = 'update_post/{{postid}}'; //put
  static const String deleteGiveTakePost = 'delete_post/{{postid}}'; //delete

  // 4-Step Trade Flow
  static const String respondToPost = 'respond/{{postid}}'; //post
  static const String getPostResponses = 'responses/{{postid}}'; //get
  static const String getMyPostResponses = 'my-post-responses'; //get
  static const String getMyResponses = 'my-responses'; //get
  static const String updateResponseStatus = 'update_response_status'; //post
  static const String processTradePayment = 'process_trade_payment'; //post
  static const String completeTrade = 'complete/{{id}}'; //post
  static const String getUserProfile = 'get_user_profile/{{id}}'; //get
  static const String submitUserReview = 'submit_user_review'; //post
  static const String updateProfile = 'update_profile'; //post

//-----------------------------------------------------------------------------//
  // Timeout durations
  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
  static const Duration sendTimeout = Duration(seconds: 30);

  // Retry configuration
  static const int maxRetries = 3;
  static const Duration retryDelay = Duration(seconds: 2);

  // Storage keys
  static const String authTokenKey = 'auth_token';
  static const String userDataKey = 'user_data';
  static const String isLoggedInKey = 'is_logged_in';
}
