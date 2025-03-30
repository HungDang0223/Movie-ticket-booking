import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_stripe/flutter_stripe.dart';
import '../../data/models/payment_card.dart';
import '../../domain/services/card_service.dart';
import '../../domain/services/stripe_payment_service.dart';
import '../../../../core/configs/payment_config.dart';

class PaymentCardBottomSheet extends StatefulWidget {
  final Function(PaymentCard) onCardSelected;
  final double amount;

  const PaymentCardBottomSheet({
    Key? key,
    required this.onCardSelected,
    required this.amount,
  }) : super(key: key);

  static Future<PaymentCard?> show(BuildContext context, double amount) async {
    // On web platform, we'll use a simulated card for demo purposes
    if (kIsWeb) {
      return PaymentCard(
        id: 'web_demo_card',
        cardNumber: '4242424242424242',
        expiryDate: '12/25',
        cardHolderName: 'Web Demo Card',
        cvvCode: '123',
      );
    }

    return await showModalBottomSheet<PaymentCard>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: PaymentCardBottomSheet(
          onCardSelected: (card) {
            Navigator.pop(context, card);
          },
          amount: amount,
        ),
      ),
    );
  }

  @override
  State<PaymentCardBottomSheet> createState() => _PaymentCardBottomSheetState();
}

class _PaymentCardBottomSheetState extends State<PaymentCardBottomSheet> {
  final CardService _cardService = CardService();
  List<PaymentCard> _savedCards = [];
  bool _isLoading = true;
  bool _showAddCard = false;
  bool _saveCard = false;
  final _cardFormKey = GlobalKey<FormState>();
  final _cardFormController = CardFormEditController();
  final _cardHolderNameController = TextEditingController();
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _loadSavedCards();
  }

  @override
  void dispose() {
    _cardHolderNameController.dispose();
    super.dispose();
  }

  Future<void> _loadSavedCards() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final cards = await _cardService.getSavedCards();
      setState(() {
        _savedCards = cards;
        // Only show add card form if there are no saved cards
        _showAddCard = cards.isEmpty;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _showAddCard = true;
      });
    }
  }

  Future<void> _handlePayment() async {
    if (!_cardFormKey.currentState!.validate()) return;

    setState(() {
      _isProcessing = true;
    });

    try {
      final cardDetails = _cardFormController.details;
      final card = PaymentCard(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        cardNumber: cardDetails.number ?? '',
        expiryDate: '${cardDetails.expiryMonth}/${cardDetails.expiryYear}',
        cardHolderName: _cardHolderNameController.text,
        cvvCode: cardDetails.cvc ?? '',
      );

      if (_saveCard) {
        await _cardService.saveCard(card);
      }

      widget.onCardSelected(card);
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error processing payment: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isProcessing = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildHeader(),
          Flexible(
            child: _isLoading
                ? _buildLoadingIndicator()
                : _showAddCard
                    ? _buildCardForm()
                    : _buildSavedCards(),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            _showAddCard ? 'Add Payment Card' : 'Select Payment Card',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          Row(
            children: [
              if (!_showAddCard)
                TextButton.icon(
                  onPressed: () {
                    setState(() {
                      _showAddCard = true;
                    });
                  },
                  icon: Icon(Icons.add, color: Colors.green),
                  label: Text(
                    'New',
                    style: TextStyle(color: Colors.green),
                  ),
                ),
              if (_showAddCard && _savedCards.isNotEmpty)
                TextButton.icon(
                  onPressed: () {
                    setState(() {
                      _showAddCard = false;
                    });
                  },
                  icon: Icon(Icons.credit_card, color: Colors.blue),
                  label: Text(
                    'Saved',
                    style: TextStyle(color: Colors.blue),
                  ),
                ),
              IconButton(
                icon: Icon(Icons.close, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return Center(
      child: CircularProgressIndicator(),
    );
  }

  Widget _buildCardForm() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Form(
        key: _cardFormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _cardHolderNameController,
              style: TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Card Holder Name',
                labelStyle: TextStyle(color: Colors.grey),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey.shade800),
                  borderRadius: BorderRadius.circular(8),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.blue),
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            SizedBox(height: 16),
            CardFormField(
              controller: _cardFormController,
              style: CardFormStyle(
                textColor: Colors.white,
                placeholderColor: Colors.grey,
                backgroundColor: Colors.grey.shade900,
                borderColor: Colors.grey.shade800,
              ),
            ),
            SizedBox(height: 16),
            Row(
              children: [
                Checkbox(
                  value: _saveCard,
                  onChanged: (value) {
                    setState(() {
                      _saveCard = value ?? false;
                    });
                  },
                ),
                Text(
                  'Save card for future payments',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
            SizedBox(height: 24),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF4CAF50),
                padding: EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: _isProcessing ? null : _handlePayment,
              child: _isProcessing
                  ? SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Text(
                      'PAY ${widget.amount.toStringAsFixed(0)} đ',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSavedCards() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        children: _savedCards.map((card) => _buildCardItem(card)).toList(),
      ),
    );
  }

  Widget _buildCardItem(PaymentCard card) {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: card.isDefault
              ? [Color(0xFF1E3C72), Color(0xFF2A5298)]
              : [Color(0xFF363636), Color(0xFF1C1C1C)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: card.isDefault ? Colors.blue : Colors.grey.shade700,
          width: 1,
        ),
      ),
      child: InkWell(
        onTap: () => widget.onCardSelected(card),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      card.cardHolderName,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),
              Text(
                card.maskedCardNumber,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  letterSpacing: 2,
                ),
              ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Expires: ${card.expiryDate}',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                  Row(
                    children: [
                      if (card.isDefault)
                        Chip(
                          label: Text(
                            'Default',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                            ),
                          ),
                          backgroundColor: Colors.green,
                          padding: EdgeInsets.zero,
                          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        )
                      else
                        TextButton(
                          onPressed: () async {
                            await _cardService.setDefaultCard(card.id);
                            _loadSavedCards();
                          },
                          child: Text(
                            'Set Default',
                            style: TextStyle(
                              color: Colors.blue,
                              fontSize: 12,
                            ),
                          ),
                          style: TextButton.styleFrom(
                            minimumSize: Size(0, 0),
                            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                        ),
                      IconButton(
                        icon: Icon(Icons.delete, color: Colors.red, size: 20),
                        onPressed: () async {
                          await _cardService.deleteCard(card.id);
                          _loadSavedCards();
                        },
                        constraints: BoxConstraints(),
                        padding: EdgeInsets.all(4),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
} 