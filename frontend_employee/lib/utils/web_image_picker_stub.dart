class PickedImage {
  const PickedImage(this.name, this.bytes);

  final String name;
  final List<int> bytes;
}

Future<PickedImage?> pickImageFile() async => null;
