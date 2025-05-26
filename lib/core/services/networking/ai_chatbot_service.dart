// import 'dart:convert';
// import 'package:firebase_ai/firebase_ai.dart';

// class AIChatbotService {
//   late GenerativeModel _model;
//   ChatSession? _chat;
//   ReservationModel? _currentReservation;
//   String _language = 'vi'; // Mặc định tiếng Việt

//   void initialize({String language = 'vi'}) {
//     _language = language;
//     _model = FirebaseAI.googleAI().generativeModel(
//       model: 'gemini-2.0-flash',
//       generationConfig: GenerationConfig(
//         maxOutputTokens: 1000,
//         temperature: 0.7,
//         topP: 0.9,
//       ),
//     );
//   }

//   Future<void> startChatWithReservation(ReservationModel reservation) async {
//     _currentReservation = reservation;
    
//     final systemPrompt = _buildSystemPrompt(reservation);

//     _chat = _model.startChat(history: [
//       Content.text(systemPrompt),
//       Content.model([TextPart(_getWelcomeMessage(reservation.customerName))])
//     ]);
//   }

//   String _buildSystemPrompt(ReservationModel reservation) {
//     final Map<String, String> prompts = {
//       'vi': '''
//         Bạn là trợ lý AI cho ứng dụng đặt vé xem phim. Bạn có quyền truy cập vào thông tin đặt chỗ của khách hàng.
//         Luôn lịch sự, thân thiện và chuyên nghiệp. Bạn có thể hỗ trợ:
//         - Trả lời câu hỏi về đặt chỗ của họ
//         - Thay đổi đặt chỗ (thời gian, số khách, yêu cầu đặc biệt)
//         - Cung cấp thông tin về ứng dụng đặt vé xem phim
//         - Hỗ trợ hủy vé

//         Thông tin đặt chỗ hiện tại:
//         ${reservation.toContextString()}

//         Hướng dẫn:
//         - Luôn xác nhận danh tính khách hàng trước khi thay đổi
//         - Thể hiện sự đồng cảm và hiểu biết
//         - Nếu cần thay đổi, hãy giải thích những gì bạn đang làm
//         - Giữ phản hồi ngắn gọn nhưng hữu ích
//         - Luôn gọi khách hàng bằng tên khi thích hợp
//         - Chỉ trả lời bằng tiếng Việt
//       ''',
//       'en': '''
//         You are a helpful assistant for movie booking ticket application chatbot. You have access to the customer's reservation details.
//         Always be polite, friendly and professional. You can help with:
//         - Answering questions about their reservation
//         - Making changes to their reservation (time, guests, special requests)
//         - Providing information for movie booking ticket application
//         - Helping with cancellations

//         Current reservation context:
//         ${reservation.toContextString()}

//         Instructions:
//         - Always confirm the customer's identity before making changes
//         - Be empathetic and understanding
//         - If you need to make changes, explain what you're doing
//         - Keep responses concise but helpful
//         - Always address the customer by name when appropriate
//         - Only respond in English
//       ''',
//       'zh': '''
//         您是电影订票应用程序聊天机器人的有用助手。您可以访问客户的预订详细信息。
//         总是要礼貌、友好和专业。您可以帮助：
//         - 回答有关他们预订的问题
//         - 更改他们的预订（时间、客人、特殊要求）
//         - 提供电影订票应用程序的信息
//         - 帮助取消

//         当前预订上下文：
//         ${reservation.toContextString()}

//         说明：
//         - 在进行更改之前始终确认客户身份
//         - 要有同理心和理解
//         - 如果您需要进行更改，请解释您在做什么
//         - 保持回复简洁但有用
//         - 在适当的时候总是称呼客户的姓名
//         - 只用中文回复
//       ''',
//     };

//     return prompts[_language] ?? prompts['en']!;
//   }

//   String _getWelcomeMessage(String customerName) {
//     final Map<String, String> messages = {
//       'vi': 'Xin chào $customerName! Tôi thấy bạn có một đặt chỗ với chúng tôi. Tôi có thể hỗ trợ gì cho bạn hôm nay?',
//       'en': 'Hello $customerName! I can see you have a reservation with us. How can I assist you today?',
//       'zh': '您好 $customerName！我看到您在我们这里有预订。今天我可以为您提供什么帮助吗？',
//     };

