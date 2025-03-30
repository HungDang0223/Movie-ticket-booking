import 'package:equatable/equatable.dart';

class PaymentCard extends Equatable {
  final String id;
  final String cardNumber;
  final String expiryDate;
  final String cardHolderName;
  final String cvvCode;
  final bool isDefault;

  const PaymentCard({
    required this.id,
    required this.cardNumber,
    required this.expiryDate,
    required this.cardHolderName,
    required this.cvvCode,
    this.isDefault = false,
  });

  // Create masked card number for display (only show last 4 digits)
  String get maskedCardNumber {
    if (cardNumber.length < 4) return cardNumber;
    final lastFourDigits = cardNumber.substring(cardNumber.length - 4);
    return '•••• •••• •••• $lastFourDigits';
  }

  // Copy with method to create a new instance with some modified properties
  PaymentCard copyWith({
    String? id,
    String? cardNumber,
    String? expiryDate,
    String? cardHolderName,
    String? cvvCode,
    bool? isDefault,
  }) {
    return PaymentCard(
      id: id ?? this.id,
      cardNumber: cardNumber ?? this.cardNumber,
      expiryDate: expiryDate ?? this.expiryDate,
      cardHolderName: cardHolderName ?? this.cardHolderName,
      cvvCode: cvvCode ?? this.cvvCode,
      isDefault: isDefault ?? this.isDefault,
    );
  }

  // For equality checks
  @override
  List<Object?> get props => [id, cardNumber, expiryDate, cardHolderName, cvvCode, isDefault];
} 