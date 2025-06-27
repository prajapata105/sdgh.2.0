// lib/Infrastructure/HttpMethods/requesting_methods.dart
import 'package:dio/dio.dart';
import 'package:ssda/Services/Exceptions/api_exception.dart';

var kdioBaseOptions = BaseOptions(
  contentType: Headers.jsonContentType, // baseUrl यहां से हटा दिया है, क्योंकि यह हर सर्विस में अलग हो सकता है
  responseType: ResponseType.json,
);

class ApiService {
  static final _dio = Dio(kdioBaseOptions);

  static Future requestMethods({
    String? methodType,
    required String url, // URL को अब non-nullable और required कर दिया है
    dynamic body,
    Map<String, String>? customHeaders, // <<<--- नया पैरामीटर जोड़ा गयाz
  }) async {
    if (url.isEmpty) throw ApiException(400, "URL is Required");

    try {
      Response response;

      // कस्टम हेडर्स को मौजूदा हेडर्स के साथ मिलाएं (यदि कोई हो)
      Options options = Options(
        headers: {"Cache-Control": "no-cache"}, // आपका मौजूदा हेडर
      );
      if (customHeaders != null) {
        options.headers?.addAll(customHeaders); // कस्टम हेडर्स जोड़ें
      }

      switch (methodType) {
        case "GET":
          response = await _dio.get(url, options: options);
          break;
        case "POST":
          response = await _dio.post(url, data: body, options: options);
          break;
        case "PUT":
          response = await _dio.put(url, data: body, options: options);
          break;
        case "DELETE":
          response = await _dio.delete(url, data: body, options: options);
          break;
        default:
          throw ApiException(400, "Invalid Method Type");
      }
      return response.data;
    } on DioException catch (e) {
      print("DioException in ApiService:");
      print("URL: ${e.requestOptions.uri}");
      print("Type: ${e.type}");
      print("Message: ${e.message}");
      if (e.response != null) {
        print("Response Status Code: ${e.response!.statusCode}");
        print("Response Data: ${e.response!.data}");
      }
      return Future.error(ApiException(
          e.response?.statusCode ?? 500, e.message ?? "Dio Error",
          stackTrace: e.stackTrace));
    } catch (e, s) {
      print("Generic error in ApiService: $e");
      print("Stack trace: $s");
      throw ApiException(500, e.toString(), stackTrace: s);
    }
  }
}