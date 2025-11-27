import 'dart:convert';
import 'dart:io';

import 'package:aplikasi_cbt/app/controllers/general_controller.dart';
import 'package:aplikasi_cbt/app/utils/app_material.dart';
import 'package:http/http.dart' as http;

enum RequestType { get, post, put, delete }

class HttpService {
  static String getErrorMessageFromException(String error) {
    final lowerError = error.toLowerCase();
    if (lowerError.contains('connection') ||
        lowerError.contains('failed host lookup') ||
        lowerError.contains('network is unreachable') ||
        lowerError.contains('remote computer refused the network connection') ||
        lowerError.contains('socketexception')) {
      return "Ada masalah dengan koneksi, coba lagi nanti!";
    } else if (lowerError.contains('timeout') ||
        lowerError.contains('semaphore timeout')) {
      return "Waktu koneksi habis. Silahkan coba lagi!";
    } else if (lowerError.contains('unauthorized') ||
        lowerError.contains('401')) {
      return "Anda tidak memiliki akses. Silahkan login!";
    } else if (lowerError.contains('not found') || lowerError.contains('404')) {
      return "Data tidak ditemukan!";
    } else if (lowerError.contains('server error') ||
        lowerError.contains('500')) {
      return "Terjadi kesalahan pada server. Silahkan coba lagi nanti!";
    }
    return "Terjadi kesalahan: $error";
  }

  static String getErrorMessage(int statusCode) {
    switch (statusCode) {
      case 400:
        return "Permintaan tidak valid. Periksa input Anda!";
      case 401:
        return "Anda tidak memiliki akses. Silahkan login!";
      case 403:
        return "Anda tidak diizinkan untuk mengakses halaman ini!";
      case 404:
        return "Data tidak ditemukan!";
      case 408:
        return "Waktu habis. Silahkan coba lagi!";
      case 422:
        return "Data tidak valid. Periksa input Anda!";
      case 500:
        return "Terjadi kesalahan pada server. Silahkan coba lagi nanti!";
      case 502:
        return "Server sedang tidak dapat diakses. Coba lagi nanti!";
      case 503:
        return "Layanan sedang tidak tersedia. Silahkan coba beberapa saat lagi!";
      case 504:
        return "Server tidak merespons tepat waktu. Silahkan coba lagi!";
      default:
        return "Terjadi kesalahan tidak diketahui!";
    }
  }

  static Future<dynamic> request({
    required String url,
    RequestType type = RequestType.get,
    Map<String, dynamic>? body,
    Map<String, String>? extraHeaders,
    bool isLogin = false,
    bool isFormData = false,
    void Function(int statusCode)? onStatus,
    void Function(dynamic error)? onError,
    void Function(dynamic error)? onStuck,
  }) async {
    String? authToken = (isLogin
        ? null
        : AllMaterial.box.read("token") ?? AllMaterial.token.value);

    Future<http.Response> makeRequest(String? usedToken) {
      Map<String, String> headers = isLogin
          ? {
              'Content-Type':
                  isFormData ? 'multipart/form-data' : 'application/json',
            }
          : {
              if (usedToken != null) 'Authorization': 'Bearer $usedToken',
              'Content-Type':
                  isFormData ? 'multipart/form-data' : 'application/json',
              ...?extraHeaders,
            };

      Uri uri = Uri.parse(url);

      switch (type) {
        case RequestType.get:
          return http.get(uri, headers: headers);
        case RequestType.post:
          return http.post(uri,
              headers: headers, body: isFormData ? body : jsonEncode(body));
        case RequestType.put:
          return http.put(uri,
              headers: headers, body: isFormData ? body : jsonEncode(body));
        case RequestType.delete:
          return http.delete(uri,
              headers: headers, body: isFormData ? body : jsonEncode(body));
      }
    }

    try {
      http.Response response = await makeRequest(authToken);

      onStatus?.call(response.statusCode);

      if (response.statusCode == 401) {
        await GeneralController.logout(autoLogout: true);
      }

      if (response.body.isEmpty) {
        print(
            "http service (${response.statusCode}) - $type ($url): <empty body>");

        return null;
      }

      dynamic decoded;
      try {
        decoded = jsonDecode(response.body);
      } catch (e) {
        print("Gagal decode JSON: $e");
        if (onError != null) onError("Respons tidak valid dari server");
        return null;
      }

      print("http service (${response.statusCode}) - $type ($url): $decoded");

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return decoded;
      } else if (response.statusCode == 422 && decoded is Map) {
        if (decoded.containsKey('detail') && decoded['detail'] is List) {
          final detailList = decoded['detail'] as List;
          final extracted = <String, String>{};
          for (final item in detailList) {
            if (item is Map &&
                item.containsKey('loc') &&
                item.containsKey('msg')) {
              final loc = item['loc'];
              final msg = item['msg'];
              if (loc is List && loc.length >= 2) {
                final field = loc.last.toString();
                extracted[field] = msg.toString();
              }
            }
          }
          onStuck?.call(extracted);
        } else {
          onStuck?.call(decoded);
        }

        return decoded;
      } else {
        onStuck?.call(decoded);

        return decoded;
      }
    } catch (e) {
      print(e);
      final errorStr = e.toString();
      final friendlyMessage = getErrorMessageFromException(errorStr);

      if (onError != null) {
        onError(friendlyMessage);
      }

      return null;
    }
  }

  static Future<dynamic> requestMultipart({
    required String url,
    RequestType type = RequestType.post,
    required Map<String, String> fields,
    Map<String, File>? files,
    Map<String, String>? extraHeaders,
    bool isLogin = false,
    bool showLoading = true,
    String loadingMessage = 'Memuat...',
    String successMessage = 'Berhasil!',
    String errorMessage = 'Gagal!',
    void Function(int statusCode)? onStatus,
    void Function(dynamic error)? onError,
  }) async {
    String? authToken = (isLogin
        ? null
        : AllMaterial.box.read("token") ?? AllMaterial.token.value);

    Uri uri = Uri.parse(url);
    var request = http.MultipartRequest(
      type == RequestType.put ? 'PUT' : 'POST',
      uri,
    );

    if (authToken != null) {
      request.headers['Authorization'] = 'Bearer $authToken';
    }
    if (extraHeaders != null) {
      extraHeaders
          .removeWhere((key, value) => key.toLowerCase() == 'content-type');
      request.headers.addAll(extraHeaders);
    }

    request.fields.addAll(fields);

    if (files != null && files.isNotEmpty) {
      for (final entry in files.entries) {
        final file = entry.value;
        if (await file.exists()) {
          final fileName = file.path.split('/').last;
          print('Uploading file [${entry.key}] → $fileName (${file.path})');

          request.files.add(
            await http.MultipartFile.fromPath(
              entry.key,
              file.path,
              filename: fileName,
            ),
          );
        } else {
          print('⚠️ File not found: ${file.path}');
        }
      }
    }

    try {
      final streamedResponse =
          await request.send().timeout(const Duration(seconds: 30));
      final response = await http.Response.fromStream(streamedResponse);

      onStatus?.call(response.statusCode);

      dynamic decoded;
      try {
        decoded = jsonDecode(response.body);
      } catch (_) {
        decoded = {"raw": response.body};
      }

      print(
          "http service multipart: (${response.statusCode}) - $type ($url): $decoded");

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return decoded;
      } else {
        return decoded;
      }
    } catch (e) {
      print("multipart error: $e");
      final errorStr = e.toString();
      final friendlyMessage = getErrorMessageFromException(errorStr);

      if (onError != null) {
        onError(friendlyMessage);
      }
      return null;
    }
  }
}
