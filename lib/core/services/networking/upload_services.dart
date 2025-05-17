import 'dart:io';
import 'dart:isolate';

import 'package:supabase_flutter/supabase_flutter.dart';

class UploadData {
  final File imageFile;
  final SendPort sendPort;

  UploadData(this.imageFile, this.sendPort);
}

class UploadService {
  // Hàm thực hiện upload trong isolate
  static Future<void> uploadImageInIsolate(UploadData data) async {
    try {
      final String fileName = DateTime.now().millisecondsSinceEpoch.toString();
      final path = 'uploads/$fileName';
      
      // Thực hiện upload file lên Supabase
      final response = await Supabase.instance.client.storage
          .from('user-image')
          .upload(path, data.imageFile);
      
      // Lấy URL của file vừa upload
      final imageUrl = Supabase.instance.client.storage
          .from('user-image')
          .getPublicUrl(path);
      
      // Gửi URL về main isolate
      data.sendPort.send({'success': true, 'url': imageUrl});
    } catch (e) {
      // Gửi thông báo lỗi về main isolate
      data.sendPort.send({'success': false, 'error': e.toString()});
    }
  }

  // Hàm để gọi từ UI thread
  static Future<Map<String, dynamic>> uploadImage(File imageFile) async {
    final receivePort = ReceivePort();
    
    // Tạo isolate mới để upload ảnh
    await Isolate.spawn(
      uploadImageInIsolate, 
      UploadData(imageFile, receivePort.sendPort)
    );
    
    // Đợi kết quả từ isolate
    final result = await receivePort.first as Map<String, dynamic>;
    receivePort.close();
    
    return result;
  }
}