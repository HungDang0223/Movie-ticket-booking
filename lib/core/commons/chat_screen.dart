import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:http/http.dart' as http;
import 'package:movie_tickets/core/constants/app_color.dart';
import 'package:movie_tickets/core/constants/strings.dart';
import 'dart:convert';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

import 'package:movie_tickets/core/services/networking/ai_chatbot_service.dart';
import 'package:movie_tickets/features/authentication/data/models/user_model.dart';
import 'package:movie_tickets/features/booking/data/models/models.dart';
import 'package:movie_tickets/features/booking/domain/repositories/showing_movie_repository.dart';
import 'package:movie_tickets/features/movies/data/repositories/movie_repository_impl.dart';
import 'package:movie_tickets/features/movies/domain/repositories/movie_repository.dart';
import 'package:movie_tickets/injection.dart';

class ChatScreen extends StatefulWidget {
  final UserModel user;

  const ChatScreen({
    Key? key,
    required this.user,
  }) : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final AIChatbotService _chatService = AIChatbotService();
  final TextEditingController _messageController = TextEditingController();
  final List<ChatMessage> _messages = [];
  final ImagePicker _imagePicker = ImagePicker();
  bool _isLoading = false;
  File? _selectedImage;
  final MovieRepository _movieRepository = sl<MovieRepository>();
  final ShowingMovieRepository _showingMovieRepository = sl<ShowingMovieRepository>();

  @override
  void initState() {
    super.initState();
    _initializeChat();
  }

  Future<void> _initializeChat() async {
    _chatService.initialize(language: 'vi');
    
    await _chatService.startChatWithReservation(widget.user);
    // Thêm welcome message
    final welcomeResponse = await _chatService.sendMessage("Xin chào!");
    setState(() {
      _messages.add(ChatMessage(
        text: welcomeResponse.message,
        isUser: false,
        actions: welcomeResponse.actions,
        timestamp: DateTime.now(),
      ));
    });
    }