//     return messages[_language] ?? messages['en']!;
//   }

//   Future<String> sendMessage(String message) async {
//     if (_chat == null) {
//       throw Exception('Chat not initialized. Please start chat with reservation first.');
//     }

//     try {
//       final response = await _chat!.sendMessage(Content.text(message));
//       return response.text ?? _getErrorMessage();
//     } catch (e) {
//       return _getTechnicalErrorMessage();
//     }
//   }

//   String _getErrorMessage() {
//     final Map<String, String> messages = {
//       'vi': 'Tôi xin lỗi, nhưng tôi không thể xử lý yêu cầu của bạn. Vui lòng thử lại.',
//       'en': 'I apologize, but I could not process your request. Please try again.',
//       'zh': '很抱歉，我无法处理您的请求。请再试一次。',
//     };
    
//     return messages[_language] ?? messages['en']!;
//   }

//   String _getTechnicalErrorMessage() {
//     final Map<String, String> messages = {
//       'vi': 'Tôi đang gặp một số khó khăn kỹ thuật. Vui lòng thử lại sau một lát.',
//       'en': 'I\'m experiencing some technical difficulties. Please try again in a moment.',
//       'zh': '我遇到了一些技术困难。请稍后再试。',
//     };
    
//     return messages[_language] ?? messages['en']!;
//   }

//   // Method để thay đổi ngôn ngữ trong runtime
//   void setLanguage(String language) {
//     _language = language;
//   }

//   String getCurrentLanguage() {
//     return _language;
//   }

//   Future<void> updateReservationContext(ReservationModel updatedReservation) async {
//     _currentReservation = updatedReservation;
    
//     if (_chat != null) {
//       final updateMessage = _getUpdateMessage(updatedReservation);
//       await _chat!.sendMessage(Content.text(updateMessage));
//     }
//   }

//   String _getUpdateMessage(ReservationModel reservation) {
//     final Map<String, String> messages = {
//       'vi': 'CẬP NHẬT HỆ THỐNG: Đặt chỗ đã được cập nhật. Chi tiết mới: ${reservation.toContextString()}',
//       'en': 'SYSTEM UPDATE: Reservation has been updated. New details: ${reservation.toContextString()}',
//       'zh': '系统更新：预订已更新。新详细信息：${reservation.toContextString()}',
//     };
    
//     return messages[_language] ?? messages['en']!;
//   }

//   ReservationModel? getCurrentReservation() {
//     return _currentReservation;
//   }

//   void resetChat() {
//     _chat = null;
//     _currentReservation = null;
//   }

//   bool get isChatActive => _chat != null;

//   // Danh sách ngôn ngữ được hỗ trợ
//   static List<String> getSupportedLanguages() {
//     return ['vi', 'en', 'zh'];
//   }
// }

// class ReservationModel {
//   final String id;
//   final String customerName;
//   final String email;
//   final String phone;
//   final DateTime reservationDate;
//   final String time;
//   final int numberOfGuests;
//   final String tableType;
//   final String specialRequests;
//   final String status;

//   ReservationModel({
//     required this.id,
//     required this.customerName,
//     required this.email,
//     required this.phone,
//     required this.reservationDate,
//     required this.time,
//     required this.numberOfGuests,
//     required this.tableType,
//     this.specialRequests = '',
//     this.status = 'confirmed',
//   });

//   Map<String, dynamic> toJson() {
//     return {
//       'id': id,
//       'customerName': customerName,
//       'email': email,
//       'phone': phone,
//       'reservationDate': reservationDate.toIso8601String(),
//       'time': time,
//       'numberOfGuests': numberOfGuests,
//       'tableType': tableType,
//       'specialRequests': specialRequests,
//       'status': status,
//     };
//   }

