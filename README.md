A library to upload image to https://2.pik.vn.

## Usage

1. Install package 


https://pub.dev/packages/pikvn_client

Add a line like this to your package's pubspec.yaml (and run an implicit dart pub get):
```yaml
dependencies:
  pikvn_client: ^0.0.3
```
2. Usage

```dart
import 'dart:io';

import 'package:pikvn_client/pikvn_client.dart';

void main() async {
  final client = PikVnClient();
  final imageFile = File('test/data/test.jpeg');
  final uploadedUrl = await client.uploadImage(imageFile);

  print('Uploaded url: $uploadedUrl');
  //Uploaded: https://2.pik.vn/20214bfff7a7-9a44-46f8-950f-56e1577f6f56.jpg
}
```