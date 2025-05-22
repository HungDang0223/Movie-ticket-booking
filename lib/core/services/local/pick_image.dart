import 'dart:io';
import 'dart:isolate';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../networking/upload_services.dart';

class ImagePickerService {
  Future<File?> selectImage(BuildContext context) async {
    // Hiển thị dialog cho phép người dùng chọn nguồn ảnh
    final ImageSource? source = await showDialog<ImageSource>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Chọn nguồn ảnh'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                GestureDetector(
                  child: const ListTile(
                    leading: Icon(Icons.photo_library),
                    title: Text('Thư viện ảnh'),
                  ),
                  onTap: () {
                    Navigator.of(context).pop(ImageSource.gallery);
                  },
                ),
                const Divider(),
                GestureDetector(
                  child: const ListTile(
                    leading: Icon(Icons.photo_camera),
                    title: Text('Camera'),
                  ),
                  onTap: () {
                    Navigator.of(context).pop(ImageSource.camera);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );

    // Nếu người dùng đã chọn nguồn
    if (source != null) {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: source,
        imageQuality: 80, // Giảm chất lượng để tối ưu bộ nhớ
      );

      if (image != null) {
        // Sử dụng Isolate để xử lý ảnh (giảm kích thước, nén...)
        // trước khi hiển thị lên UI
        final receivePort = ReceivePort();
        await Isolate.spawn(
          _processImageInIsolate,
          UploadData(File(image.path), receivePort.sendPort)
        );

        // Đợi kết quả từ isolate
        final processedPath = await receivePort.first as String?;
        receivePort.close();
        
        if (processedPath != null) {
          return File(processedPath);
          
        }
        return null;
      }
      return null;
    }
    return null;
  }

static void _processImageInIsolate(UploadData data) async {
  try {
    final File imageFile = data.imageFile;
    
    // Xử lý ảnh ở đây nếu cần (resize, compress...)
    // Ví dụ sử dụng package flutter_image_compress:
    // final result = await FlutterImageCompress.compressWithFile(
    //   imageFile.path,
    //   quality: 70,
    // );
    // final compressedFile = File('${imageFile.path}_compressed.jpg')
    //  ..writeAsBytesSync(result!);
    
    // Vì đây chỉ là ví dụ nên ta trả về file gốc
    data.sendPort.send(imageFile.path);
  } catch (e) {
    data.sendPort.send(null);
  }
}
}