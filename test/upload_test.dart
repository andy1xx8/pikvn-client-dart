import 'dart:io';

import 'package:pikvn_client/src/client.dart';
import 'package:test/test.dart';

void main() {
  final client = PikVnClient();

  test('Upload should OK', () async {
    final imageFile = File('test/data/test.jpeg');
    final r = await client.uploadImage(imageFile);

    expect(r, isNotNull);
    print('Uploaded: ${r}');
  });
}
