import 'dart:io';

import 'package:image/image.dart' as img;

class Utils {
  Utils._();

  /// Get extension from file name
  static String getFileExt(String fileName) {
    return RegExp('\\.(?<ext>\\w+)').allMatches(fileName)
        .map((e) => e.namedGroup('ext'))
        .lastWhere((element) => element != null && element.isNotEmpty, orElse: () => 'jpeg',)!;
  }

  /// Resize image if its width greater than [maxWidth] and then encode as [ext] extension.
  static List<int> resizeImageIfRequired(File file, String ext, int maxWidth) {
    final sourceImg = img.decodeImage(file.readAsBytesSync())!;
    img.Image resizedImgData;
    if (sourceImg.width <= maxWidth) {
      resizedImgData = sourceImg;
    } else {
      resizedImgData = img.copyResize(
        sourceImg,
        width: maxWidth,
        interpolation: img.Interpolation.nearest,
      );
    }
    return _encodeImageAsExt(ext, resizedImgData);
  }

  static List<int> _encodeImageAsExt(String ext, img.Image imgData) {
    if (ext == 'png') {
      return img.encodePng(imgData);
    } else if (ext == 'gif') {
      return img.encodeGif(imgData);
    } else if (ext == 'ico') {
      return img.encodeIco(imgData);
    } else {
      return img.encodeJpg(imgData);
    }
  }
}
