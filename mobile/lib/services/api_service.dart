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
    try {
      final uri = Uri.parse('$baseUrl$path');
      final request = await client.openUrl(method, uri);
      request.headers.contentType = ContentType.json;
      if (body != null) {
        request.write(jsonEncode(body));
      }
      final response = await request.close();
      final responseBody = await response.transform(utf8.decoder).join();
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw Exception(responseBody.isEmpty ? 'Request failed' : responseBody);
      }
      return responseBody;
    } finally {
      client.close();
    }
  }
}