//   factory ReservationModel.fromJson(Map<String, dynamic> json) {
//     return ReservationModel(
//       id: json['id'],
//       customerName: json['customerName'],
//       email: json['email'],
//       phone: json['phone'],
//       reservationDate: DateTime.parse(json['reservationDate']),
//       time: json['time'],
//       numberOfGuests: json['numberOfGuests'],
//       tableType: json['tableType'],
//       specialRequests: json['specialRequests'] ?? '',
//       status: json['status'] ?? 'confirmed',
//     );
//   }

//   String toContextString() {
//     return '''
// Reservation Details:
// - ID: $id
// - Customer: $customerName
// - Email: $email  
// - Phone: $phone
// - Date: ${reservationDate.day}/${reservationDate.month}/${reservationDate.year}
// - Time: $time
// - Guests: $numberOfGuests people
// - Table Type: $tableType
// - Special Requests: $specialRequests
// - Status: $status
// ''';
//   }
// }

import 'dart:convert';
import 'package:firebase_ai/firebase_ai.dart';

// Model cho response từ AI
class AIChatResponse {
  final String message;
  final List<ChatAction>? actions;
  final Map<String, dynamic>? metadata;

  AIChatResponse({
    required this.message,
    this.actions,
    this.metadata,
  });

  factory AIChatResponse.fromJson(Map<String, dynamic> json) {
    return AIChatResponse(
      message: json['message'] ?? '',
      actions: json['actions'] != null 
        ? (json['actions'] as List).map((e) => ChatAction.fromJson(e)).toList()
        : null,
      metadata: json['metadata'],
    );
  }
}

// Model cho các action mà AI có thể thực hiện
class ChatAction {
  final String type; // 'navigate', 'api_call', 'button'
  final String label;
  final String route;
  final Map<String, dynamic>? parameters;
  final String? apiEndpoint;
  final String? buttonId;

  ChatAction({
    required this.type,
    required this.label,
    this.route = '',
    this.parameters,
    this.apiEndpoint,
    this.buttonId,
  });

  factory ChatAction.fromJson(Map<String, dynamic> json) {
    return ChatAction(
      type: json['type'],
      label: json['label'],
      route: json['route'] ?? '',
      parameters: json['parameters'],
      apiEndpoint: json['apiEndpoint'],
      buttonId: json['buttonId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'label': label,
      'route': route,
      'parameters': parameters,
      'apiEndpoint': apiEndpoint,
      'buttonId': buttonId,
    };
  }
}

class AIChatbotService {
  late GenerativeModel _model;
  ChatSession? _chat;
  ReservationModel? _currentReservation;
  String _language = 'vi';

  void initialize({String language = 'vi'}) {
    _language = language;
    _model = FirebaseAI.googleAI().generativeModel(
      model: 'gemini-2.0-flash',
      generationConfig: GenerationConfig(
        maxOutputTokens: 1500,
        temperature: 0.7,
        topP: 0.9,
      ),
    );
  }

  Future<void> startChatWithReservation(ReservationModel reservation) async {
    _currentReservation = reservation;
    
    final systemPrompt = _buildSystemPrompt(reservation);

    _chat = _model.startChat(history: [
      Content.text(systemPrompt),
      Content.model([TextPart(_getWelcomeMessage(reservation.customerName))])
    ]);
  }

