class Combo {
  final int comboId;
  final String comboName;
  final String imageUrl;
  final String description;
  final int price;

  const Combo({
    required this.comboId,
    required this.comboName,
    required this.imageUrl,
    required this.description,
    required this.price,
  });
  factory Combo.fromJson(Map<String, dynamic> json) {
    return Combo(
      comboId: json['comboId'] as int,
      comboName: json['comboName'] as String,
      imageUrl: json['imageUrl'] as String,
      description: json['description'] as String,
      price: (json['price'] as num).toInt(), // Changed to toInt()
    );
  }
  
    Map<String, dynamic> toJson() {
      return {
        'comboId': comboId,
        'comboName': comboName,
        'imagePath': imageUrl,
        'description': description,
        'price': price,
      };
    }
}