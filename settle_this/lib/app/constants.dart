class AppConstants {
  AppConstants._();

  static const String appName = 'Settle This';
  static const String appTagline = 'AI Referee for everyday disputes';

  static const int minScenarioChars = 30;
  static const int maxScenarioChars = 3000;
  static const int maxSideChars = 1500;

  static const int minimumAge = 18;
  static const String currentDisclaimerVersion = 'v1';

  static const String entitlementSettlePlus = 'settle_plus';
  static const String revenueCatOfferingDefault = 'default';

  static const String firebaseEnv = String.fromEnvironment(
    'SETTLE_THIS_ENV',
    defaultValue: 'dev',
  );

  static const String revenueCatApiKey = String.fromEnvironment(
    'REVENUECAT_API_KEY',
    defaultValue: '',
  );

  static bool get isProd => firebaseEnv == 'prod';
}
