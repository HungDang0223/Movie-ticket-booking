import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:localization/localization.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:movie_tickets/core/constants/app_color.dart';
import 'package:movie_tickets/core/utils/snackbar_utilies.dart';
import 'package:movie_tickets/features/payment/domain/services/vnpay_payment_service.dart';
import 'package:movie_tickets/features/payment/domain/services/zalopay_payment_service.dart';
import 'package:movie_tickets/features/payment/presentation/bloc/bloc.dart';
import 'package:movie_tickets/injection.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'payment_success_page.dart';
import '../widgets/payment_card_bottom_sheet.dart';
import '../../data/models/payment_card.dart';
import '../../domain/services/card_service.dart';
import '../../domain/services/stripe_payment_service.dart';

class PaymentPage extends StatefulWidget {
  final String movieTitle;
  final String theaterName;
  final String showDate;
  final String showTime;
  final List<String> selectedSeats;
  final double ticketPrice;
  final Map<String, int> selectedSnacks; // Map of snack name to quantity
  final double snacksPrice;

  const PaymentPage({
    super.key,
    required this.movieTitle,
    required this.theaterName,
    required this.showDate,
    required this.showTime,
    required this.selectedSeats,
    required this.ticketPrice,
    required this.selectedSnacks,
    required this.snacksPrice,
  });

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  final TextEditingController _voucherController = TextEditingController();
  String? appliedVoucher;
  double discountAmount = 0;
  String? selectedPaymentMethod;
  bool isProcessing = false;
  PaymentCard? selectedCard;
  final CardService _cardService = CardService();
  final cardController = CardFormEditController();
  late PaymentBloc bloc = sl<PaymentBloc>();

  static const EventChannel eventChannel = EventChannel('flutter.native/eventPayOrder');
  static const MethodChannel platform = MethodChannel('flutter.native/channelPayOrder');

  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  
  String zpTransToken = "";
  String payResult = "";
  // Check if we're running on web
  bool get _isWeb => kIsWeb;

  // List of payment methods available in Vietnam
  final List<Map<String, dynamic>> paymentMethods = [
    {
      'id': 'card',
      'name': 'Thẻ tín dụng/ghi nợ',
      'icon': 'icons/credit_card.png',
      'color': const Color(0xFF1976D2),
    },
    {
      'id': 'momo',
      'name': 'Ví MoMo',
      'icon': 'assets/icons/momo.png',
      'color': const Color(0xFFAE2070),
    },
    {
      'id': 'zalopay',
      'name': 'ZaloPay',
      'icon': 'assets/icons/zalopay.png',
      'color': const Color(0xFF0068FF),
    },
    {
      'id': 'vnpay',
      'name': 'VNPay',
      'icon': 'assets/icons/vnpay.png',
      'color': const Color(0xFF004A9F),
    },
  ];

  // Map of voucher codes to discount percentages
  final Map<String, double> validVouchers = {
    'WELCOME10': 10.0, // 10% off
    'CGVNEW20': 20.0, // 20% off
    'MOVIE50K': 50000.0, // 50,000 VND off
  };
  
  @override
  void initState() {
    super.initState();
    bloc = sl<PaymentBloc>();
    if (Platform.isIOS) {
      eventChannel.receiveBroadcastStream().listen(
        (dynamic event) => _onEvent(event as Map<dynamic, dynamic>),
        onError: _onError
      );
    }
  }
  @override
  void dispose() {
    _voucherController.dispose();
    super.dispose();
  }

  void _onEvent(Map<dynamic, dynamic> event) {
    print("_onEvent: '$event'.");
    var res = Map<String, dynamic>.from(event);
    setState(() {
      if (res["errorCode"] == 1) {
        payResult = "Thanh toán thành công";
      } else if (res["errorCode"] == 4) {
        payResult = "User hủy thanh toán";
      }else {
        payResult = "Giao dịch thất bại";
      }
    });
  }

