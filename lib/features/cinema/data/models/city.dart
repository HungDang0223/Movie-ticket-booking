import 'dart:ffi';

class City {
  final int cityId;
  final String cityName;
  final double latitude;
  final double longitude;

  City({required this.cityId, required this.cityName, required this.latitude, required this.longitude});

  factory City.fromJson(Map<String, dynamic> json) {
    return City(
        cityId: json['cityId'] as int,
        cityName: json['cityName'] ?? '',
        latitude: json['latitude'] ?? '16.16',
        longitude: json['longitude'] ?? '107.15');
  } 
}