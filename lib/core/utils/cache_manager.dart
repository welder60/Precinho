import 'package:flutter_cache_manager/flutter_cache_manager.dart';

import '../constants/app_constants.dart';

class AppCacheManagers {
  AppCacheManagers._();

  static final BaseCacheManager imageCache = CacheManager(
    Config(
      'imageCache',
      stalePeriod: Duration(days: AppConstants.imageCacheDuration),
      maxNrOfCacheObjects: 200,
    ),
  );
}
