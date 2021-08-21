import 'dart:convert';
import 'dart:io';

import 'package:dio/adapter.dart';
import 'package:dio/dio.dart';
import 'package:image/image.dart' as img;

class PikVnClient {
  static const String BASE_URL = 'https://2.pik.vn';
  static const String IMG_URL = 'https://2.pik.vn';

  Dio _dio;

  PikVnClient() {
    _dio = Dio(_buildBaseOptions());
    //Trust ssl
    (_dio.httpClientAdapter as DefaultHttpClientAdapter).onHttpClientCreate =
        (HttpClient client) {
      client.badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
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
    final ext = _getFileExtension(file);
    final imageData = _resizeImageIfNeeded(file, ext, maxWidth);
    final body = {
      'image': 'data:image/$ext;base64,${base64.encode(imageData)}'
    };
    final headers = {
      'x-requested-with': 'XMLHttpRequest',
      'user-agent':
          'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_4) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/80.0.3987.163 Safari/537.36',
    };
    final options = Options(
      contentType: 'application/x-www-form-urlencoded; charset=UTF-8',
      headers: headers,
    );

    final response = await _dio.post('/', data: body, options: options);
    final Map<String, dynamic> json = jsonDecode(response.data);
    final r = json['saved'];
    if (r == null || (r is bool && !r)) {
      throw Exception('Can\'t upload at the moment.');
    }
    return '$IMG_URL/$r';
  }

  String _getFileExtension(File file) {
    return RegExp('\\.(?<ext>\\w+)')
        .allMatches(file.path)
        .map((e) => e.namedGroup('ext'))
        .lastWhere(
          (element) => element != null && element.isNotEmpty,
          orElse: () => 'jpeg',
        );
  }

  List<int> _resizeImageIfNeeded(File file, String ext, int maxWidth) {
    final sourceImg = img.decodeImage(file.readAsBytesSync());
    img.Image resizedImage;
    if (sourceImg.width <= maxWidth) {
      resizedImage = sourceImg;
    } else {
      resizedImage = img.copyResize(
        sourceImg,
        width: maxWidth,
        interpolation: img.Interpolation.nearest,
      );
    }
    if (ext == 'png') {
      return img.encodePng(resizedImage);
    } else if (ext == 'gif') {
      return img.encodeGif(resizedImage);
    } else if (ext == 'ico') {
      return img.encodeIco(resizedImage);
    } else {
      return img.encodeJpg(resizedImage);
    }
  }

  BaseOptions _buildBaseOptions() {
    bool validateStatus(int status) {
      return status >= 200 && status < 300 ||
          status == 301 ||
          status == 302 ||
          status == 303 ||
          status == 307;
    }

    return BaseOptions(
      baseUrl: BASE_URL,
      responseType: ResponseType.plain,
      connectTimeout: 30000,
      receiveTimeout: 60000,
      followRedirects: true,
      maxRedirects: 5,
      receiveDataWhenStatusError: true,
      validateStatus: validateStatus,
      headers: _buildBaseHeaders(),
    );
  }

  Map<String, String> _buildBaseHeaders() {
    return {
      HttpHeaders.contentTypeHeader:
          'application/x-www-form-urlencoded; charset=UTF-8',
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
    };
  }
}