  void _onError(Object error) {
    print("_onError: '$error'.");
    setState(() {
      payResult = "Giao dịch thất bại";
    });
  }

  void applyVoucher() {
    final code = _voucherController.text.trim();
    if (validVouchers.containsKey(code)) {
      setState(() {
        appliedVoucher = code;
        final discount = validVouchers[code]!;
        if (discount < 100) {
          // Percentage discount
          discountAmount = (widget.ticketPrice + widget.snacksPrice) * (discount / 100);
        } else {
          // Fixed amount discount
          discountAmount = discount;
        }
        
        // Ensure discount doesn't exceed total price
        if (discountAmount > (widget.ticketPrice + widget.snacksPrice)) {
          discountAmount = widget.ticketPrice + widget.snacksPrice;
        }
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Đã áp dụng mã giảm giá thành công!'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Mã giảm giá không hợp lệ hoặc đã hết hạn'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void removeVoucher() {
    setState(() {
      appliedVoucher = null;
      discountAmount = 0;
      _voucherController.clear();
    });
  }

  void processPayment(BuildContext context) async {
    if (selectedPaymentMethod == null) {
      SnackbarUtils.showErrorSnackbar(
        context,
        'Vui lòng chọn phương thức thanh toán',
      );
      return;
    }

    setState(() {
      isProcessing = true;
    });
    bool paymentSuccess = false;
    try {
      
      
      // Process payment based on the selected method
      if (selectedPaymentMethod == 'card' || selectedPaymentMethod == 'visa') {
        // final card = await PaymentCardBottomSheet.show(context, totalAmount);
        // if (card != null) {
        //   // Payment was successful in the bottom sheet
        //   final String transactionId = 'CGV${DateTime.now().millisecondsSinceEpoch.toString().substring(5)}';
        //   Navigator.pushReplacement(
        //     context,
        //     MaterialPageRoute(
              // builder: (context) => PaymentSuccessPage(
              //   movieTitle: widget.movieTitle,
              //   theaterName: widget.theaterName,
              //   showDate: widget.showDate,
              //   showTime: widget.showTime,
              //   selectedSeats: widget.selectedSeats,
              //   transactionId: transactionId,
              // ),
        //     ),
        //   );
        //   return;
        // }
        await StripePaymentService.instance.processPaymentWithSheet(totalAmount);
        return;
      } 
      if (selectedPaymentMethod == 'zalopay') {
        bloc.add(ProcessZaloPayPayment(totalAmount));
      }

      if (selectedPaymentMethod == 'vnpay') {
        // final paymentUrl = VNPAYPaymentService.instance.generatePaymentUrl(
        //     version: "2.1.0",
        //     tmnCode: "8PT36G81",
        //     txnRef: DateTime.now().millisecondsSinceEpoch.toString(),
        //     amount: 30000,
        //     returnUrl: "https://skunk-elegant-hideously.ngrok-free.app/api/Vnpay/IpnAction",
        //     ipAdress: "192.168.1.168",
        //     vnpayHashKey: "GTY1T76QPSOLJ6TTSE3II4QFKU0M8Q0S",
        //     vnPayHashType: VNPayHashType.HMACSHA512,
        //     vnpayExpireDate: DateTime.now().add(Duration(days: 1)));
        final paymentUrl = await VNPAYPaymentService.instance.generatePaymentUrlApi(totalAmount, "PAY");
        await show(paymentUrl: paymentUrl, context: context,
          onPaymentSuccess: (params) {
            setState(() {
              isProcessing = false;
            });
            print("Payment success: '$params'.");
          },
          onPaymentError: (params) {
            setState(() {
              isProcessing = false;
            });
            print("Payment error: '$params'.");
          },
          );
          return;
      }

      
    } catch (e) {
      setState(() {
        isProcessing = false;
      });
      
      if (e is StripeException) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.error.localizedMessage ?? 'Payment failed'),
            backgroundColor: Colors.red,
          ),
        );
      } else {
        print((e));
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('An error occurred: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
    
  }
  // Show bottom sheet for card selection or input
  Future<void> _showCardSelectionBottomSheet() async {
    
    final PaymentCard? card = await PaymentCardBottomSheet.show(context, totalAmount);
    if (card != null) {
      setState(() {
        selectedCard = card;
      });
      // Proceed with payment after card is selected
      processPayment(context);
    }
  }

  double get totalAmount => widget.ticketPrice + widget.snacksPrice - discountAmount;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColor.DEFAULT,
        elevation: 0,
        title: const Text('Thanh toán', style: TextStyle(fontWeight: FontWeight.bold, color: AppColor.WHITE)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppColor.WHITE),
          tooltip: 'Quay lại',
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: BlocListener<PaymentBloc, PaymentState>(
        bloc: bloc,
        listener: (context, state) {
          if (state is PaymentProcessing) {
            CircularProgressIndicator();
          } else if (state is PaymentSuccess) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => PaymentSuccessPage(
                    movieTitle: widget.movieTitle,
                    theaterName: widget.theaterName,
                    showDate: widget.showDate,
                    showTime: widget.showTime,
                    selectedSeats: widget.selectedSeats,
                    transactionId: state.transactionId,
                  ),
                ),
              );
            });
          } else if (state is PaymentFailure) {
            setState(() {
              isProcessing = false; // Hide loading indicator
            });
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Payment failed: ${state.error}'),
                backgroundColor: Colors.red,
              ),
            );
          } else if (state is PaymentCanceled) {
            setState(() {
              isProcessing = false; // Hide loading indicator
            });
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Payment canceled'),
                backgroundColor: Colors.orange,
              ),
            );
          }
        },
        child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Build the ticket information card
                    _buildTicketInfoCard(),
                    const SizedBox(height: 20),
                    // Build voucher section
                    _buildVoucherSection(),
                    const SizedBox(height: 20),
                    // Build payment methods list
                    const Text('Phương thức thanh toán', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 10),
                    _buildPaymentMethodsList(),
                    const SizedBox(height: 20),
                    // Checkout button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => processPayment(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColor.DEFAULT_2,
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        child: Text('THANH TOÁN ${totalAmount.toStringAsFixed(0)} đ', style: const TextStyle(fontSize: 16, color: AppColor.WHITE, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
      ),
    );
  }

  Widget _buildTicketInfoCard() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade800, width: 1),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.movieTitle,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 12),
          
          _infoRow('Rạp', widget.theaterName),
          _infoRow('Ngày chiếu', widget.showDate),
          _infoRow('Giờ chiếu', widget.showTime),
          _infoRow('Ghế', widget.selectedSeats.join(', ')),
          
          Divider(color: Colors.grey.shade700, height: 30),
          
          // Pricing details          _priceRow('payment.ticket_price'.i18n(), widget.ticketPrice),
          if (widget.snacksPrice > 0)
            _priceRow('payment.snacks'.i18n(), widget.snacksPrice),
          if (discountAmount > 0)
            _priceRow('payment.discount'.i18n(), -discountAmount, textColor: Colors.greenAccent),
          
          Divider(color: Colors.grey.shade700, height: 30),
          
          _priceRow('payment.total'.i18n(), totalAmount, isBold: true),
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 14,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _priceRow(String label, double amount, {bool isBold = false, Color? textColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.grey,
              fontSize: 14,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            '${amount >= 0 ? "" : "-"}${amount.abs().toStringAsFixed(0)} đ',
            style: TextStyle(
              fontSize: isBold ? 16 : 14,
              fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVoucherSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Mã giảm giá',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 10),
        
        if (appliedVoucher != null)
          // Show applied voucher
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.green.withOpacity(0.5)),
            ),
            child: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.green, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        appliedVoucher!,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Giảm ${discountAmount.toStringAsFixed(0)} đ',
                        style: const TextStyle(
                          color: Colors.green,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red, size: 20),
                  onPressed: removeVoucher,
                ),
              ],
            ),
          )
        else
          // Show voucher input field
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _voucherController,
                  decoration: InputDecoration(
                    hintText: 'Nhập mã giảm giá',
                    hintStyle: const TextStyle(color: Colors.grey),
                    filled: false,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              ElevatedButton(
                onPressed: applyVoucher,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColor.DEFAULT_2,
                  padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                ),
                child: const Text('ÁP DỤNG', style: TextStyle(color: AppColor.WHITE),),
              ),
            ],
          ),
      ],
    );
  }

  Widget _buildPaymentMethodsList() {
    return Column(
      children: paymentMethods.map((method) {
        final bool isSelected = selectedPaymentMethod == method['id'];
        
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          decoration: BoxDecoration(
            color: isSelected ? method['color'].withOpacity(0.2) : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isSelected ? method['color'] : AppColor.GRAY1,
              width: 1,
            ),
          ),
          child: InkWell(
            onTap: () {
              setState(() {
                selectedPaymentMethod = method['id'];
                // Clear selected card when changing payment method
                if (method['id'] != 'card') {
                  selectedCard = null;
                } else {
                  // Show card selection bottom sheet if card payment method is selected
                  _showCardSelectionBottomSheet();
                }
              });
            },
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: method['color'].withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isSelected ? method['color'] : AppColor.GRAY1,
                        width: 1,
                      ),
                    ),
                    child: Image.asset(
                      method['icon'],
                      errorBuilder: (context, error, stackTrace) => 
                          Icon(Icons.credit_card, color: method['color']),
                    ),
                  ),
                  const SizedBox(width: 16),
                  
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          method['name'],
                          style: TextStyle(
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                        if (method['id'] == 'card' && selectedCard != null)
                          Text(
                            selectedCard!.maskedCardNumber,
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 12,
                            ),
                          ),
                      ],
                    ),
                  ),
                  if (isSelected)
                    Icon(Icons.check_circle, color: method['color']),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

