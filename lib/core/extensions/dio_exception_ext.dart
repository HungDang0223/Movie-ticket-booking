import 'package:dio/dio.dart';

extension DioExceptionExt on DioExceptionType {
  String toPrettyDescription() {
    switch (this) {
      case DioExceptionType.connectionTimeout:
        return 'Quá thời gian kết nối';
      case DioExceptionType.sendTimeout:
        return 'Quá thời gian gửi';
      case DioExceptionType.receiveTimeout:
        return 'Quá thời gian nhận';
      case DioExceptionType.badCertificate:
        return 'incorrect certificate as configured';
      case DioExceptionType.badResponse:
        return 'bad response';
      case DioExceptionType.cancel:
        return 'Yêu cầu bị hủy';
      case DioExceptionType.connectionError:
        return 'Lỗi kết nối với server';
      case DioExceptionType.unknown:
        return 'Lỗi không mong muốn';
    }
  }
}