import 'dart:async';
// ignore: avoid_web_libraries_in_flutter, deprecated_member_use
import 'dart:html' as html;
import 'dart:typed_data';

class PickedImage {
  const PickedImage(this.name, this.bytes);

  final String name;
  final List<int> bytes;
}

Future<PickedImage?> pickImageFile() async {
  final input = html.FileUploadInputElement()
    ..accept = 'image/*'
    ..multiple = false;
  final completer = Completer<PickedImage?>();
  input.onChange.listen((_) {
    final file = input.files?.isEmpty == false ? input.files!.first : null;
    if (file == null) {
      completer.complete(null);
      return;
    }
    final reader = html.FileReader();
    reader.onLoadEnd.listen((_) {
      final result = reader.result;
      if (result is ByteBuffer) {
        completer.complete(PickedImage(file.name, result.asUint8List()));
      } else {
        completer.complete(null);
      }
    });
    reader.readAsArrayBuffer(file);
  });
  input.click();
  return completer.future;
}
