class AppConstants {
  static const String appName = 'KrishiLink';
  static const String appVersion = '1.0.0';

  // API Configuration
  static const String apiBaseUrl = 'http://localhost:3000/api';
  static const int apiTimeoutSeconds = 30;

  // User Roles
  static const String roleFarmer = 'farmer';
  static const String roleBuyer = 'buyer';
  static const String roleWorker = 'worker';
  static const String roleAdmin = 'admin';

  // Order Status
  static const String orderStatusPending = 'pending';
  static const String orderStatusConfirmed = 'confirmed';
  static const String orderStatusProcessing = 'processing';
  static const String orderStatusShipped = 'shipped';
  static const String orderStatusDelivered = 'delivered';
  static const String orderStatusCancelled = 'cancelled';

  // Tracking Status
  static const String trackingHarvested = 'harvested';
  static const String trackingPacked = 'packed';
  static const String trackingInTransit = 'in_transit';
  static const String trackingOutForDelivery = 'out_for_delivery';
  static const String trackingDelivered = 'delivered';

  // Job Status
  static const String jobStatusOpen = 'open';
  static const String jobStatusClosed = 'closed';
  static const String jobStatusFilled = 'filled';

  // Product Status
  static const String productStatusAvailable = 'available';
  static const String productStatusOutOfStock = 'out_of_stock';
  static const String productStatusDiscontinued = 'discontinued';

  // Application Status
  static const String applicationStatusPending = 'pending';
  static const String applicationStatusAccepted = 'accepted';
  static const String applicationStatusRejected = 'rejected';

  // Shared Preferences Keys
  static const String prefIsLoggedIn = 'isLoggedIn';
  static const String prefUserRole = 'userRole';
  static const String prefUserPhone = 'userPhone';
  static const String prefUserData = 'userData';
  static const String prefLanguage = 'language';
  static const String prefIsDarkMode = 'isDarkMode';
  static const String prefProducts = 'products';
  static const String prefOrders = 'orders';
  static const String prefJobs = 'jobs';

  // Demo Data
  static const String demoOtp = '123456';
  static const String demoPhone = '9876543210';

  // Payment Methods
  static const String paymentMethodCash = 'cash';
  static const String paymentMethodUPI = 'upi';
  static const String paymentMethodCard = 'card';
  static const String paymentMethodBankTransfer = 'bank_transfer';

  // Units
  static const List<String> units = [
    'kg',
    'g',
    'ton',
    'dozen',
    'piece',
    'liter'
  ];

  // Crop Categories
  static const List<String> categories = [
    'All',
    'Vegetables',
    'Fruits',
    'Grains',
    'Dairy',
    'Spices',
    'Pulses',
    'Others'
  ];

  // Support Contact
  static const String supportEmail = 'support@krishilink.com';
  static const String supportPhone = '+91 1800-123-4567';

  // Social Impact - UN SDGs
  static const List<String> sdgs = [
    'SDG 1: No Poverty',
    'SDG 2: Zero Hunger',
    'SDG 8: Decent Work',
    'SDG 10: Reduced Inequality'
  ];
}