  String _buildSystemPrompt(ReservationModel reservation) {
    final Map<String, String> prompts = {
      'vi': '''
        Bạn là trợ lý AI cho ứng dụng đặt vé xem phim. Bạn có thể hỗ trợ khách hàng điều hướng trong app.

        CÁC TÍNH NĂNG BỠI BẠN CÓ THỂ HỖ TRỢ:
        1. Trả lời câu hỏi về đặt vé
        2. Điều hướng đến các trang khác nhau
        3. Tạo các button action cho người dùng
        4. Gọi API để lấy dữ liệu

        CÁC ROUTE AVAILABLE:
        - /home: Trang chủ
        - /movie_detail: Chi tiết phim (cần movieId)
        - /showing_movie_booking: Đặt vé (cần movieId)
        - /seat_booking: Chọn ghế (cần movie + showingMovie)
        - /snack_booking: Chọn đồ ăn
        - /payment: Thanh toán
        - /setting: Cài đặt

        CÁC API ENDPOINTS:
        - GET /api/movies: Lấy danh sách phim
        - GET /api/movies/{id}: Lấy chi tiết phim
        - GET /api/showings/{movieId}: Lấy lịch chiếu
        - GET /api/theaters: Lấy danh sách rạp

        ĐỊNH DẠNG RESPONSE:
        Bạn PHẢI trả về JSON với format:
        {
          "message": "Tin nhắn của bạn",
          "actions": [
            {
              "type": "navigate|api_call|button",
              "label": "Nhãn hiển thị",
              "route": "/route_path",
              "parameters": {"key": "value"},
              "apiEndpoint": "/api/endpoint",
              "buttonId": "unique_id"
            }
          ]
        }

        VÍ DỤ:
        - Khi user hỏi "Tôi muốn xem phim": Tạo button điều hướng đến trang chủ
        - Khi user hỏi "Phim gì hay?": Gọi API lấy danh sách phim
        - Khi user chọn phim: Điều hướng đến trang chi tiết

        Thông tin đặt chỗ hiện tại:
        ${reservation.toContextString()}

        LUÔN trả về JSON hợp lệ và chỉ sử dụng tiếng Việt.
      ''',
      'en': '''
        You are an AI assistant for movie booking ticket application. You can help customers navigate through the app.

        FEATURES YOU CAN SUPPORT:
        1. Answer questions about movie booking
        2. Navigate to different pages
        3. Create action buttons for users
        4. Call APIs to fetch data

        AVAILABLE ROUTES:
        - /home: Home page
        - /movie_detail: Movie details (needs movieId)
        - /showing_movie_booking: Book tickets (needs movieId)
        - /seat_booking: Select seats (needs movie + showingMovie)
        - /snack_booking: Select snacks
        - /payment: Payment
        - /setting: Settings

        API ENDPOINTS:
        - GET /api/movies: Get movie list
        - GET /api/movies/{id}: Get movie details
        - GET /api/showings/{movieId}: Get showtimes
        - GET /api/theaters: Get theater list

        RESPONSE FORMAT:
        You MUST return JSON with format:
        {
          "message": "Your message",
          "actions": [
            {
              "type": "navigate|api_call|button",
              "label": "Display label",
              "route": "/route_path",
              "parameters": {"key": "value"},
              "apiEndpoint": "/api/endpoint",
              "buttonId": "unique_id"
            }
          ]
        }

        Current reservation context:
        ${reservation.toContextString()}

        ALWAYS return valid JSON and only respond in English.
      ''',
    };

    return prompts[_language] ?? prompts['en']!;
  }

  String _getWelcomeMessage(String customerName) {
    final welcomeResponse = {
      "message": _language == 'vi' 
        ? "Xin chào $customerName! Tôi có thể giúp bạn đặt vé xem phim, tìm phim hay, hoặc điều hướng trong ứng dụng. Bạn cần hỗ trợ gì?"
        : "Hello $customerName! I can help you book movie tickets, find great movies, or navigate through the app. What do you need help with?",
      "actions": [
        {
          "type": "navigate",
          "label": _language == 'vi' ? "🎬 Xem phim đang chiếu" : "🎬 Browse Movies",
          "route": "/home"
        },
        {
          "type": "api_call",
          "label": _language == 'vi' ? "🎭 Phim hay nhất" : "🎭 Top Movies",
          "apiEndpoint": "/api/movies/trending"
        },
        {
          "type": "navigate",
          "label": _language == 'vi' ? "⚙️ Cài đặt" : "⚙️ Settings",
          "route": "/setting"
        }
      ]
    };

    return jsonEncode(welcomeResponse);
  }

  Future<AIChatResponse> sendMessage(String message) async {
    if (_chat == null) {
      throw Exception('Chat not initialized. Please start chat with reservation first.');
    }

    try {
      final response = await _chat!.sendMessage(Content.text(message));
      final responseText = response.text ?? '{"message": "Lỗi xử lý", "actions": []}';
      
      // Parse JSON response from AI
      try {
        final jsonResponse = jsonDecode(responseText);
        return AIChatResponse.fromJson(jsonResponse);
      } catch (e) {
        // Nếu AI không trả về JSON, wrap thành response thông thường
        return AIChatResponse(
          message: responseText,
          actions: null,
        );
      }
    } catch (e) {
      return AIChatResponse(
        message: _language == 'vi' 
          ? 'Tôi đang gặp một số khó khăn kỹ thuật. Vui lòng thử lại sau một lát.'
          : 'I\'m experiencing some technical difficulties. Please try again in a moment.',
        actions: null,
      );
    }
  }

