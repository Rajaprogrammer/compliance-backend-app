class AppConstants {
  static const String backendBaseUrl = "https://lease-moore-others-montreal.trycloudflare.com/.netlify/functions";
  static const String timezone = "Asia/Kolkata";
  
  static const String firebaseApiKey = "AIzaSyCnWS-V96J6YDBVYKOeL5p8aa45GPTdSEg";
  static const String firebaseAuthDomain = "compliance-management-484405.firebaseapp.com";
  static const String firebaseProjectId = "compliance-management-484405";
  static const String firebaseStorageBucket = "compliance-management-484405.firebasestorage.app";
  static const String firebaseMessagingSenderId = "4348274796";
  static const String firebaseAppId = "1:4348274796:web:a9e1720c2ae223035bd049";
  
  static const String rolePartner = 'PARTNER';
  static const String roleManager = 'MANAGER';
  static const String roleAssociate = 'ASSOCIATE';
  
  static const List<String> taskStatuses = [
    'PENDING', 'IN_PROGRESS', 'CLIENT_PENDING', 'APPROVAL_PENDING', 'COMPLETED'
  ];
  
  static const List<String> categories = [
    'GST', 'TDS', 'INCOME_TAX', 'ROC', 'ACCOUNTING', 'AUDIT', 'OTHER'
  ];
  
  static const List<String> priorities = ['HIGH', 'MEDIUM', 'LOW'];
}
