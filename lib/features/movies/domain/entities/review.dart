abstract class Review {
  final String userName;
  final String userRank;
  final double rating;
  final String reviewContent;
  final DateTime reviewDate;

  Review( 
      {required this.userName,
      required this.userRank,
      required this.rating,
      required this.reviewContent,
      required this.reviewDate});
}