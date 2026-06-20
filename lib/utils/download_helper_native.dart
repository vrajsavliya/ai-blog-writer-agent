import 'dart:io';

Future<void> downloadImage(String imagePath, String filename) async {
  // On Native, the file is already saved at imagePath.
  // In a real app we might use file_picker to let the user save it to Documents/Downloads,
  // but for now we'll just print since we don't have file_picker installed.
  print('Image is already at $imagePath');
}
