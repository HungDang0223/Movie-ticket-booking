class Showing {
  final int showingId;
  final String movieName;
  final String cinemaName;
  final String screenName;
  final DateTime startTime;
  final DateTime endTime;
  final String language;
  final String subtitleLanguage;
  final String showingFormat;
  final DateTime showingDate;

  const Showing({
    required this.showingId,
    required this.movieName,
    required this.cinemaName,
    required this.screenName,
    required this.startTime,
    required this.endTime,
    required this.language,
    required this.subtitleLanguage,
    required this.showingFormat,
    required this.showingDate,
  });
  factory Showing.fromJson(Map<String, dynamic> json) {
    return Showing(
      showingId: json['showingId'] as int,
      movieName: json['movieName'] as String,
      cinemaName: json['cinemaName'] as String,
      screenName: json['screenName'] as String,
      startTime: DateTime.parse(json['startTime'] as String),
      endTime: DateTime.parse(json['endTime'] as String),
      language: json['language'] as String,
      subtitleLanguage: json['subtitleLanguage'] as String,
      showingFormat: json['showingFormat'] as String,
      showingDate: DateTime.parse(json['showingDate'] as String),
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'showingId': showingId,
      'movieName': movieName,
      'cinemaName': cinemaName,
      'screenName': screenName,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime.toIso8601String(),
      'language': language,
      'subtitleLanguage': subtitleLanguage,
      'showingFormat': showingFormat,
      'showingDate': showingDate.toIso8601String(),
    };
  }
}