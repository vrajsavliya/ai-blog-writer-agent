import 'dart:html' as html;

Future<void> downloadImage(String imagePath, String filename) async {
  if (imagePath.startsWith('data:image/')) {
    html.AnchorElement(href: imagePath)
      ..setAttribute('download', filename)
      ..click();
  }
}
