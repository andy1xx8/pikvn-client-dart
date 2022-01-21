import 'dart:convert';
import 'dart:io';

import 'package:dio/adapter.dart';
import 'package:dio/dio.dart';
import 'package:pikvn_client/src/utils.dart';
import 'package:brotli/brotli.dart';

class PikVnClient {
  /// Base url of PIK server
  static const String BASE_URL = 'https://2.pik.vn';

  late Dio _dio;

  PikVnClient() {
    _dio = Dio(_buildBaseOptions(PikVnClient.BASE_URL));
    //Trust ssl
    (_dio.httpClientAdapter as DefaultHttpClientAdapter).onHttpClientCreate = (HttpClient client) {
      client.badCertificateCallback = (X509Certificate cert, String host, int port) => true;
      return client;
    };
  }

  /// Upload a local file to Pik (`https://2.pik.vn`) server and return a url to the uploaded file.
  ///
  /// [file] - File to be uploaded
  ///
  /// [maxWidth]
  ///   - Your image's width will be resized to this value (if needed)
  ///   - It's because Pik server require your image width must less than  or equal 1200 px
  Future<String> uploadImage(File file, {int maxWidth = 1200}) async {
    final ext = Utils.getFileExt(file.path);
    final imageData = Utils.resizeImageIfRequired(file, ext, maxWidth);
    final body = {'image': 'data:image/$ext;base64,${base64.encode(imageData)}'};
    final headers = {
      'Accept-Encoding': 'gzip, deflate',
      'x-requested-with': 'XMLHttpRequest',
      'user-agent':
          'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_4) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/80.0.3987.163 Safari/537.36',
    };
    final options = Options(
      contentType: 'application/x-www-form-urlencoded; charset=UTF-8',
      headers: headers,
    );

    final response = await _dio.post('/', data: body, options: options);

    final Map<String, dynamic> json = _readResponseAsJson(response);
    final savedUrl = json['saved'];
    if (savedUrl == null || (savedUrl is bool && !savedUrl)) {
      throw Exception('Can\'t upload at the moment.');
    }
    return '$BASE_URL/$savedUrl';
  }

  Map<String, dynamic> _readResponseAsJson(Response response) {
    final encoding = response.headers.value('content-encoding');
    return jsonDecode(response.data);
  }


  BaseOptions _buildBaseOptions(String baseUrl) {
    return BaseOptions(
      baseUrl: baseUrl,
      responseType: ResponseType.plain,
      connectTimeout: 30000,
      receiveTimeout: 60000,
      followRedirects: true,
      maxRedirects: 5,
      receiveDataWhenStatusError: true,
      validateStatus: _validateStatus,
      headers: {
        HttpHeaders.contentTypeHeader: 'application/x-www-form-urlencoded; charset=UTF-8',
        HttpHeaders.userAgentHeader:
            'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_14_6) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/79.0.3945.130 Safari/537.36',
        HttpHeaders.acceptHeader:
            'text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.9',
        HttpHeaders.acceptLanguageHeader: 'en,vi;q=0.9',
        HttpHeaders.acceptEncodingHeader: 'gzip, deflate, br',
        'sec-fetch-mode': 'nagigate',
        'sec-fetch-site': 'same-origin',
        'sec-fetch-user': '?1',
        'upgrade-insecure-requests': '1',
      },
    );
  }

  bool _validateStatus(int? status) {
    if (status != null) {
      return status >= 200 && status < 300 || status == 301 || status == 302 || status == 303 || status == 307;
    } else {
      return false;
    }
  }
}