  Future<void> _sendMessage(String message, {File? imageFile}) async {
    if (message.trim().isEmpty && imageFile == null) return;

    setState(() {
      _messages.add(ChatMessage(
        text: message.isEmpty ? "📷 Đã gửi hình ảnh" : message,
        isUser: true,
        timestamp: DateTime.now(),
        imageFile: imageFile,
      ));
      _isLoading = true;
      _selectedImage = null; // Clear selected image
    });

    _messageController.clear();

    try {
      final response = await _chatService.sendMessage(message, imageFile: imageFile);
      
      setState(() {
        _messages.add(ChatMessage(
          text: response.message,
          isUser: false,
          actions: response.actions,
          timestamp: DateTime.now(),
        ));
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _messages.add(ChatMessage(
          text: 'Xin lỗi, tôi gặp lỗi khi xử lý tin nhắn của bạn.',
          isUser: false,
          timestamp: DateTime.now(),
        ));
        _isLoading = false;
      });
    }
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 80,
      );
      
      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
        });
      }
    } catch (e) {
      _showErrorSnackBar('Lỗi khi chọn hình ảnh: $e');
    }
  }

  Future<void> _takePhoto() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 80,
      );
      
      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
        });
      }
    } catch (e) {
      _showErrorSnackBar('Lỗi khi chụp ảnh: $e');
    }
  }

  void _showImagePickerDialog() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Chọn từ thư viện'),
                onTap: () {
                  Navigator.of(context).pop();
                  _pickImage();
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_camera),
                title: const Text('Chụp ảnh'),
                onTap: () {
                  Navigator.of(context).pop();
                  _takePhoto();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _executeAction(ChatAction action) async {
    setState(() {
      _isLoading = true;
    });

    try {
      switch (action.type) {
        case 'navigate':
          await _handleNavigation(action);
          break;
        case 'api_call':
          await _handleApiCall(action);
          break;
        case 'button':
          await _handleButtonAction(action);
          break;
        case 'show_showtimes':
          await _handleShowShowtimes(action);
          break;
      }
    } catch (e) {
      _showErrorSnackBar('Lỗi khi thực hiện action: $e');
    }

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _handleShowShowtimes(ChatAction action) async {
    final movieId = action.parameters?['movieId'];
    if (movieId == null) return;

    // Gọi API để lấy suất chiếu
    try {
      final response = await http.get(
        Uri.parse('$baseURL/api/showing-movies/$movieId'),
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final showtimes = data['showtimes'] as List<dynamic>?;
        
        if (showtimes != null && showtimes.isNotEmpty) {
          // Tạo actions cho các suất chiếu
          final showtimeActions = showtimes.take(5).map<ChatAction>((showtime) {
            return ChatAction(
              type: 'navigate',
              label: '🎬 ${showtime['time']} - ${showtime['cinema']}',
              route: '/seat_booking',
              parameters: {
                'movieId': movieId,
                'showingId': showtime['id'].toString(),
                'showtime': showtime['time'],
                'cinema': showtime['cinema'],
              },
            );
          }).toList();
          
          setState(() {
            _messages.add(ChatMessage(
              text: 'Đây là các suất chiếu có sẵn:',
              isUser: false,
              actions: showtimeActions,
              timestamp: DateTime.now(),
            ));
          });
        } else {
          setState(() {
            _messages.add(ChatMessage(
              text: 'Hiện tại chưa có suất chiếu nào cho phim này.',
              isUser: false,
              timestamp: DateTime.now(),
            ));
          });
        }
      }
    } catch (e) {
      _showErrorSnackBar('Lỗi khi tải suất chiếu: $e');
    }
  }

  Future<void> _handleNavigation(ChatAction action) async {
    final route = action.route;
    final parameters = action.parameters;

    dynamic arguments;
    
    switch (route) {
      case '/movie_detail':
        if (parameters?['movieId'] != null) {
          // Load movie data từ API
          final movieData = await _loadMovieData(int.parse(parameters!['movieId']!));
          arguments = movieData;
        }
        break;
      
      case '/showing_movie_booking':
        if (parameters?['movieId'] != null) {
          final movieData = await _loadMovieData(int.parse(parameters!['movieId']!));
          arguments = movieData;
        }
        break;
      
      case '/seat_booking':
        if (parameters != null) {
          arguments = {
            'movie': await _loadMovieData(int.parse(parameters['movieId']!)),
            'showingMovie': await _loadShowingData(int.parse(parameters['showingId']!)),
            'websocketUrl': parameters['websocketUrl'] ?? 'ws://localhost:5000/ws/seat-reservation',
            'userId': widget.user.userId,
          };
        }
        break;
      
      case '/snack_booking':
      case '/payment':
        arguments = parameters;
        break;
    }

    // Navigate
    if (mounted) {
      print("Arguments: $arguments");
      print("Route: $route");
      Navigator.of(context).pushNamed(route, arguments: arguments);
    }
  }

  Future<void> _handleApiCall(ChatAction action) async {
    try {
      final endpoint = action.apiEndpoint;
      final response = await http.get(Uri.parse('$baseURL$endpoint'));
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        // Process API response and show results
        String resultMessage = 'Đã tải dữ liệu thành công!';
        List<ChatAction>? resultActions;

        if (endpoint?.contains('/movies') == true) {
          resultMessage = 'Tìm thấy ${data['movies']?.length ?? 0} phim:';
          resultActions = _createMovieActions(data['movies']);
        }

        setState(() {
          _messages.add(ChatMessage(
            text: resultMessage,
            isUser: false,
            actions: resultActions,
            timestamp: DateTime.now(),
          ));
        });
      }
    } catch (e) {
      _showErrorSnackBar('Lỗi khi gọi API: $e');
    }
  }

  List<ChatAction> _createMovieActions(List<dynamic>? movies) {
    if (movies == null) return [];
    
    return movies.take(5).map<ChatAction>((movie) {
      return ChatAction(
        type: 'navigate',
        label: '🎬 ${movie['title']}',
        route: '/movie_detail',
        parameters: {'movieId': movie['id']},
      );
    }).toList();
  }

  Future<void> _handleButtonAction(ChatAction action) async {
    // Handle custom button actions
    setState(() {
      _messages.add(ChatMessage(
        text: 'Đã thực hiện: ${action.label}',
        isUser: false,
        timestamp: DateTime.now(),
      ));
    });
  }

  // Mock API calls - thay thế bằng actual API calls
  Future<dynamic> _loadMovieData(int movieId) async {
     final response = await _movieRepository.getMovieDetail(movieId);
     if (response.isSuccess) {
       return response.data;
     } else {
       throw Exception('Lỗi khi tải dữ liệu phim: ${response.failure!.message}');
     }
  }

  Future<dynamic> _loadShowingData(int showingId) async {
    final response = await _showingMovieRepository.getShowingMovies(showingId, DateTime.now());
    if (response.isSuccess) {
      return response.data;
    } else {
      throw Exception('Lỗi khi tải dữ liệu suất chiếu: ${response.failure!.message}');
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Movie Bot 🤖'),
        backgroundColor: AppColor.DEFAULT_2,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                return _buildMessageBubble(message);
              },
            ),
          ),
          if (_isLoading)
            Padding(
              padding: EdgeInsets.all(8),
              child: Row(
                children: [
                  SizedBox(width: 16),
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: SvgPicture.asset(
                      'assets/icons/typing.svg',
                    ),
                  ),
                ],
              ),
            ),
          if (_selectedImage != null) _buildSelectedImagePreview(),
          _buildInputArea(),
        ],
      ),
    );
  }

  Widget _buildSelectedImagePreview() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: Image.file(
              _selectedImage!,
              width: 60,
              height: 60,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 8),
          const Expanded(
            child: Text('Hình ảnh đã chọn'),
          ),
          IconButton(
            onPressed: () {
              setState(() {
                _selectedImage = null;
              });
            },
            icon: const Icon(Icons.close),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage message) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: message.isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!message.isUser) ...[
            const CircleAvatar(
              radius: 16,
              backgroundColor: AppColor.DEFAULT,
              child: Icon(Icons.smart_toy, color: Colors.white, size: 16),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Column(
              crossAxisAlignment: message.isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: message.isUser ? AppColor.DEFAULT : Colors.grey[200],
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (message.imageFile != null) ...[
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.file(
                            message.imageFile!,
                            width: 200,
                            fit: BoxFit.cover,
                          ),
                        ),
                        if (message.text.isNotEmpty) const SizedBox(height: 8),
                      ],
                      if (message.text.isNotEmpty)
                        Text(
                          message.text,
                          style: TextStyle(
                            color: message.isUser ? Colors.white : Colors.black87,
                          ),
                        ),
                    ],
                  ),
                ),
                if (message.actions != null && message.actions!.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    children: message.actions!.map((action) {
                      return ElevatedButton.icon(
                        onPressed: () => _executeAction(action),
                        icon: _getActionIcon(action.type),
                        label: Text(action.label),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _getActionColor(action.type),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ],
            ),
          ),
          if (message.isUser) ...[
            const SizedBox(width: 8),
            const CircleAvatar(
              radius: 16,
              backgroundColor: Colors.blue,
              child: Icon(Icons.person, color: Colors.white, size: 16),
            ),
          ],
        ],
      ),
    );
  }

  Icon _getActionIcon(String type) {
    switch (type) {
      case 'navigate':
        return const Icon(Icons.arrow_forward, size: 16);
      case 'api_call':
        return const Icon(Icons.download, size: 16);
      case 'button':
        return const Icon(Icons.touch_app, size: 16);
      case 'show_showtimes':
        return const Icon(Icons.schedule, size: 16);
      default:
        return const Icon(Icons.help, size: 16);
    }
  }

  Color _getActionColor(String type) {
    switch (type) {
      case 'navigate':
        return Colors.green;
      case 'api_call':
        return Colors.blue;
      case 'button':
        return Colors.orange;
      case 'show_showtimes':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            offset: Offset(0, -2),
            blurRadius: 4,
            color: Colors.black12,
          ),
        ],
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: _showImagePickerDialog,
            icon: const Icon(Icons.image),
            color: AppColor.DEFAULT,
          ),
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: InputDecoration(
                hintText: 'Nhập tin nhắn...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey[100],
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              onSubmitted: (text) => _sendMessage(text, imageFile: _selectedImage),
            ),
          ),
          const SizedBox(width: 8),
          FloatingActionButton(
            mini: true,
            onPressed: () => _sendMessage(_messageController.text, imageFile: _selectedImage),
            backgroundColor: AppColor.DEFAULT,
            child: const Icon(Icons.send, color: Colors.white),
          ),
        ],
      ),
    );
  }
}

class ChatMessage {
  final String text;
  final bool isUser;
  final List<ChatAction>? actions;
  final DateTime timestamp;
  final File? imageFile;

  ChatMessage({
    required this.text,
    required this.isUser,
    this.actions,
    required this.timestamp,
    this.imageFile,
  });
  
  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      text: json['text'],
      isUser: json['isUser'],
      actions: (json['actions'] as List<dynamic>?)
          ?.map((action) => ChatAction.fromJson(action))
          .toList(),
      timestamp: DateTime.parse(json['timestamp']),
      // Note: imageFile không được serialize
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'text': text,
      'isUser': isUser,
      'actions': actions?.map((action) => action.toJson()).toList(),
      'timestamp': timestamp.toIso8601String(),
      // Note: imageFile không được serialize
    };
  }
}