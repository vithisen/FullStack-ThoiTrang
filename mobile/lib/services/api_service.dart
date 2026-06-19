import 'dart:convert';
import 'dart:io';

import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static const String _currentUserIdKey = 'currentUserId';
  static int? currentUserId;

  static Future<void> initializeSession() async {
    final prefs = await SharedPreferences.getInstance();
    currentUserId = prefs.getInt(_currentUserIdKey);
  }

  static Future<void> clearSession() async {
    currentUserId = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_currentUserIdKey);
  }

  static String get baseUrl {
    const fromDefine = String.fromEnvironment('API_BASE_URL');
    if (fromDefine.isNotEmpty) return fromDefine;
    return 'https://fashion-shop-backend-yese.onrender.com/api';
  }

  static Future<Map<String, dynamic>> login(
    String email,
    String password,
  ) async {
    final data = await post('/auth/login', {
      'email': email,
      'passwordHash': password,
    });
    await _setCurrentUserId(data['id']);
    return data;
  }

  static Future<Map<String, dynamic>> googleLogin({
    required String email,
    required String displayName,
    required String firebaseUid,
    String? photoUrl,
    String? idToken,
  }) async {
    final data = await post('/auth/google', {
      'email': email,
      'displayName': displayName,
      'firebaseUid': firebaseUid,
      'photoUrl': photoUrl,
      'idToken': idToken,
    });
    await _setCurrentUserId(data['id']);
    return data;
  }

  static Future<Map<String, dynamic>> facebookLogin({
    String? email,
    required String displayName,
    required String firebaseUid,
    String? photoUrl,
    String? idToken,
  }) async {
    final data = await post('/auth/facebook', {
      'email': email,
      'displayName': displayName,
      'firebaseUid': firebaseUid,
      'photoUrl': photoUrl,
      'idToken': idToken,
    });
    await _setCurrentUserId(data['id']);
    return data;
  }

  static Future<Map<String, dynamic>> register(
    String name,
    String email,
    String password,
  ) async {
    final parts = name.trim().split(RegExp(r'\s+'));
    final firstName = parts.isEmpty ? name : parts.first;
    final lastName = parts.length > 1 ? parts.sublist(1).join(' ') : '';
    final data = await post('/auth/register', {
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'passwordHash': password,
    });
    await _setCurrentUserId(data['id']);
    return data;
  }

  static Future<void> _setCurrentUserId(Object? value) async {
    if (value is! int) return;
    currentUserId = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_currentUserIdKey, value);
  }

  static bool get hasSession => currentUserId != null;

  static int _requireCustomerId(int? customerId) {
    final resolvedId = customerId ?? currentUserId;
    if (resolvedId == null) {
      throw Exception('Please login first');
    }
    return resolvedId;
  }

  static Future<Map<String, dynamic>> forgotPassword(String email) {
    return post('/auth/forgot-password', {'email': email});
  }

  static Future<List<dynamic>> products({
    int? categoryId,
    int? brandId,
    String? q,
    double? minPrice,
    double? maxPrice,
    String? size,
    String? color,
    bool? saleOnly,
    String? sort,
  }) {
    final params = <String, String>{};
    if (categoryId != null) params['categoryId'] = '$categoryId';
    if (brandId != null) params['brandId'] = '$brandId';
    if (q != null && q.trim().isNotEmpty) params['q'] = q.trim();
    if (minPrice != null) params['minPrice'] = minPrice.toStringAsFixed(0);
    if (maxPrice != null) params['maxPrice'] = maxPrice.toStringAsFixed(0);
    if (size != null && size.trim().isNotEmpty) params['size'] = size.trim();
    if (color != null && color.trim().isNotEmpty) {
      params['color'] = color.trim();
    }
    if (saleOnly != null) params['saleOnly'] = '$saleOnly';
    if (sort != null && sort.trim().isNotEmpty) params['sort'] = sort.trim();
    final query = params.isEmpty
        ? ''
        : '?${Uri(queryParameters: params).query}';
    return getList('/products$query');
  }

  static Future<Map<String, dynamic>> productDetail(int productId) {
    return get('/products/$productId');
  }

  static Future<List<dynamic>> relatedProducts(int productId) {
    return getList('/products/$productId/related');
  }

  static Future<List<dynamic>> categories() => getList('/categories');

  static Future<List<dynamic>> brands() => getList('/brands');

  static Future<List<dynamic>> attributes() => getList('/attributes');

  static Future<List<dynamic>> slideshows() => getList('/slideshows');

  static Future<Map<String, dynamic>> cart({int? customerId}) {
    return get('/customers/${_requireCustomerId(customerId)}/cart');
  }

  static Future<Map<String, dynamic>> addCartItem(
    int productId, {
    int quantity = 1,
    String size = 'L',
    String color = 'Black',
    int? customerId,
  }) {
    return post('/customers/${_requireCustomerId(customerId)}/cart/items', {
      'productId': productId,
      'quantity': quantity,
      'size': size,
      'color': color,
    });
  }

  static Future<Map<String, dynamic>> updateCartItem(
    int itemId,
    int quantity, {
    int? customerId,
  }) {
    return patch(
      '/customers/${_requireCustomerId(customerId)}/cart/items/$itemId',
      {'quantity': quantity},
    );
  }

  static Future<void> deleteCartItem(int itemId, {int? customerId}) async {
    await delete(
      '/customers/${_requireCustomerId(customerId)}/cart/items/$itemId',
    );
  }

  static Future<List<dynamic>> favorites({int? customerId}) {
    return getList('/customers/${_requireCustomerId(customerId)}/favorites');
  }

  static Future<Map<String, dynamic>> addFavorite(
    int productId, {
    int? customerId,
  }) {
    return post('/customers/${_requireCustomerId(customerId)}/favorites', {
      'productId': productId,
    });
  }

  static Future<void> removeFavorite(int productId, {int? customerId}) async {
    await delete(
      '/customers/${_requireCustomerId(customerId)}/favorites/$productId',
    );
  }

  static Future<List<dynamic>> coupons() => getList('/coupons');

  static Future<List<dynamic>> shippingMethods() =>
      getList('/shipping-methods');

  static Future<Map<String, dynamic>> customer({int? customerId}) {
    return get('/customers/${_requireCustomerId(customerId)}');
  }

  static Future<Map<String, dynamic>> updateCustomer(
    Map<String, dynamic> body, {
    int? customerId,
  }) {
    return patch('/customers/${_requireCustomerId(customerId)}', body);
  }

  static Future<Map<String, dynamic>> changePassword(
    String oldPassword,
    String newPassword, {
    int? customerId,
  }) {
    return patch('/customers/${_requireCustomerId(customerId)}/password', {
      'oldPassword': oldPassword,
      'newPassword': newPassword,
    });
  }

  static Future<List<dynamic>> addresses({int? customerId}) {
    return getList('/customers/${_requireCustomerId(customerId)}/addresses');
  }

  static Future<Map<String, dynamic>> addAddress(
    Map<String, dynamic> body, {
    int? customerId,
  }) {
    return post('/customers/${_requireCustomerId(customerId)}/addresses', body);
  }

  static Future<Map<String, dynamic>> updateAddress(
    int addressId,
    Map<String, dynamic> body, {
    int? customerId,
  }) {
    return patch(
      '/customers/${_requireCustomerId(customerId)}/addresses/$addressId',
      body,
    );
  }

  static Future<void> deleteAddress(int addressId, {int? customerId}) async {
    await delete(
      '/customers/${_requireCustomerId(customerId)}/addresses/$addressId',
    );
  }

  static Future<List<dynamic>> reviews(int productId) =>
      getList('/products/$productId/reviews');

  static Future<Map<String, dynamic>> addReview(
    int productId, {
    required int rating,
    required String comment,
    List<String> images = const [],
    int? customerId,
  }) {
    return post('/products/$productId/reviews', {
      'customerId': _requireCustomerId(customerId),
      'rating': rating,
      'comment': comment,
      'images': images,
    });
  }

  static Future<Map<String, dynamic>> createOrder({
    int? addressId,
    String? couponCode,
    int? shippingMethodId,
    int? customerId,
  }) {
    final body = <String, dynamic>{};
    if (addressId != null) body['addressId'] = addressId;
    if (couponCode != null && couponCode.trim().isNotEmpty) {
      body['couponCode'] = couponCode.trim();
    }
    if (shippingMethodId != null) body['shippingMethodId'] = shippingMethodId;
    return post('/customers/${_requireCustomerId(customerId)}/orders', body);
  }

  static Future<List<dynamic>> orders({int? customerId}) {
    return getList('/customers/${_requireCustomerId(customerId)}/orders');
  }

  static Future<Map<String, dynamic>> reorder(int orderId, {int? customerId}) {
    return post(
      '/customers/${_requireCustomerId(customerId)}/orders/$orderId/reorder',
      {},
    );
  }

  static Future<Map<String, dynamic>> get(String path) async {
    final response = await _request('GET', path);
    return jsonDecode(response) as Map<String, dynamic>;
  }

  static Future<List<dynamic>> getList(String path) async {
    final response = await _request('GET', path);
    return jsonDecode(response) as List<dynamic>;
  }

  static Future<Map<String, dynamic>> post(
    String path,
    Map<String, dynamic> body,
  ) async {
    final response = await _request('POST', path, body: body);
    return jsonDecode(response) as Map<String, dynamic>;
  }

  static Future<Map<String, dynamic>> patch(
    String path,
    Map<String, dynamic> body,
  ) async {
    final response = await _request('PATCH', path, body: body);
    return jsonDecode(response) as Map<String, dynamic>;
  }

  static Future<String> delete(String path) {
    return _request('DELETE', path);
  }

  static Future<String> _request(
    String method,
    String path, {
    Map<String, dynamic>? body,
  }) async {
    final client = HttpClient();
    final requestStartedAt = DateTime.now();
    final action = _actionLabel(method, path);
    try {
      final uri = Uri.parse('$baseUrl$path');
      _apiLog(
        action,
        '$method $uri',
        body == null ? null : 'body=${_redact(body)}',
      );
      final request = await client.openUrl(method, uri);
      request.headers.contentType = ContentType.json;
      if (body != null) {
        request.write(jsonEncode(body));
      }
      final response = await request.close();
      final responseBody = await response.transform(utf8.decoder).join();
      final elapsedMs = DateTime.now()
          .difference(requestStartedAt)
          .inMilliseconds;
      _apiLog(
        action,
        'status=${response.statusCode} ${elapsedMs}ms',
        responseBody.isEmpty
            ? 'empty response'
            : _summarizeResponse(responseBody),
      );
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw Exception(responseBody.isEmpty ? 'Request failed' : responseBody);
      }
      return responseBody;
    } catch (error) {
      final elapsedMs = DateTime.now()
          .difference(requestStartedAt)
          .inMilliseconds;
      _apiLog(action, 'ERROR after ${elapsedMs}ms', '$error');
      rethrow;
    } finally {
      client.close();
    }
  }

  static String _actionLabel(String method, String path) {
    if (path.contains('/auth/login')) return 'LOGIN';
    if (path.contains('/auth/register')) return 'REGISTER';
    if (path.contains('/auth/google')) return 'GOOGLE_LOGIN';
    if (path.contains('/auth/facebook')) return 'FACEBOOK_LOGIN';
    if (path.contains('/auth/forgot-password')) return 'FORGOT_PASSWORD';
    if (path.contains('/cart/items') && method == 'POST') return 'ADD_CART';
    if (path.contains('/cart/items') && method == 'PATCH') return 'UPDATE_CART';
    if (path.contains('/cart/items') && method == 'DELETE') {
      return 'DELETE_CART';
    }
    if (path.contains('/favorites') && method == 'POST') return 'ADD_FAVORITE';
    if (path.contains('/favorites') && method == 'DELETE') {
      return 'REMOVE_FAVORITE';
    }
    if (path.contains('/favorites')) return 'LIST_FAVORITES';
    if (path.contains('/orders') && path.contains('/reorder')) return 'REORDER';
    if (path.contains('/orders') && method == 'POST') return 'CREATE_ORDER';
    if (path.contains('/orders')) return 'ORDERS';
    if (path.contains('/reviews') && method == 'POST') return 'ADD_REVIEW';
    if (path.contains('/reviews')) return 'REVIEWS';
    if (path.contains('/addresses') && method == 'POST') return 'ADD_ADDRESS';
    if (path.contains('/addresses') && method == 'PATCH') {
      return 'UPDATE_ADDRESS';
    }
    if (path.contains('/addresses') && method == 'DELETE') {
      return 'DELETE_ADDRESS';
    }
    if (path.contains('/addresses')) return 'ADDRESSES';
    if (path.contains('/password')) return 'CHANGE_PASSWORD';
    if (path.contains('/customers') && method == 'PATCH') {
      return 'UPDATE_PROFILE';
    }
    if (path.contains('/customers')) return 'CUSTOMER';
    if (path.contains('/products') && method == 'GET') return 'PRODUCTS';
    if (path.contains('/coupons')) return 'COUPONS';
    if (path.contains('/shipping-methods')) return 'SHIPPING';
    return 'REQUEST';
  }

  static Map<String, dynamic> _redact(Map<String, dynamic> value) {
    return value.map((key, entry) {
      final normalizedKey = key.toLowerCase();
      final shouldHide =
          normalizedKey.contains('password') ||
          normalizedKey.contains('token') ||
          normalizedKey.contains('secret');
      return MapEntry(key, shouldHide ? '***' : entry);
    });
  }

  static String _summarizeResponse(String responseBody) {
    try {
      final decoded = jsonDecode(responseBody);
      if (decoded is List) return 'items=${decoded.length}';
      if (decoded is Map<String, dynamic>) {
        final fields = <String>[];
        for (final key in [
          'id',
          'email',
          'productName',
          'orderTotal',
          'subtotal',
          'total',
          'message',
        ]) {
          if (decoded.containsKey(key)) fields.add('$key=${decoded[key]}');
        }
        if (decoded['items'] is List) {
          fields.add('items=${(decoded['items'] as List).length}');
        }
        return fields.isEmpty
            ? 'keys=${decoded.keys.join(',')}'
            : fields.join(' ');
      }
    } catch (_) {
      // Fall through to a short raw preview if the response is not JSON.
    }
    return responseBody.length <= 240
        ? responseBody
        : '${responseBody.substring(0, 240)}...';
  }

  static void _apiLog(String action, String message, [String? detail]) {
    final timestamp = DateTime.now().toIso8601String();
    final suffix = detail == null ? '' : ' | $detail';
    stdout.writeln('[$timestamp][API][$action] $message$suffix');
  }
}
