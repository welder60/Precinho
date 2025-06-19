import 'package:dio/dio.dart';
import '../../core/constants/app_constants.dart';
import '../../core/errors/failures.dart';

class ApiService {
  late final Dio _dio;
  String? _authToken;

  ApiService({Dio? dio}) {
    _dio = dio ?? Dio();
    _setupInterceptors();
  }

  void _setupInterceptors() {
    _dio.options.baseUrl = AppConstants.baseUrl;
    _dio.options.connectTimeout = const Duration(milliseconds: AppConstants.timeoutDuration);
    _dio.options.receiveTimeout = const Duration(milliseconds: AppConstants.timeoutDuration);

    // Interceptor para adicionar token de autenticação
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          if (_authToken != null) {
            options.headers['Authorization'] = 'Bearer $_authToken';
          }
          options.headers['Content-Type'] = 'application/json';
          handler.next(options);
        },
        onError: (error, handler) {
          final failure = _handleDioError(error);
          handler.reject(DioException(
            requestOptions: error.requestOptions,
            error: failure,
            type: DioExceptionType.unknown,
          ));
        },
      ),
    );

    // Interceptor para logging (apenas em debug)
    _dio.interceptors.add(LogInterceptor(
      requestBody: true,
      responseBody: true,
      logPrint: (object) {
        // Log apenas em modo debug
        print(object);
      },
    ));
  }

  void setAuthToken(String token) {
    _authToken = token;
  }

  void clearAuthToken() {
    _authToken = null;
  }

  // Métodos HTTP genéricos
  Future<Map<String, dynamic>> get(
    String endpoint, {
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final response = await _dio.get(
        endpoint,
        queryParameters: queryParameters,
      );
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<Map<String, dynamic>> post(
    String endpoint, {
    Map<String, dynamic>? data,
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final response = await _dio.post(
        endpoint,
        data: data,
        queryParameters: queryParameters,
      );
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<Map<String, dynamic>> put(
    String endpoint, {
    Map<String, dynamic>? data,
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final response = await _dio.put(
        endpoint,
        data: data,
        queryParameters: queryParameters,
      );
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<Map<String, dynamic>> delete(
    String endpoint, {
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final response = await _dio.delete(
        endpoint,
        queryParameters: queryParameters,
      );
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  // Upload de arquivo
  Future<Map<String, dynamic>> uploadFile(
    String endpoint,
    String filePath, {
    String fieldName = 'file',
    Map<String, dynamic>? additionalData,
  }) async {
    try {
      final formData = FormData.fromMap({
        fieldName: await MultipartFile.fromFile(filePath),
        ...?additionalData,
      });

      final response = await _dio.post(
        endpoint,
        data: formData,
      );
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  // Download de arquivo
  Future<void> downloadFile(
    String endpoint,
    String savePath, {
    Map<String, dynamic>? queryParameters,
    ProgressCallback? onReceiveProgress,
  }) async {
    try {
      await _dio.download(
        endpoint,
        savePath,
        queryParameters: queryParameters,
        onReceiveProgress: onReceiveProgress,
      );
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Failure _handleDioError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return const NetworkFailure(
          message: 'Tempo limite de conexão excedido',
        );

      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode;
        final message = _getErrorMessageFromResponse(error.response);

        switch (statusCode) {
          case 400:
            return ValidationFailure(message: message, code: statusCode);
          case 401:
            return AuthenticationFailure(message: message, code: statusCode);
          case 403:
            return PermissionFailure(message: message, code: statusCode);
          case 404:
            return ServerFailure(message: 'Recurso não encontrado', code: statusCode);
          case 500:
          case 502:
          case 503:
            return ServerFailure(message: 'Erro interno do servidor', code: statusCode);
          default:
            return ServerFailure(message: message, code: statusCode);
        }

      case DioExceptionType.cancel:
        return const UnknownFailure(message: 'Requisição cancelada');

      case DioExceptionType.connectionError:
        return const NetworkFailure(
          message: 'Erro de conexão. Verifique sua internet',
        );

      case DioExceptionType.badCertificate:
        return const NetworkFailure(
          message: 'Erro de certificado SSL',
        );

      case DioExceptionType.unknown:
      default:
        return UnknownFailure(
          message: 'Erro desconhecido: ${error.message}',
        );
    }
  }

  String _getErrorMessageFromResponse(Response? response) {
    if (response?.data is Map<String, dynamic>) {
      final data = response!.data as Map<String, dynamic>;
      return data['message'] ?? data['error'] ?? 'Erro no servidor';
    }
    return 'Erro no servidor';
  }

  // Métodos específicos da API

  // Usuários
  Future<Map<String, dynamic>> getUserProfile(String userId) async {
    return await get('/users/$userId');
  }

  Future<Map<String, dynamic>> updateUserProfile(
    String userId,
    Map<String, dynamic> userData,
  ) async {
    return await put('/users/$userId', data: userData);
  }

  // Produtos
  Future<Map<String, dynamic>> getProducts({
    int page = 1,
    int limit = 20,
    String? search,
    String? category,
  }) async {
    return await get('/products', queryParameters: {
      'page': page,
      'limit': limit,
      if (search != null) 'search': search,
      if (category != null) 'category': category,
    });
  }

  Future<Map<String, dynamic>> createProduct(Map<String, dynamic> productData) async {
    return await post('/products', data: productData);
  }

  Future<Map<String, dynamic>> updateProduct(
    String id,
    Map<String, dynamic> productData,
  ) async {
    return await put('/products/$id', data: productData);
  }

  // Preços
  Future<Map<String, dynamic>> getPrices({
    required double latitude,
    required double longitude,
    double radius = 5.0,
    String? productId,
    int page = 1,
    int limit = 20,
  }) async {
    return await get('/prices', queryParameters: {
      'latitude': latitude,
      'longitude': longitude,
      'radius': radius,
      if (productId != null) 'product_id': productId,
      'page': page,
      'limit': limit,
    });
  }

  Future<Map<String, dynamic>> createPrice(Map<String, dynamic> priceData) async {
    return await post('/prices', data: priceData);
  }

  // Lojas
  Future<Map<String, dynamic>> getStores({
    required double latitude,
    required double longitude,
    double radius = 5.0,
    String? category,
    int page = 1,
    int limit = 20,
  }) async {
    return await get('/stores', queryParameters: {
      'latitude': latitude,
      'longitude': longitude,
      'radius': radius,
      if (category != null) 'category': category,
      'page': page,
      'limit': limit,
    });
  }

  Future<Map<String, dynamic>> createStore(Map<String, dynamic> storeData) async {
    return await post('/stores', data: storeData);
  }

  Future<Map<String, dynamic>> updateStore(
    String id,
    Map<String, dynamic> storeData,
  ) async {
    return await put('/stores/$id', data: storeData);
  }

  // Listas de compras
  Future<Map<String, dynamic>> getShoppingLists(String userId) async {
    return await get('/users/$userId/shopping-lists');
  }

  Future<Map<String, dynamic>> createShoppingList(
    String userId,
    Map<String, dynamic> listData,
  ) async {
    return await post('/users/$userId/shopping-lists', data: listData);
  }

  Future<Map<String, dynamic>> updateShoppingList(
    String userId,
    String listId,
    Map<String, dynamic> listData,
  ) async {
    return await put('/users/$userId/shopping-lists/$listId', data: listData);
  }

  Future<void> deleteShoppingList(String userId, String listId) async {
    await delete('/users/$userId/shopping-lists/$listId');
  }
}