  // Method để xử lý action từ AI
  Future<AIChatResponse> executeAction(ChatAction action, {Map<String, dynamic>? additionalData}) async {
    switch (action.type) {
      case 'api_call':
        return await _handleApiCall(action, additionalData);
      case 'navigate':
        return _handleNavigation(action);
      case 'button':
        return await _handleButtonAction(action, additionalData);
      default:
        return AIChatResponse(
          message: 'Unknown action type: ${action.type}',
        );
    }
  }

  Future<AIChatResponse> _handleApiCall(ChatAction action, Map<String, dynamic>? data) async {
    // Simulate API call - thay thế bằng actual API call
    await Future.delayed(Duration(milliseconds: 500));
    
    final message = _language == 'vi' 
      ? "Đã gọi API ${action.apiEndpoint}. Dữ liệu đã được tải!"
      : "Called API ${action.apiEndpoint}. Data loaded!";
    
    return AIChatResponse(
      message: message,
      metadata: {'api_result': 'success', 'endpoint': action.apiEndpoint},
    );
  }

  AIChatResponse _handleNavigation(ChatAction action) {
    final message = _language == 'vi' 
      ? "Đang điều hướng đến ${action.route}..."
      : "Navigating to ${action.route}...";
    
    return AIChatResponse(
      message: message,
      metadata: {
        'navigation': {
          'route': action.route,
          'parameters': action.parameters,
        }
      },
    );
  }

  Future<AIChatResponse> _handleButtonAction(ChatAction action, Map<String, dynamic>? data) async {
    final message = _language == 'vi' 
      ? "Đã thực hiện action: ${action.label}"
      : "Executed action: ${action.label}";
    
    return AIChatResponse(
      message: message,
      metadata: {'button_action': action.buttonId, 'data': data},
    );
  }

  void setLanguage(String language) {
    _language = language;
  }

  String getCurrentLanguage() {
    return _language;
  }

  Future<void> updateReservationContext(ReservationModel updatedReservation) async {
    _currentReservation = updatedReservation;
    
    if (_chat != null) {
      final updateMessage = _getUpdateMessage(updatedReservation);
      await _chat!.sendMessage(Content.text(updateMessage));
    }
  }

  String _getUpdateMessage(ReservationModel reservation) {
    final updateResponse = {
      "message": _language == 'vi' 
        ? "Thông tin đặt chỗ đã được cập nhật"
        : "Reservation information has been updated",
      "actions": []
    };
    
    return jsonEncode(updateResponse);
  }

  ReservationModel? getCurrentReservation() {
    return _currentReservation;
  }

  void resetChat() {
    _chat = null;
    _currentReservation = null;
  }

  bool get isChatActive => _chat != null;
}

// Existing ReservationModel stays the same
class ReservationModel {
  final String id;
  final String customerName;
  final String email;
  final String phone;
  final DateTime reservationDate;
  final String time;
  final int numberOfGuests;
  final String tableType;
  final String specialRequests;
  final String status;

  ReservationModel({
    required this.id,
    required this.customerName,
    required this.email,
    required this.phone,
    required this.reservationDate,
    required this.time,
    required this.numberOfGuests,
    required this.tableType,
    this.specialRequests = '',
    this.status = 'confirmed',
  });

  String toContextString() {
    return '''
Reservation Details:
- ID: $id
- Customer: $customerName
- Email: $email  
- Phone: $phone
- Date: ${reservationDate.day}/${reservationDate.month}/${reservationDate.year}
- Time: $time
- Guests: $numberOfGuests people
- Table Type: $tableType
- Special Requests: $specialRequests
- Status: $status
''';
  }
}