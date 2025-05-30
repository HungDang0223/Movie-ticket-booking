class Cinema {
  final int cinemaId;
  final String cinemaName;
  final String location;
  final int cityId;
  final String imagePath;
  final String fax;
  final String hotline;
  final double latitude;
  final double longitude;

  Cinema(
      {required this.cinemaId,
      required this.cinemaName,
      required this.location,
      required this.cityId,
      required this.imagePath,
      required this.fax,
      required this.hotline,
      required this.latitude,
      required this.longitude});

  factory Cinema.fromJson(Map<String, dynamic> json) {
    return Cinema(
        cinemaId: json['cinemaId'],
        cinemaName: json['cinemaName'],
        location: json['location'],
        cityId: json['cityId'],
        imagePath: json['imagePath'],
        fax: json['fax'],
        hotline: json['hotline'],
        latitude: json['latitude'],
        longitude: json['longitude']);
  }
  Map<String, dynamic> toJson() {
    return {
      'cinemaId': cinemaId,
      'cinemaName': cinemaName,
      'location': location,
      'cityId': cityId,
      'imagePath': imagePath,
      'fax': fax,
      'hotline': hotline,
      'latitude': latitude,
      'longitude': longitude,
    };
  }
}

class CinemaResponse {
  final Map<String, List<Cinema>> cinemasByCity;
  const CinemaResponse({
    required this.cinemasByCity,
  });
  factory CinemaResponse.fromJson(Map<String, dynamic> json) {
    
    final cinemasByCity = <String, List<Cinema>>{};
    json['data'].forEach((key, value) {
      cinemasByCity[key] = (value as List).map((e) => Cinema.fromJson(e)).toList();
    });

    return CinemaResponse(
      cinemasByCity: cinemasByCity,
    );
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    cinemasByCity.forEach((key, value) {
      data[key] = value.map((e) => e.toJson()).toList();
    });
    return {'data': data};
  }
}