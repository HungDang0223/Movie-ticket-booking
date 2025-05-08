import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_stripe/flutter_stripe.dart';
import '../../data/models/payment_card.dart';
import '../../domain/services/card_service.dart';
import '../../domain/services/stripe_payment_service.dart';
import '../../../../core/configs/payment_config.dart';
import 'package:flutter/cupertino.dart';

class PaymentCardBottomSheet extends StatefulWidget {
  final Function(PaymentCard) onCardSelected;
  final double amount;
  

  PaymentCardBottomSheet({
    super.key,
    required this.onCardSelected,
    required this.amount,
  });

  static Future<PaymentCard?> show(BuildContext context, double amount) async {
    // On web platform, we'll use a simulated card for demo purposes
    if (kIsWeb) {
      return const PaymentCard(
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
  bool _isPaymentProcessing = false;

  final scaffoldMessenger = GlobalKey<ScaffoldMessengerState>();

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

  Future<bool> _confirmCancel() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('Cancel Payment?'),
        content: const Text('Are you sure you want to cancel this payment?'),
        actions: [
          CupertinoDialogAction(
            child: const Text('No'),
            onPressed: () => Navigator.pop(context, false),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            child: const Text('Yes'),
            onPressed: () => Navigator.pop(context, true),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.45,
      ),
      decoration: const BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _isPaymentProcessing
              ? _buildProcessingHeader()
              : _buildHeader(),
          Flexible(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              transitionBuilder: (Widget child, Animation<double> animation) {
                return FadeTransition(
                  opacity: animation,
                  child: child,
                );
              },
              child: _isPaymentProcessing
                  ? _buildProcessingPayment()
                  : _isLoading
                      ? _buildLoadingIndicator()
                      : _showAddCard
                          ? _buildCardForm()
                          : _buildSavedCards(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: SingleChildScrollView(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
              child: Text(
                _showAddCard ? 'Add Payment Card' : 'Select Payment Card',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (!_showAddCard)
                  TextButton.icon(
                    onPressed: () {
                      setState(() {
                        _showAddCard = true;
                      });
                    },
                    icon: const Icon(Icons.add, color: Colors.green),
                    label: const Text(
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
                    icon: const Icon(Icons.credit_card, color: Colors.blue),
                    label: const Text(
                      'Saved',
                      style: TextStyle(color: Colors.blue),
                    ),
                  ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }

  Widget _buildCardForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            controller: _cardHolderNameController,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              labelText: 'Card Holder Name',
              labelStyle: const TextStyle(color: Colors.grey),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.grey.shade800),
                borderRadius: BorderRadius.circular(8),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: const BorderSide(color: Colors.blue),
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          const SizedBox(height: 16),
          CardFormField(
            controller: _cardFormController,
            style: CardFormStyle(
              textColor: Colors.white,
              placeholderColor: Colors.grey,
              backgroundColor: Colors.grey.shade900,
              borderColor: Colors.grey.shade800,
            ),
            enablePostalCode: false,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Checkbox(
                value: _saveCard,
                onChanged: (value) {
                  setState(() {
                    _saveCard = value ?? false;
                  });
                },
                fillColor: WidgetStateProperty.resolveWith(
                  (states) => states.contains(WidgetState.selected) 
                      ? const Color(0xFF4CAF50) 
                      : Colors.grey,
                ),
              ),
              const Text(
                'Save card for future payments',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4CAF50),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: _isPaymentProcessing ? null : _handlePayment,
            child: Text(
              'PAY ${widget.amount.toStringAsFixed(0)} đ',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSavedCards() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: _savedCards.map((card) => _buildCardItem(card)).toList(),
      ),
    );
  }

  Widget _buildCardItem(PaymentCard card) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: card.isDefault
              ? [const Color(0xFF1E3C72), const Color(0xFF2A5298)]
              : [const Color(0xFF363636), const Color(0xFF1C1C1C)],
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
        onTap: () => _handleSavedCardPayment(card),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      card.cardHolderName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Text(
                card.maskedCardNumber,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Expires: ${card.expiryDate}',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                  Row(
                    children: [
                      if (card.isDefault)
                        const Chip(
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
                          child: const Text(
                            'Set Default',
                            style: TextStyle(
                              color: Colors.blue,
                              fontSize: 12,
                            ),
                          ),
                          style: TextButton.styleFrom(
                            minimumSize: const Size(0, 0),
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                        ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red, size: 20),
                        onPressed: () async {
                          await _cardService.deleteCard(card.id);
                          _loadSavedCards();
                        },
                        constraints: const BoxConstraints(),
                        padding: const EdgeInsets.all(4),
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

  Widget _buildProcessingHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Colors.grey.shade800,
            width: 1,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Thanh toán',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          TextButton(
            onPressed: () async {
              if (await _confirmCancel()) {
                if (mounted) {
                  setState(() {
                    _isPaymentProcessing = false;
                  });
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Payment cancelled'),
                      backgroundColor: Colors.orange,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              }
            },
            child: const Text(
              'Hủy',
              style: TextStyle(
                color: Colors.red,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProcessingPayment() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(
            width: 48,
            height: 48,
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              strokeWidth: 3,
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Processing your payment...',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handlePayment() async {
    final cardDetails = _cardFormController.details;
    
    if (!cardDetails.complete) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please complete all card details'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    if (_cardHolderNameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter card holder name'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() {
      _isPaymentProcessing = true;
    });

    try {
      // Create card object
      final card = PaymentCard(
        id: 'card_${DateTime.now().millisecondsSinceEpoch}',
        cardNumber: cardDetails.number ?? '',
        expiryDate: '${cardDetails.expiryMonth}/${cardDetails.expiryYear}',
        cardHolderName: _cardHolderNameController.text.trim(),
        cvvCode: cardDetails.cvc ?? '',
      );

      // Process payment
      final result = await StripePaymentService.instance.processPayment(
        card,
        widget.amount,
      );

      if (result['status'] == 'succeeded') {
        // Save card if checkbox is checked
        if (_saveCard) {
          await _cardService.saveCard(card);
        }

        if (mounted) {
          Navigator.pop(context, card);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Payment successful!'),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      } else {
        throw Exception('Payment failed');
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Payment failed: ${e.toString()}'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Future<void> _handleSavedCardPayment(PaymentCard card) async {
    setState(() {
      _isPaymentProcessing = true;
    });

    try {
      final result = await StripePaymentService.instance.processPayment(
        card,
        widget.amount,
      );

      if (result['status'] == 'succeeded') {
        if (mounted) {
          Navigator.pop(context, card);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Payment successful!'),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      } else {
        throw Exception('Payment failed');
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Payment failed: ${e.toString()}'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }
} 