Future<void> show({
    required String paymentUrl,
    Function(Map<String, dynamic>)? onPaymentSuccess,
    Function(Map<String, dynamic>)? onPaymentError,
    Function()? onWebPaymentComplete,
    required BuildContext context,
  }) async {
    if (kIsWeb) {
      await launchUrlString(
        paymentUrl,
        webOnlyWindowName: '_self',
      );
      if (onWebPaymentComplete != null) {
        onWebPaymentComplete();
      }
    } else {
      final webViewController = WebViewController()
        ..setJavaScriptMode(JavaScriptMode.unrestricted)
        ..setNavigationDelegate(
          NavigationDelegate(
            onUrlChange: (change) async {
              final url = change.url;
              if (url != null && url.contains('vnp_ResponseCode')) {
                final params = Uri.parse(url).queryParameters;
                if (params['vnp_ResponseCode'] == '00') {
                  if (onPaymentSuccess != null) {
                    onPaymentSuccess(params);
                  }
                } else {
                  if (onPaymentError != null) {
                    onPaymentError(params);
                  }
                }
                Navigator.of(context).pop();
              }
            },
            onPageFinished: (String url) {
              print(url);
              // Kiểm tra nếu URL chứa `vnp_ReturnUrl`
              if (url.contains("vnp_ReturnUrl")) {
                Uri uri = Uri.parse(url);
                String responseCode = uri.queryParameters["vnp_ResponseCode"] ?? "99";

                // Đóng WebView và trả về kết quả
                Navigator.pop(context, responseCode == "00" ? "success" : "failed");
              }
            },
          ),
        )
        ..loadRequest(Uri.parse(paymentUrl));

      await showDialog(
        context: context,
        builder: (context) => WebViewWidget(
          controller: webViewController,
        ),
      );
    }
  }
