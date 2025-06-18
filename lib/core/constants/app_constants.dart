// Constantes da aplicação Precinho
class AppConstants {
  // Configurações gerais
  static const String appName = 'Precinho';
  static const String appVersion = '1.0.0';
  
  // Configurações de API
  static const String baseUrl = 'https://api.precinho.com';
  static const int timeoutDuration = 30000; // 30 segundos
  static const String googleMapsApiKey = 'YOUR_GOOGLE_MAPS_API_KEY';
  
  // Configurações de geolocalização
  static const double defaultSearchRadius = 5.0; // 5km
  static const double maxSearchRadius = 50.0; // 50km
  static const double minSearchRadius = 1.0; // 1km

  // Configurações de cache
  static const int imageCacheDuration = 7; // 7 dias
  static const int dataCacheDuration = 1; // 1 dia
  
  // Configurações de pontuação
  static const int pointsForPriceSubmission = 10;
  static const int pointsForStoreSubmission = 15;
  static const int pointsForProductSubmission = 5;
  static const int pointsForReview = 2;

  // Contas de administrador
  static const List<String> adminEmails = [
    'welder60@gmail.com',
    'admin@precinho.com',
  ];
  
  // Configurações de validação
  static const int minPasswordLength = 6;
  static const int maxProductNameLength = 100;
  static const int maxStoreNameLength = 100;
  static const int maxDescriptionLength = 500;
  
  // Configurações de imagem
  static const int maxImageSize = 5 * 1024 * 1024; // 5MB
  static const int imageQuality = 80;
  static const int thumbnailSize = 200;
  
  // Chaves de armazenamento local
  static const String userTokenKey = 'user_token';
  static const String userDataKey = 'user_data';
  static const String settingsKey = 'app_settings';
  static const String cacheKey = 'app_cache';
  
  // URLs de termos e política
  static const String termsOfServiceUrl = 'https://precinho.com/terms';
  static const String privacyPolicyUrl = 'https://precinho.com/privacy';
  static const String supportUrl = 'https://precinho.com/support';
}

