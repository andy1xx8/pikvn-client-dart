import 'dart:io';

import 'package:pikvn_client/pikvn_client.dart';

void main() async {
  final client = PikVnClient();
  final imageFile = File('test/data/test.jpeg');
  final uploadedUrl = await client.uploadImage(imageFile);

  print('Uploaded url: $uploadedUrl');
  //Uploaded: https://2.pik.vn/20214bfff7a7-9a44-46f8-950f-56e1577f6f56.jpg
}
