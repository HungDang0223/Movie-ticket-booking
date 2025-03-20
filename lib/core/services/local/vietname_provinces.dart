import 'dart:convert';
import 'package:flutter/services.dart';

class VietnamProvinces {
  static List<dynamic> _data = [];

  VietnamProvinces._getContent() {
    loadData();
    
    // print(_data.);
  }

  static VietnamProvinces get ins {
    return VietnamProvinces._getContent();
  }

  // Load dữ liệu từ file JSON
  Future<void> loadData() async {
    final String response = await rootBundle.loadString('assets/data/vietnam-provinces.json');
    _data = json.decode(response);
    // print(_data[0]);
  //   print(_data.firstWhere(
  //   (p) => p['name'].toString() == 'Thành phố Hà Nội',
  //   orElse: () => {},
  // ));
    
  }

  // Lấy danh sách tỉnh/thành phố
  List<String> getProvinces() {
    return _data.map<String>((province) => province['name']).toList();
  }

  // Lấy danh sách quận/huyện trong một tỉnh/thành phố
  List<String> getDistricts(String provinceName) {
    final Map<String, dynamic>? province = _data.firstWhere(
      (p) => p['name'].toString().trim() == provinceName.trim(),
      orElse: () => null, // Correctly return null if not found
    );

    if (province != null) {
      return (province['districts'] as List<dynamic>) // Ensure it's a List
          .map<String>((d) => d['name'].toString()) // Explicitly convert to String
          .toList();
    }
    return [];
  }

  // Lấy danh sách phường/xã trong một quận/huyện
  List<String> getWards(String provinceName, String districtName) {
    final Map<String, dynamic>? province = _data.firstWhere(
      (p) => p['name'].toString().trim() == provinceName.trim(),
      orElse: () => null, // Correctly return null if not found
    );

    if (province != null) {

      final districts = province['districts'] as List<dynamic>;
      final Map<String, dynamic>? district = districts.firstWhere((d) => d['name'].toString() == districtName, orElse: () => null);

      if (district != null) {
        return (district['wards'] as List<dynamic>).map<String>((w) => w['name'].toString()).toList();
      }
    }
    return [];
  }
}