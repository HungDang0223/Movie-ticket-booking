
class ShowingMovie {
  final int showingId;
  final int screenId;
  final String cinemaName;
  final String screenName;
  final String startTime;
  final String endTime;
  final String language;
  final String subtitleLanguage;
  final String showingFormat;
  final DateTime showingDate;
  final int seatCount;

  const ShowingMovie({
    required this.showingId,
    required this.screenId,
    required this.cinemaName,
    required this.screenName,
    required this.startTime,
    required this.endTime,
    required this.language,
    required this.subtitleLanguage,
    required this.showingFormat,
    required this.showingDate,
    required this.seatCount,
  });
  factory ShowingMovie.fromJson(Map<String, dynamic> json) {
    return ShowingMovie(
      showingId: json['showingId'] as int,
      screenId: json['screenId'] as int,
      cinemaName: json['cinemaName'] as String,
      screenName: json['screenName'] as String,
      startTime: json['startTime'] as String,
      endTime: json['endTime'] as String,
      language: json['language'] as String,
      subtitleLanguage: json['subtitleLanguage'] as String,
      showingFormat: json['showingFormat'] as String,
      showingDate: DateTime.parse(json['showingDate'] as String),
      seatCount: json['seatCount'] as int,
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'showingId': showingId,
      'screenId': screenId,
      'cinemaName': cinemaName,
      'screenName': screenName,
      'startTime': startTime,
      'endTime': endTime,
      'language': language,
      'subtitleLanguage': subtitleLanguage,
      'showingFormat': showingFormat,
      'showingDate': showingDate.toIso8601String(),
      'seatCount': seatCount,
    };
  }
}