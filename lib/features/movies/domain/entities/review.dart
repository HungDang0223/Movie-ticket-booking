abstract class Review {
  final int reviewId;
  final int userId;
  final String fullName;
  final String photoPath;
  final int movieId;
  final int rating;
  final String reviewContent;
  final DateTime reviewDate;
  final int likes;
  final int unlikes;

  Review(
      {required this.reviewId,
      required this.userId,
      required this.fullName,
      required this.photoPath,
      required this.movieId,
      required this.rating,
      required this.reviewContent,
      required this.reviewDate,
      required this.likes,
      required this.unlikes});
}