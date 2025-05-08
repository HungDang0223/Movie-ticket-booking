import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:movie_tickets/features/payment/domain/services/vnpay_payment_service.dart';
import 'package:movie_tickets/features/payment/domain/services/zalopay_payment_service.dart';
import 'package:movie_tickets/features/payment/presentation/bloc/bloc.dart';
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
    Key? key,
    required this.movieTitle,
    required this.theaterName,
    required this.showDate,
    required this.showTime,
    required this.selectedSeats,
    required this.ticketPrice,
    required this.selectedSnacks,
    required this.snacksPrice,
  }) : super(key: key);

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
      'color': Color(0xFF1976D2),
    },
    {
      'id': 'momo',
      'name': 'Ví MoMo',
      'icon': 'icons/momo.png',
      'color': Color(0xFFAE2070),
    },
    {
      'id': 'zalopay',
      'name': 'ZaloPay',
      'icon': 'icons/zalopay.png',
      'color': Color(0xFF0068FF),
    },
    {
      'id': 'vnpay',
      'name': 'VNPay',
      'icon': 'icons/vnpay.png',
      'color': Color(0xFF004A9F),
    },
    {
      'id': 'visa',
      'name': 'Thẻ Visa/Master',
      'icon': 'icons/visa.svg',
      'color': Color(0xFF1434CB),
    },
    {
      'id': 'atm',
      'name': 'Thẻ ATM nội địa',
      'icon': 'icons/atm.png',
      'color': Color(0xFF00695C),
    },
    {
      'id': 'banking',
      'name': 'Chuyển khoản ngân hàng',
      'icon': 'icons/atm.png',
      'color': Color(0xFF616161),
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
    // platform.invokeMethod('startFragmentHostActivity');
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
        SnackBar(
          content: Text('Đã áp dụng mã giảm giá thành công!'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
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

//   void processPayment(BuildContext context) async {
//     if (selectedPaymentMethod == null) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text('Vui lòng chọn phương thức thanh toán'),
//           backgroundColor: Colors.red,
//         ),
//       );
//       return;
//     }

//     setState(() {
//       isProcessing = true;
//     });
//     bool paymentSuccess = false;
//     try {
      
      
//       // Process payment based on the selected method
//       if (selectedPaymentMethod == 'card' || selectedPaymentMethod == 'visa') {
//         // final card = await PaymentCardBottomSheet.show(context, totalAmount);
//         // if (card != null) {
//         //   // Payment was successful in the bottom sheet
//         //   final String transactionId = 'CGV${DateTime.now().millisecondsSinceEpoch.toString().substring(5)}';
//         //   Navigator.pushReplacement(
//         //     context,
//         //     MaterialPageRoute(
//               // builder: (context) => PaymentSuccessPage(
//               //   movieTitle: widget.movieTitle,
//               //   theaterName: widget.theaterName,
//               //   showDate: widget.showDate,
//               //   showTime: widget.showTime,
//               //   selectedSeats: widget.selectedSeats,
//               //   transactionId: transactionId,
//               // ),
//         //     ),
//         //   );
//         //   return;
//         // }
//         await StripePaymentService.instance.processPaymentWithSheet(totalAmount);
//         return;
//       } 
//       if (selectedPaymentMethod == 'zalopay') {
//   setState(() {
//     isProcessing = true; // Show loading indicator while creating order
//   });

//   try {
//     // Step 1: Create the order
//     final order = await ZalopayPaymentService.instance.createOrder(totalAmount.round());

//     if (order != null && order.zptranstoken != null) {
//       final zpTransToken = order.zptranstoken;

//       // Step 2: Start payment via native Android (invoke MethodChannel)
//       final result = await platform.invokeMethod('payOrder', {
//         "zptoken": zpTransToken,
//       });

//       // Step 3: Handle result
//       print("payOrder Result: '$result'.");

//       if (result == "Payment Success") {
//         paymentSuccess = true;
//         // Navigate to success screen or show dialog
//         print("✅ Payment success");
//       } else if (result == "User Canceled") {
//         print("⚠️ User canceled the payment");
//       } else {
//         print("❌ Payment failed");
//       }
//     } else {
//       print("❌ Failed to create order or missing token.");
//     }
//   } catch (e) {
//     print("Exception during ZaloPay flow: $e");
//   } finally {
//     setState(() {
//       isProcessing = false; // Always hide loading
//     });
//   }
// }

//       if (selectedPaymentMethod == 'vnpay') {
//         final paymentUrl = VNPAYPaymentService.instance.generatePaymentUrl(
//             version: "2.1.0",
//             tmnCode: "8PT36G81",
//             txnRef: DateTime.now().millisecondsSinceEpoch.toString(),
//             amount: 30000,
//             returnUrl: "https://d670-2001-ee0-4c0e.ngrok-free.app/api/vnpay/return",
//             ipAdress: "192.168.1.168",
//             vnpayHashKey: "GTY1T76QPSOLJ6TTSE3II4QFKU0M8Q0S",
//             vnPayHashType: VNPayHashType.HMACSHA512,
//             vnpayExpireDate: DateTime.now().add(Duration(days: 1)));
//         await show(paymentUrl: paymentUrl, context: context,
//           onPaymentSuccess: (params) {
//             print("Payment success: '$params'.");
//           },
//           onPaymentError: (params) {
//             print("Payment error: '$params'.");
//           },
//           );
//           return;
//       }

      
//     } catch (e) {
//       setState(() {
//         isProcessing = false;
//       });
      
//       if (e is StripeException) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text(e.error.localizedMessage ?? 'Payment failed'),
//             backgroundColor: Colors.red,
//           ),
//         );
//       } else {
//         print((e));
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text('An error occurred: ${e.toString()}'),
//             backgroundColor: Colors.red,
//           ),
//         );
//       }
//     }
    
//   }

void processPayment(BuildContext context) async {
    if (selectedPaymentMethod == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Vui lòng chọn phương thức thanh toán'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      isProcessing = true;
    });

    try {
      // Dispatch event based on selected payment method
      if (selectedPaymentMethod == 'zalopay') {
        // Call the ZaloPay payment processing BLoC event
        BlocProvider.of<PaymentBloc>(context).add(ProcessZaloPayPayment(totalAmount));
      } else if (selectedPaymentMethod == 'card' || selectedPaymentMethod == 'visa') {
        // Process Stripe payment
        await StripePaymentService.instance.processPaymentWithSheet(totalAmount);
        return;
      } 
      // Add other payment processing logic (like MoMo, VNPay, etc.) here...
      
    } catch (e) {
      setState(() {
        isProcessing = false;
      });

      // Handle exceptions accordingly
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('An error occurred: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
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
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        title: Text('Thanh toán', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.red),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: BlocListener<PaymentBloc, PaymentState>(
        listener: (context, state) {
          if (state is PaymentProcessing) {
            setState(() {
              isProcessing = true; // Show loading indicator
            });
          } else if (state is PaymentSuccess) {
            setState(() {
              isProcessing = false;
              // Navigate to success page
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
              SnackBar(
                content: Text('Payment canceled'),
                backgroundColor: Colors.orange,
              ),
            );
          }
        },
        child: isProcessing
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Build the ticket information card
                    _buildTicketInfoCard(),
                    SizedBox(height: 20),
                    // Build voucher section
                    _buildVoucherSection(),
                    SizedBox(height: 20),
                    // Build payment methods list
                    Text('Phương thức thanh toán', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                    SizedBox(height: 10),
                    _buildPaymentMethodsList(),
                    SizedBox(height: 20),
                    // Checkout button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => processPayment(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF4CAF50),
                          padding: EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        child: Text('THANH TOÁN ${totalAmount.toStringAsFixed(0)} đ', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
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
        color: Colors.grey.shade900,
        borderRadius: BorderRadius.circular(16),
      ),
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.movieTitle,
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: 12),
          
          _infoRow('Rạp', widget.theaterName),
          _infoRow('Ngày chiếu', widget.showDate),
          _infoRow('Giờ chiếu', widget.showTime),
          _infoRow('Ghế', widget.selectedSeats.join(', ')),
          
          Divider(color: Colors.grey.shade700, height: 30),
          
          // Pricing details
          _priceRow('Giá vé', widget.ticketPrice),
          if (widget.snacksPrice > 0)
            _priceRow('Bắp nước', widget.snacksPrice),
          if (discountAmount > 0)
            _priceRow('Giảm giá', -discountAmount, textColor: Colors.greenAccent),
          
          Divider(color: Colors.grey.shade700, height: 30),
          
          _priceRow('Tổng cộng', totalAmount, isBold: true),
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.grey,
              fontSize: 14,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: Colors.white,
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
      padding: EdgeInsets.symmetric(vertical: 4),
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
              color: textColor ?? Colors.white,
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
        Text(
          'Mã giảm giá',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 10),
        
        if (appliedVoucher != null)
          // Show applied voucher
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.green.withOpacity(0.5)),
            ),
            child: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.green, size: 20),
                SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        appliedVoucher!,
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Giảm ${discountAmount.toStringAsFixed(0)} đ',
                        style: TextStyle(
                          color: Colors.green,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.delete, color: Colors.red, size: 20),
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
                  style: TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Nhập mã giảm giá',
                    hintStyle: TextStyle(color: Colors.grey),
                    filled: true,
                    fillColor: Colors.grey.shade900,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  ),
                ),
              ),
              SizedBox(width: 10),
              ElevatedButton(
                onPressed: applyVoucher,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF4CAF50),
                  padding: EdgeInsets.symmetric(vertical: 14),
                ),
                child: Text('ÁP DỤNG'),
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
          margin: EdgeInsets.only(bottom: 8),
          decoration: BoxDecoration(
            color: isSelected ? method['color'].withOpacity(0.2) : Colors.grey.shade900,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isSelected ? method['color'] : Colors.transparent,
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
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    padding: EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: method['color'].withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Image.asset(
                      method['icon'],
                      errorBuilder: (context, error, stackTrace) => 
                          Icon(Icons.credit_card, color: method['color']),
                    ),
                  ),
                  SizedBox(width: 16),
                  
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          method['name'],
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                        if (method['id'] == 'card' && selectedCard != null)
                          Text(
                            selectedCard!.maskedCardNumber,
                            style: TextStyle(
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
