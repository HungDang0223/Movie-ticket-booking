class Snack {
  final int snackId;
  final String name;
  final String description;
  final double price;
  final String imageUrl;

  Snack({
    required this.snackId,
    required this.name,
    required this.description,
    required this.price,
    required this.imageUrl,
  });

  factory Snack.fromJson(Map<String, dynamic> json) {
    return Snack(
      snackId: json['snackId'],
      name: json['name'],
      description: json['description'],
      price: json['price'].toDouble(),
      imageUrl: json['image_url'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'snackId': snackId,
      'name': name,
      'description': description,
      'price': price,
      'image_url': imageUrl,
    };
  }
}