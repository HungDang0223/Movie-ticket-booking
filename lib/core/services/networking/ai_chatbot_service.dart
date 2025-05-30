import 'dart:convert';
import 'dart:io';
import 'package:firebase_ai/firebase_ai.dart';
import 'package:movie_tickets/features/authentication/data/models/user_model.dart';
import 'package:movie_tickets/features/movies/data/models/movie_model.dart';
import 'package:movie_tickets/features/movies/domain/repositories/movie_repository.dart';
import 'package:movie_tickets/injection.dart';

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
  UserModel? _currentUser;
  String _language = 'vi';
  final MovieRepository movieRepository = sl<MovieRepository>();
  List<MovieModel>? _cachedMovies;


  void initialize({String language = 'vi'}) {
    _language = language;
    _model = FirebaseAI.googleAI().generativeModel(
      model: 'gemini-2.0-flash-exp',
      generationConfig: GenerationConfig(
        maxOutputTokens: 2000,
        temperature: 0.7,
        topP: 0.9,
      ),
    );
  }

  Future<void> startChatWithReservation(UserModel user) async {
    _currentUser = user;
    
    // Load movies cache for better search
    await _loadMoviesCache();

    final systemPrompt = _buildSystemPrompt();

    _chat = _model.startChat(history: [
      Content.text(systemPrompt),
      Content.model([TextPart(_getWelcomeMessage(_currentUser!.fullName))])
    ]);
  }

  Future<void> _loadMoviesCache() async {
    try {
      final result = await movieRepository.getListShowingMovies();
      if (result.isSuccess && result.data != null) {
        _cachedMovies = result.data;
      }
    } catch (e) {
      _cachedMovies = [];
      print('Error loading movies cache: $e');
    }
    }

  String _buildSystemPrompt() {

    final Map<String, String> prompts = {
      'vi': '''
        Bạn là trợ lý AI cho ứng dụng đặt vé xem phim. Bạn có thể hỗ trợ khách hàng điều hướng trong app.

        NHỚ DANH SÁCH PHIM HIỆN TẠI NẾU CÓ:
        $_cachedMovies
        NẾU RỖNG HOẶC GẶP LỖI KHI LẤY DỮ LIỆU THÌ HÃY THÔNG BÁO VỚI NGƯỜI DÙNG KHI NGƯỜI DÙNG CÓ CÂU HỎI LIÊN QUAN.

        CÁC TÍNH NĂNG BẠN CÓ THỂ HỖ TRỢ:
        1. Tìm kiếm phim theo tên (không cần chính xác 100%)
        2. Đặt vé cho phim cụ thể
        3. Điều hướng đến các trang khác nhau
        4. Trả lời câu hỏi về phim
        5. Xử lý hình ảnh người dùng gửi - mô tả nội dung và tìm phim liên quan
        5. Đưa ra danh sách phim hiện tại để người dùng chọn

        KHI NGƯỜI CHỌN PHIM:
        - Tìm phim trong danh sách dựa trên tên (sử dụng fuzzy matching)
        - Tạo button điều hướng đến trang đặt vé với movieId

        KHI NGƯỜI DÙNG GỬI HÌNH ẢNH:
        - Mô tả chi tiết nội dung hình ảnh
        - Nếu hình ảnh liên quan đến phim (poster, cảnh phim, diễn viên), tìm phim tương ứng
        - Đề xuất đặt vé nếu tìm thấy phim phù hợp
        - Trả lời câu hỏi về hình ảnh nếu người dùng hỏi

        KHI NGƯỜI DÙNG MUỐN ĐẶT VÉ CHO PHIM:
        - Tìm phim trong danh sách dựa trên tên (sử dụng fuzzy matching)
        - Tạo button điều hướng đến trang đặt vé với movieId
        - Nếu không tìm thấy phim chính xác, đề xuất phim tương tự

        CÁC ROUTE AVAILABLE:
        - /home: Trang chủ
        - /movie_detail: Chi tiết phim (cần movie)
        - /showing_movie_booking: Đặt vé (cần movieId)
        - /seat_booking: Chọn ghế (cần movie + showingMovie)
        - /snack_booking: Chọn đồ ăn
        - /payment: Thanh toán
        - /setting: Cài đặt

        ĐỊNH DẠNG RESPONSE:
        Bạn PHẢI trả về JSON với format:
        {
          "message": "Tin nhắn của bạn",
          "actions": [
            {
              "type": "navigate|api_call|button",
              "label": "Nhãn hiển thị",
              "route": "/route_path",
              "parameters": {"movieId": "id_cua_phim"},
              "apiEndpoint": "/api/endpoint"
            }
          ]
        }

        VÍ DỤ XỬ LÝ ĐẶT VÉ:
        User: "Tôi muốn đặt vé xem Spider-Man"
        Response: {
          "message": "Tôi tìm thấy phim Spider-Man cho bạn! Bạn có muốn xem lịch chiếu không?",
          "actions": [
            {
              "type": "navigate",
              "label": "🎬 Đặt vé Spider-Man",
              "route": "/showing_movie_booking",
              "parameters": {"movieId": "123"}
            }
          ]
        }

        VÍ DỤ XỬ LÝ HÌNH ẢNH:
        User gửi poster phim Spider-Man
        Response: {
          "message": "Tôi thấy đây là poster phim Spider-Man! Đây là một bộ phim siêu anh hùng rất hay. Bạn có muốn đặt vé xem không?",
          "actions": [
            {
              "type": "navigate", 
              "label": "🎬 Đặt vé Spider-Man",
              "route": "/showing_movie_booking",
              "parameters": {"movieId": "123"}
            },
            {
              "type": "navigate",
              "label": "📋 Xem chi tiết phim", 
              "route": "/movie_detail",
              "parameters": {"movieId": "123"}
            }
          ]
        }

        LUÔN trả về JSON hợp lệ và chỉ sử dụng tiếng Việt.
      ''',
    };

    return prompts[_language] ?? prompts['vi']!;
  }

  String _getWelcomeMessage(String customerName) {
    final welcomeResponse = {
      "message": _language == 'vi' 
        ? "Xin chào $customerName! 🎬 Tôi có thể giúp bạn đặt vé xem phim, tìm phim hay, hoặc trả lời câu hỏi về bất kỳ hình ảnh nào bạn gửi. Bạn cần hỗ trợ gì?"
        : "Hello $customerName! 🎬 I can help you book movie tickets, find great movies, or answer questions about any images you send. What do you need help with?",
      "actions": [
        {
          "type": "navigate",
          "label": _language == 'vi' ? "🎬 Xem phim đang chiếu" : "🎬 Browse Movies",
          "route": "/home"
        },
        {
          "type": "button",
          "label": _language == 'vi' ? "🔍 Tìm phim yêu thích" : "🔍 Search Movies",
          "buttonId": "search_movies"
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

  // Tìm phim dựa trên tên (fuzzy search)
  MovieModel? _findMovieByName(String movieName) {
    if (_cachedMovies == null || _cachedMovies!.isEmpty) return null;

    final searchName = movieName.toLowerCase().trim();
    
    // Exact match first
    var movie = _cachedMovies!.firstWhere(
      (movie) => movie.title.toLowerCase() == searchName,
      orElse: () => MovieModel.empty(),
    );
    
    if (movie.movieId != 0) return movie;
    
    // Partial match
    movie = _cachedMovies!.firstWhere(
      (movie) => movie.title.toLowerCase().contains(searchName) ||
                 searchName.contains(movie.title.toLowerCase()),
      orElse: () => MovieModel.empty(),
    );
    
    if (movie.movieId != 0) return movie;
    
    return null;
  }

  // Tìm phim tương tự
  List<MovieModel> _findSimilarMovies(String movieName, {int limit = 3}) {
    if (_cachedMovies == null || _cachedMovies!.isEmpty) return [];

    final searchName = movieName.toLowerCase().trim();
    final similarMovies = <MovieModel>[];
    
    for (final movie in _cachedMovies!) {
      final title = movie.title.toLowerCase();
      
      // Check if any word in search matches any word in title
      final searchWords = searchName.split(' ');
      final titleWords = title.split(' ');
      
      bool hasMatch = false;
      for (final searchWord in searchWords) {
        for (final titleWord in titleWords) {
          if (searchWord.length >= 3 && titleWord.contains(searchWord)) {
            hasMatch = true;
            break;
          }
        }
        if (hasMatch) break;
      }
      
      if (hasMatch) {
        similarMovies.add(movie);
      }
    }
    
    return similarMovies.take(limit).toList();
  }

  Future<AIChatResponse> sendMessage(String message, {File? imageFile}) async {
    if (_chat == null) {
      throw Exception('Chat not initialized. Please start chat with reservation first.');
    }

    try {
      Content content;
      
      if (imageFile != null) {
        // Handle image + text message - FIXED VERSION
        final imageBytes = await imageFile.readAsBytes();
        
        // Create proper image part with mime type detection
        String mimeType = 'image/jpeg'; // default
        final extension = imageFile.path.toLowerCase().split('.').last;
        switch (extension) {
          case 'png':
            mimeType = 'image/png';
            break;
          case 'jpg':
          case 'jpeg':
            mimeType = 'image/jpeg';
            break;
          case 'webp':
            mimeType = 'image/webp';
            break;
        }
        content = Content.inlineData(mimeType, imageBytes);
      } else {
        content = Content.text(message);
      }

      final response = await _chat!.sendMessage(content);
      final responseText = response.text ?? '';
      
      if (responseText.isEmpty) {
        return AIChatResponse(
          message: _language == 'vi' 
            ? 'Xin lỗi, tôi không hiểu câu hỏi của bạn. Vui lòng thử lại.'
            : 'Sorry, I did not understand your question. Please try again.',
        );
      }

      // Try to parse as JSON first with better error handling
      return _parseAIResponse(responseText, message, imageFile != null);
      
    } catch (e) {
      print('Error in sendMessage: $e');
      return AIChatResponse(
        message: _language == 'vi' 
          ? 'Tôi đang gặp một số khó khăn kỹ thuật. Vui lòng thử lại sau một lát.'
          : 'I\'m experiencing some technical difficulties. Please try again in a moment.',
      );
    }
  }

  AIChatResponse _parseAIResponse(String responseText, String originalMessage, bool hasImage) {
    // Try to parse as JSON
    try {
      responseText = responseText.substring(responseText.indexOf('{'), responseText.lastIndexOf('}') + 1);
      final jsonResponse = jsonDecode(responseText);
      return AIChatResponse.fromJson(jsonResponse);
    } catch (e) {
      print('JSON parse error: $e');
      print('Response text: $responseText');

      // If not JSON, handle as text response
      if (hasImage) {
        return _handleImageResponse(responseText, originalMessage);
      } else {
        return _handleTextResponse(responseText, originalMessage);
      }
    }
  }

  AIChatResponse _handleImageResponse(String responseText, String originalMessage) {
    // For image responses, try to extract movie information
    final lowerResponse = responseText.toLowerCase();
    
    // Look for movie names in the response
    if (_cachedMovies != null) {
      for (final movie in _cachedMovies!) {
        if (lowerResponse.contains(movie.title.toLowerCase())) {
          return AIChatResponse(
            message: responseText,
            actions: [
              ChatAction(
                type: 'navigate',
                label: '🎬 Đặt vé ${movie.title}',
                route: '/showing_movie_booking',
                parameters: {'movieId': movie.movieId.toString()},
              ),
              ChatAction(
                type: 'navigate',
                label: '📋 Xem chi tiết phim',
                route: '/movie_detail',
                parameters: {'movieId': movie.movieId.toString()},
              ),
            ],
          );
        }
      }
    }
    
    // Default image response without actions
    return AIChatResponse(message: responseText);
  }

  AIChatResponse _handleTextResponse(String responseText, String originalMessage) {
    // Check if user wants to book a movie
    final lowerMessage = originalMessage.toLowerCase();
    
    if (lowerMessage.contains('đặt vé') || 
        lowerMessage.contains('đặt suất') ||
        lowerMessage.contains('xem phim') ||
        lowerMessage.contains('book') ||
        lowerMessage.contains('ticket')) {
      
      // Extract movie name from message
      final movieName = _extractMovieName(originalMessage);
      if (movieName.isNotEmpty) {
        final movie = _findMovieByName(movieName);
        
        if (movie != null) {
          return AIChatResponse(
            message: 'Tôi tìm thấy phim "${movie.title}" cho bạn! Bạn có muốn xem lịch chiếu và đặt vé không?',
            actions: [
              ChatAction(
                type: 'navigate',
                label: '🎬 Đặt vé ${movie.title}',
                route: '/showing_movie_booking',
                parameters: {'movieId': movie.movieId.toString()},
              ),
              ChatAction(
                type: 'navigate',
                label: '📋 Xem chi tiết phim',
                route: '/movie_detail',
                parameters: {'movieId': movie.movieId.toString()},
              ),
            ],
          );
        } else {
          // Try to find similar movies
          final similarMovies = _findSimilarMovies(movieName);
          if (similarMovies.isNotEmpty) {
            final actions = similarMovies.map((movie) => ChatAction(
              type: 'navigate',
              label: '🎬 ${movie.title}',
              route: '/showing_movie_booking',
              parameters: {'movieId': movie.movieId.toString()},
            )).toList();
            
            return AIChatResponse(
              message: 'Tôi không tìm thấy phim "$movieName" chính xác, nhưng có những phim tương tự:',
              actions: actions,
            );
          }
        }
      }
    }
    
    // Default response
    return AIChatResponse(message: responseText);
  }

  String _extractMovieName(String message) {
    // Simple extraction - can be improved with better NLP
    final lowerMessage = message.toLowerCase();
    
    // Remove common booking phrases
    final cleanMessage = lowerMessage
        .replaceAll('tôi muốn đặt vé xem', '')
        .replaceAll('tôi muốn đặt vé cho', '')
        .replaceAll('đặt vé xem', '')
        .replaceAll('đặt vé cho', '')
        .replaceAll('đặt suất chiếu cho', '')
        .replaceAll('xem phim', '')
        .replaceAll('phim', '')
        .trim();
    
    // If there are quotes, extract content between them
    final quoteMatch = RegExp(r'"([^"]*)"').firstMatch(cleanMessage);
    if (quoteMatch != null) {
      return quoteMatch.group(1) ?? '';
    }
    
    return cleanMessage;
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
    switch (action.buttonId) {
      case 'search_movies':
        if (_cachedMovies != null && _cachedMovies!.isNotEmpty) {
          final randomMovies = (_cachedMovies!..shuffle()).take(5).toList();
          final actions = randomMovies.map((movie) => ChatAction(
            type: 'navigate',
            label: '🎬 ${movie.title}',
            route: '/showing_movie_booking',
            parameters: {'movieId': movie.movieId.toString()},
          )).toList();
          
          return AIChatResponse(
            message: 'Đây là một số phim hay bạn có thể quan tâm:',
            actions: actions,
          );
        }
        break;
    }
    
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

  UserModel? getCurrentUser() {
    return _currentUser;
  }

  void resetChat() {
    _chat = null;
    _currentUser = null;
    _cachedMovies = null;
  }

  bool get isChatActive => _chat != null;
}