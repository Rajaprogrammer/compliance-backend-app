class AppConstants {
  static const String backendBaseUrl = "https://lease-moore-others-montreal.trycloudflare.com/.netlify/functions";
  static const String timezone = "Asia/Kolkata";
  
  // Firebase Config
  static const String firebaseApiKey = "AIzaSyCnWS-V96J6YDBVYKOeL5p8aa45GPTdSEg";
  static const String firebaseAuthDomain = "compliance-management-484405.firebaseapp.com";
  static const String firebaseProjectId = "compliance-management-484405";
  static const String firebaseStorageBucket = "compliance-management-484405.firebasestorage.app";
  static const String firebaseMessagingSenderId = "4348274796";
  static const String firebaseAppId = "1:4348274796:web:a9e1720c2ae223035bd049";
  
  // Roles
  static const String rolePartner = 'PARTNER';
  static const String roleManager = 'MANAGER';
  static const String roleAssociate = 'ASSOCIATE';
  
  // Task Statuses
  static const List<String> taskStatuses = [
    'PENDING',
    'IN_PROGRESS',
    'CLIENT_PENDING',
    'APPROVAL_PENDING',
    'COMPLETED',
  ];
  
  // Categories
  static const List<String> categories = [
    'GST',
    'TDS',
    'INCOME_TAX',
    'ROC',
    'ACCOUNTING',
    'AUDIT',
    'OTHER',
  ];
  
  // Priorities
  static const List<String> priorities = ['HIGH', 'MEDIUM', 'LOW'];
  
  // Recurrence Types
  static const List<String> recurrenceTypes = [
    'AD_HOC',
    'DAILY',
    'WEEKLY',
    'BIWEEKLY',
    'MONTHLY',
    'BIMONTHLY',
    'QUARTERLY',
    'HALF_YEARLY',
    'YEARLY',
  ];
  
  // Work Queue Modes
  static const List<String> workQueueModes = [
    'ACTIVE',
    'ALL',
    'SNOOZED',
    'APPROVAL',
    'COMPLETED',
  ];
  
  // Template Variables
  static const List<Map<String, String>> templateVariables = [
    {'name': 'Client Name', 'key': '{{clientName}}', 'desc': 'Client name'},
    {'name': 'Task Title', 'key': '{{taskTitle}}', 'desc': 'Task title'},
    {'name': 'Start Date', 'key': '{{startDate}}', 'desc': 'Start date (DD-MM-YYYY)'},
    {'name': 'Due Date', 'key': '{{dueDate}}', 'desc': 'Due date (DD-MM-YYYY)'},
    {'name': 'Calendar Link', 'key': '{{addToCalendarUrl}}', 'desc': 'Google Calendar link'},
    {'name': 'Completed At', 'key': '{{completedAt}}', 'desc': 'Completion time in IST'},
  ];
}
