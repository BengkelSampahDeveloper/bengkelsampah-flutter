import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:universal_platform/universal_platform.dart';
import '../constants/api_constants.dart';
import 'package:http_parser/http_parser.dart' as http_parser;

class ApiService {
  final String baseUrl = ApiConstants.baseUrl;
  final storage = const FlutterSecureStorage();

  Future<String?> get _token async {
    return await storage.read(key: 'token');
  }

  Future<Map<String, String>> get _headers async {
    final token = await _token;
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  Future<Map<String, dynamic>> _handleResponse(http.Response response) async {
    try {
      final data = jsonDecode(response.body);
      if (data['success'] == true && data['data']?['token'] != null) {
        await storage.write(key: 'token', value: data['data']['token']);
      }
      return data;
    } catch (e) {
      return {
        'success': false,
        'message': e.toString(),
        'timestamp': DateTime.now().toIso8601String(),
      };
    }
  }

  // Platform-specific HTTP methods
  Future<http.Response> _get(String url) async {
    if (UniversalPlatform.isWeb) {
      // Use http package for web
      final headers = await _headers;
      return await http.get(Uri.parse(url), headers: headers);
    } else {
      // Use custom HttpClient for mobile platforms
      return await _customGet(url);
    }
  }

  Future<http.Response> _post(String url, {Map<String, dynamic>? body}) async {
    if (UniversalPlatform.isWeb) {
      // Use http package for web
      final headers = await _headers;
      return await http.post(
        Uri.parse(url),
        headers: headers,
        body: body != null ? jsonEncode(body) : null,
      );
    } else {
      // Use custom HttpClient for mobile platforms
      return await _customPost(url, body: body);
    }
  }

  Future<http.Response> _put(String url, {Map<String, dynamic>? body}) async {
    if (UniversalPlatform.isWeb) {
      // Use http package for web
      final headers = await _headers;
      return await http.put(
        Uri.parse(url),
        headers: headers,
        body: body != null ? jsonEncode(body) : null,
      );
    } else {
      // Use custom HttpClient for mobile platforms
      return await _customPut(url, body: body);
    }
  }

  Future<http.Response> _delete(String url) async {
    if (UniversalPlatform.isWeb) {
      // Use http package for web
      final headers = await _headers;
      return await http.delete(Uri.parse(url), headers: headers);
    } else {
      // Use custom HttpClient for mobile platforms
      return await _customDelete(url);
    }
  }

  // Helper methods for custom HttpClient requests (mobile only)
  Future<http.Response> _customGet(String url) async {
    final client = await createHttpClientWithCustomCert();
    final request = await client.getUrl(Uri.parse(url));
    final headers = await _headers;
    headers.forEach((key, value) {
      request.headers.set(key, value);
    });
    final response = await request.close();
    final responseBody = await response.transform(utf8.decoder).join();
    return http.Response(responseBody, response.statusCode);
  }

  Future<http.Response> _customPost(String url,
      {Map<String, dynamic>? body}) async {
    final client = await createHttpClientWithCustomCert();
    final request = await client.postUrl(Uri.parse(url));
    final headers = await _headers;
    headers.forEach((key, value) {
      request.headers.set(key, value);
    });
    if (body != null) {
      request.add(utf8.encode(jsonEncode(body)));
    }
    final response = await request.close();
    final responseBody = await response.transform(utf8.decoder).join();
    return http.Response(responseBody, response.statusCode);
  }

  Future<http.Response> _customPut(String url,
      {Map<String, dynamic>? body}) async {
    final client = await createHttpClientWithCustomCert();
    final request = await client.putUrl(Uri.parse(url));
    final headers = await _headers;
    headers.forEach((key, value) {
      request.headers.set(key, value);
    });
    if (body != null) {
      request.add(utf8.encode(jsonEncode(body)));
    }
    final response = await request.close();
    final responseBody = await response.transform(utf8.decoder).join();
    return http.Response(responseBody, response.statusCode);
  }

  Future<http.Response> _customDelete(String url) async {
    final client = await createHttpClientWithCustomCert();
    final request = await client.deleteUrl(Uri.parse(url));
    final headers = await _headers;
    headers.forEach((key, value) {
      request.headers.set(key, value);
    });
    final response = await request.close();
    final responseBody = await response.transform(utf8.decoder).join();
    return http.Response(responseBody, response.statusCode);
  }

  Future<Map<String, dynamic>> sendOtp(String identifier, String type) async {
    try {
      final response = await _post('$baseUrl${ApiConstants.sendOtp}', body: {
        'identifier': identifier,
        'type': type,
      });
      return _handleResponse(response);
    } catch (e) {
      return {
        'success': false,
        'message': 'Terjadi kesalahan saat mengirim OTP',
        'timestamp': DateTime.now().toIso8601String(),
      };
    }
  }

  Future<Map<String, dynamic>> register({
    required String fullname,
    required String identifier,
    required String password,
    required String confirmPassword,
    required String otp,
  }) async {
    try {
      final response = await _post('$baseUrl${ApiConstants.register}', body: {
        'fullname': fullname,
        'identifier': identifier,
        'password': password,
        'confirm_password': confirmPassword,
        'otp': otp,
      });
      return _handleResponse(response);
    } catch (e) {
      return {
        'success': false,
        'message': 'Terjadi kesalahan saat registrasi',
        'timestamp': DateTime.now().toIso8601String(),
      };
    }
  }

  Future<Map<String, dynamic>> login(
    String identifier,
    String password,
    String otp,
  ) async {
    try {
      final response = await _post('$baseUrl${ApiConstants.login}', body: {
        'identifier': identifier,
        'password': password,
        'otp': otp,
      });
      return _handleResponse(response);
    } catch (e) {
      return {
        'success': false,
        'message': 'Terjadi kesalahan saat login',
        'timestamp': DateTime.now().toIso8601String(),
      };
    }
  }

  Future<Map<String, dynamic>> logout() async {
    try {
      final response = await _post('$baseUrl${ApiConstants.logout}');
      final data = await _handleResponse(response);
      if (data['success'] == true) {
        await storage.delete(key: 'token');
      }
      return data;
    } catch (e) {
      return {
        'success': false,
        'message': 'Terjadi kesalahan saat logout',
        'timestamp': DateTime.now().toIso8601String(),
      };
    }
  }

  Future<bool> isLoggedIn() async {
    final token = await storage.read(key: 'token');
    return token != null;
  }

  Future<Map<String, dynamic>> forgotPassword({
    required String identifier,
    required String otp,
    required String newPassword,
    required String newPasswordConfirmation,
  }) async {
    try {
      final response =
          await _post('$baseUrl${ApiConstants.forgotPassword}', body: {
        'identifier': identifier,
        'otp': otp,
        'new_password': newPassword,
        'new_password_confirmation': newPasswordConfirmation,
      });
      return _handleResponse(response);
    } catch (e) {
      return {
        'success': false,
        'message': 'Terjadi kesalahan saat mengubah password',
        'timestamp': DateTime.now().toIso8601String(),
      };
    }
  }

  Future<Map<String, dynamic>> getArticles({int page = 1}) async {
    try {
      final response =
          await _get('$baseUrl${ApiConstants.articles}?page=$page');
      return _handleResponse(response);
    } catch (e) {
      return {
        'success': false,
        'message': 'Terjadi kesalahan saat mengambil artikel',
        'timestamp': DateTime.now().toIso8601String(),
      };
    }
  }

  Future<Map<String, dynamic>> getArticleDetail(int id) async {
    try {
      final response = await _get('$baseUrl${ApiConstants.articles}/$id');
      return _handleResponse(response);
    } catch (e) {
      return {
        'success': false,
        'message': 'Terjadi kesalahan saat mengambil detail artikel',
        'timestamp': DateTime.now().toIso8601String(),
      };
    }
  }

  Future<Map<String, dynamic>> getHomeData() async {
    try {
      final response = await _get('$baseUrl${ApiConstants.home}');
      return _handleResponse(response);
    } catch (e) {
      return {
        'success': false,
        'message': 'Terjadi kesalahan saat mengambil data home',
        'timestamp': DateTime.now().toIso8601String(),
      };
    }
  }

  Future<Map<String, dynamic>> getProfileData() async {
    try {
      final response = await _get('$baseUrl${ApiConstants.profile}');
      return _handleResponse(response);
    } catch (e) {
      return {
        'success': false,
        'message': 'Terjadi kesalahan saat mengambil data profil',
        'timestamp': DateTime.now().toIso8601String(),
      };
    }
  }

  Future<Map<String, dynamic>> getPointsData({int page = 1}) async {
    try {
      final response = await _get('$baseUrl${ApiConstants.points}?page=$page');
      return _handleResponse(response);
    } catch (e) {
      return {
        'success': false,
        'message': 'Terjadi kesalahan saat mengambil data poin',
        'timestamp': DateTime.now().toIso8601String(),
      };
    }
  }

  Future<Map<String, dynamic>> getDetailProfile() async {
    try {
      final response = await _get('$baseUrl${ApiConstants.detailProfile}');
      return _handleResponse(response);
    } catch (e) {
      return {
        'success': false,
        'message': 'Terjadi kesalahan saat mengambil detail profil',
        'timestamp': DateTime.now().toIso8601String(),
      };
    }
  }

  Future<Map<String, dynamic>> getAddresses() async {
    try {
      final response = await _get('$baseUrl${ApiConstants.addresses}');
      return _handleResponse(response);
    } catch (e) {
      return {
        'success': false,
        'message': 'Terjadi kesalahan saat mengambil alamat',
        'timestamp': DateTime.now().toIso8601String(),
      };
    }
  }

  Future<Map<String, dynamic>> addAddress({
    required String nama,
    required String nomorHandphone,
    required String labelAlamat,
    required String provinsi,
    required String kotaKabupaten,
    required String kecamatan,
    required String kodePos,
    required String detailLain,
    required bool isDefault,
  }) async {
    try {
      final response = await _post('$baseUrl${ApiConstants.addresses}', body: {
        'nama': nama,
        'nomor_handphone': nomorHandphone,
        'label_alamat': labelAlamat,
        'provinsi': provinsi,
        'kota_kabupaten': kotaKabupaten,
        'kecamatan': kecamatan,
        'kode_pos': kodePos,
        'detail_lain': detailLain,
        'is_default': isDefault,
      });
      return _handleResponse(response);
    } catch (e) {
      return {
        'status': 'error',
        'message': 'Terjadi kesalahan saat menambahkan alamat',
        'timestamp': DateTime.now().toIso8601String(),
      };
    }
  }

  Future<Map<String, dynamic>> updateAddress({
    required int id,
    required String nama,
    required String nomorHandphone,
    required String labelAlamat,
    required String provinsi,
    required String kotaKabupaten,
    required String kecamatan,
    required String kodePos,
    required String detailLain,
    required bool isDefault,
  }) async {
    try {
      final response =
          await _put('$baseUrl${ApiConstants.addresses}/$id', body: {
        'nama': nama,
        'nomor_handphone': nomorHandphone,
        'label_alamat': labelAlamat,
        'provinsi': provinsi,
        'kota_kabupaten': kotaKabupaten,
        'kecamatan': kecamatan,
        'kode_pos': kodePos,
        'detail_lain': detailLain,
        'is_default': isDefault,
      });
      return _handleResponse(response);
    } catch (e) {
      return {
        'status': 'error',
        'message': 'Terjadi kesalahan saat mengupdate alamat',
        'timestamp': DateTime.now().toIso8601String(),
      };
    }
  }

  Future<Map<String, dynamic>> deleteAddress(int id) async {
    try {
      final response = await _delete('$baseUrl${ApiConstants.addresses}/$id');
      return _handleResponse(response);
    } catch (e) {
      return {
        'status': 'error',
        'message': 'Terjadi kesalahan saat menghapus alamat',
        'timestamp': DateTime.now().toIso8601String(),
      };
    }
  }

  Future<Map<String, dynamic>> updateProfile(
      {required Map<String, dynamic> body}) async {
    try {
      final response =
          await _put('$baseUrl${ApiConstants.editProfile}', body: body);
      return _handleResponse(response);
    } catch (e) {
      return {
        'status': 'error',
        'message': 'Terjadi kesalahan saat mengupdate profil',
        'timestamp': DateTime.now().toIso8601String(),
      };
    }
  }

  Future<Map<String, dynamic>> deleteAccount() async {
    try {
      final response = await _post('$baseUrl/delete-account');
      return _handleResponse(response);
    } catch (e) {
      return {
        'success': false,
        'message': 'Terjadi kesalahan saat menghapus akun',
        'timestamp': DateTime.now().toIso8601String(),
      };
    }
  }

  Future<Map<String, dynamic>> getEvents({int page = 1}) async {
    try {
      final response = await _get('$baseUrl${ApiConstants.events}?page=$page');
      return _handleResponse(response);
    } catch (e) {
      return {
        'status': 'error',
        'message': 'Terjadi kesalahan saat mengambil event',
        'timestamp': DateTime.now().toIso8601String(),
      };
    }
  }

  Future<Map<String, dynamic>> getEventDetail(int id) async {
    try {
      final response = await _get('$baseUrl${ApiConstants.events}/$id');
      return _handleResponse(response);
    } catch (e) {
      return {
        'status': 'error',
        'message': 'Terjadi kesalahan saat mengambil detail event',
        'timestamp': DateTime.now().toIso8601String(),
      };
    }
  }

  Future<Map<String, dynamic>> toggleJoinEvent(int id) async {
    try {
      final response =
          await _post('$baseUrl${ApiConstants.events}/$id/toggle-join');
      return _handleResponse(response);
    } catch (e) {
      return {
        'status': 'error',
        'message': 'Terjadi kesalahan saat bergabung/meninggalkan event',
        'timestamp': DateTime.now().toIso8601String(),
      };
    }
  }

  Future<Map<String, dynamic>> getBankSampah() async {
    try {
      final response = await _get('$baseUrl${ApiConstants.bankSampah}');
      return _handleResponse(response);
    } catch (e) {
      return {
        'status': 'error',
        'message': 'Terjadi kesalahan saat mengambil data bank sampah',
        'timestamp': DateTime.now().toIso8601String(),
      };
    }
  }

  Future<Map<String, dynamic>> getKatalog(
      {int? category, String? search}) async {
    try {
      final queryParams = <String, String>{};
      if (category != null) {
        queryParams['category'] = category.toString();
      }
      if (search != null && search.isNotEmpty) {
        queryParams['search'] = search;
      }
      final uri = Uri.parse('$baseUrl${ApiConstants.katalog}')
          .replace(queryParameters: queryParams);
      final response = await _get(uri.toString());
      return _handleResponse(response);
    } catch (e) {
      return {
        'status': 'error',
        'message': 'Terjadi kesalahan saat mengambil data katalog',
        'timestamp': DateTime.now().toIso8601String(),
      };
    }
  }

  Future<Map<String, dynamic>> getKatalogDetail(int id) async {
    try {
      final response = await _get('$baseUrl${ApiConstants.katalog}/$id');
      return _handleResponse(response);
    } catch (e) {
      return {
        'status': 'error',
        'message': 'Terjadi kesalahan saat mengambil detail katalog',
        'timestamp': DateTime.now().toIso8601String(),
      };
    }
  }

  Future<Map<String, dynamic>> checkPilahkuItems(
      List<Map<String, dynamic>> items) async {
    try {
      final response =
          await _post('$baseUrl${ApiConstants.pilahkuCheck}', body: {
        'items': items,
      });
      return _handleResponse(response);
    } catch (e) {
      return {
        'success': false,
        'message': 'Terjadi kesalahan saat pengecekan pilahku',
        'timestamp': DateTime.now().toIso8601String(),
      };
    }
  }

  Future<Map<String, dynamic>> createSetoran({
    required int bankSampahId,
    required int addressId,
    required String tipeSetor,
    required List<Map<String, dynamic>> items,
    required double estimasiTotal,
    DateTime? tanggalPenjemputan,
    String? waktuPenjemputan,
    Object? fotoSampah,
    required String tipeLayanan,
  }) async {
    try {
      if (UniversalPlatform.isWeb) {
        // WEB: gunakan http.MultipartRequest
        final token = await _token;
        final uri = Uri.parse('$baseUrl${ApiConstants.setorans}');
        final request = http.MultipartRequest('POST', uri);
        if (token != null) {
          request.headers['Authorization'] = 'Bearer $token';
        }
        request.headers['Accept'] = 'application/json';
        request.fields['bank_sampah_id'] = bankSampahId.toString();
        request.fields['address_id'] = addressId.toString();
        request.fields['tipe_setor'] = tipeSetor;
        request.fields['estimasi_total'] = estimasiTotal.toString();
        request.fields['tipe_layanan'] = tipeLayanan;
        if (tanggalPenjemputan != null) {
          request.fields['tanggal_penjemputan'] =
              tanggalPenjemputan.toIso8601String().split('T')[0];
        }
        if (waktuPenjemputan != null) {
          request.fields['waktu_penjemputan'] = waktuPenjemputan;
        }
        request.fields['items'] = jsonEncode(items);
        if (fotoSampah != null && fotoSampah is Uint8List) {
          request.files.add(
            http.MultipartFile.fromBytes(
              'foto_sampah',
              fotoSampah,
              filename: 'foto_sampah.jpg',
              contentType: http_parser.MediaType('image', 'jpeg'),
            ),
          );
        }
        final streamedResponse = await request.send();
        final responseBody = await streamedResponse.stream.bytesToString();
        final httpResponse =
            http.Response(responseBody, streamedResponse.statusCode);
        return _handleResponse(httpResponse);
      } else {
        // NON-WEB: kode lama
        final token = await _token;
        final client = await createHttpClientWithCustomCert();
        final url = Uri.parse('$baseUrl${ApiConstants.setorans}');
        final request = await client.postUrl(url);
        final boundary =
            '----dart-http-boundary-${DateTime.now().millisecondsSinceEpoch}';
        request.headers
            .set('Content-Type', 'multipart/form-data; boundary=$boundary');
        if (token != null) {
          request.headers.set('Authorization', 'Bearer $token');
        }
        request.headers.set('Accept', 'application/json');

        final body = BytesBuilder();
        void writeString(String s) => body.add(utf8.encode(s));

        // Helper to add field
        void addField(String name, String value) {
          writeString('--$boundary\r\n');
          writeString('Content-Disposition: form-data; name="$name"\r\n\r\n');
          writeString('$value\r\n');
        }

        addField('bank_sampah_id', bankSampahId.toString());
        addField('address_id', addressId.toString());
        addField('tipe_setor', tipeSetor);
        addField('estimasi_total', estimasiTotal.toString());
        addField('tipe_layanan', tipeLayanan);
        if (tanggalPenjemputan != null) {
          addField('tanggal_penjemputan',
              tanggalPenjemputan.toIso8601String().split('T')[0]);
        }
        if (waktuPenjemputan != null) {
          addField('waktu_penjemputan', waktuPenjemputan);
        }
        addField('items', jsonEncode(items));

        // Add file as binary
        if (fotoSampah != null) {
          writeString('--$boundary\r\n');
          writeString(
              'Content-Disposition: form-data; name="foto_sampah"; filename="foto_sampah.jpg"\r\n');
          writeString('Content-Type: image/jpeg\r\n\r\n');
          if (fotoSampah is File) {
            body.add(await fotoSampah.readAsBytes());
          } else if (fotoSampah is Uint8List) {
            body.add(fotoSampah);
          }
          writeString('\r\n');
        }

        writeString('--$boundary--\r\n');

        request.add(body.toBytes());
        final response = await request.close();
        final responseBody = await response.transform(utf8.decoder).join();
        final httpResponse = http.Response(responseBody, response.statusCode);
        return _handleResponse(httpResponse);
      }
    } catch (e) {
      return {
        'status': 'error',
        'message': 'Terjadi kesalahan saat membuat setoran: ${e.toString()}',
        'timestamp': DateTime.now().toIso8601String(),
      };
    }
  }

  Future<Map<String, dynamic>> getSetorans({
    String? status,
    String? tipeSetor,
    int page = 1,
  }) async {
    try {
      final queryParams = <String, String>{
        'page': page.toString(),
      };
      if (status != null) {
        queryParams['status'] = status;
      }
      if (tipeSetor != null) {
        queryParams['tipe_setor'] = tipeSetor;
      }

      final uri = Uri.parse('$baseUrl${ApiConstants.setorans}')
          .replace(queryParameters: queryParams);
      final response = await _get(uri.toString());
      return _handleResponse(response);
    } catch (e) {
      return {
        'status': 'error',
        'message': 'Terjadi kesalahan saat mengambil data setoran',
        'timestamp': DateTime.now().toIso8601String(),
      };
    }
  }

  Future<Map<String, dynamic>> getSetoranDetail(int id) async {
    try {
      final response = await _get('$baseUrl${ApiConstants.setorans}/$id');
      return _handleResponse(response);
    } catch (e) {
      return {
        'status': 'error',
        'message': 'Terjadi kesalahan saat mengambil detail setoran',
        'timestamp': DateTime.now().toIso8601String(),
      };
    }
  }

  Future<Map<String, dynamic>> cancelSetoran(
      int id, String alasanPembatalan) async {
    try {
      final response = await _post(
        '$baseUrl${ApiConstants.setorans}/$id/cancel',
        body: {
          'alasan_pembatalan': alasanPembatalan,
        },
      );
      return _handleResponse(response);
    } catch (e) {
      return {
        'status': 'error',
        'message':
            'Terjadi kesalahan saat membatalkan setoran: ${e.toString()}',
        'timestamp': DateTime.now().toIso8601String(),
      };
    }
  }

  Future<HttpClient> createHttpClientWithCustomCert() async {
    final context = SecurityContext(withTrustedRoots: true);
    final certBytes =
        await rootBundle.load('assets/certificates/lets_encrypt_r11.pem');
    context.setTrustedCertificatesBytes(certBytes.buffer.asUint8List());
    return HttpClient(context: context);
  }

  Future<void> updateFCMToken(String token) async {
    try {
      final response = await _post('$baseUrl/fcm-token', body: {
        'fcm_token': token,
      });
      // Optionally handle response
    } catch (e) {
      // Optionally handle error
    }
  }

  // Notification API methods
  Future<Map<String, dynamic>> getNotifications(
      {int limit = 20, int offset = 0}) async {
    try {
      final response =
          await _get('$baseUrl/notifications?limit=$limit&offset=$offset');
      return _handleResponse(response);
    } catch (e) {
      return {
        'success': false,
        'message': 'Terjadi kesalahan saat mengambil notifikasi',
        'timestamp': DateTime.now().toIso8601String(),
      };
    }
  }

  Future<Map<String, dynamic>> markNotificationAsRead(
      int notificationId) async {
    try {
      final response =
          await _post('$baseUrl/notifications/mark-as-read', body: {
        'notification_id': notificationId,
      });
      return _handleResponse(response);
    } catch (e) {
      return {
        'success': false,
        'message': 'Terjadi kesalahan saat menandai notifikasi',
        'timestamp': DateTime.now().toIso8601String(),
      };
    }
  }

  Future<Map<String, dynamic>> markAllNotificationsAsRead() async {
    try {
      final response = await _post('$baseUrl/notifications/mark-all-as-read');
      return _handleResponse(response);
    } catch (e) {
      return {
        'success': false,
        'message': 'Terjadi kesalahan saat menandai semua notifikasi',
        'timestamp': DateTime.now().toIso8601String(),
      };
    }
  }

  Future<Map<String, dynamic>> deleteNotification(int notificationId) async {
    try {
      final response = await _delete(
          '$baseUrl/notifications?notification_id=$notificationId');
      return _handleResponse(response);
    } catch (e) {
      return {
        'success': false,
        'message': 'Terjadi kesalahan saat menghapus notifikasi',
        'timestamp': DateTime.now().toIso8601String(),
      };
    }
  }
}
