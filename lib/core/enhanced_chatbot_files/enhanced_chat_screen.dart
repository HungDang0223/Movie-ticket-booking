import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:movie_tickets/core/constants/app_color.dart';
import 'package:movie_tickets/core/services/networking/ai_chatbot_service.dart';
import 'package:movie_tickets/features/authentication/data/models/user_model.dart';
import 'enhanced_ai_chatbot_service.dart';

class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;
  final List<ChatAction>? actions;
  final File? imageFile;
  final Map<String, dynamic>? metadata;

  ChatMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
    this.actions,
    this.imageFile,
    this.metadata,
  });
}

class EnhancedChatScreen extends StatefulWidget {
  final UserModel user;
  final String? initialMessage;
  final Function(ChatAction)? onActionTap;

  const EnhancedChatScreen({
    super.key,
    required this.user,
    this.initialMessage,
    this.onActionTap,
  });

  @override
  State<EnhancedChatScreen> createState() => _EnhancedChatScreenState();
}

class _EnhancedChatScreenState extends State<EnhancedChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final List<ChatMessage> _messages = [];
  final EnhancedAIChatbotService _chatService = EnhancedAIChatbotService();
  final ImagePicker _imagePicker = ImagePicker();

  bool _isLoading = false;
  File? _selectedImage;

  @override
  void initState() {
    super.initState();
    _initializeChat();
  }

  Future<void> _initializeChat() async {
    _chatService.initialize(language: 'vi');

    await _chatService.startChatWithReservation(widget.user);

    // Send initial message if provided
    final initialMsg = widget.initialMessage ?? "Xin chào!";
    final welcomeResponse = await _chatService.sendMessage(initialMsg);

    setState(() {
      _messages.add(ChatMessage(
        text: welcomeResponse.message,
        isUser: false,
        actions: welcomeResponse.actions,
        timestamp: DateTime.now(),
        metadata: welcomeResponse.metadata,
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
      _selectedImage = null;
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
          metadata: response.metadata,
        ));
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _messages.add(ChatMessage(
          text: 'Xin lỗi, có lỗi xảy ra. Vui lòng thử lại.',
          isUser: false,
          timestamp: DateTime.now(),
        ));
        _isLoading = false;
      });
    }
  }

  Future<void> _handleActionTap(ChatAction action) async {
    // Call external handler if provided
    if (widget.onActionTap != null) {
      widget.onActionTap!(action);
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await _chatService.executeAction(action);

      setState(() {
        _messages.add(ChatMessage(
          text: response.message,
          isUser: false,
          actions: response.actions,
          timestamp: DateTime.now(),
          metadata: response.metadata,
        ));
        _isLoading = false;
      });

      // Handle navigation if needed
      if (response.metadata?['navigation'] != null) {
        _handleNavigation(response.metadata!['navigation']);
      }
    } catch (e) {
      setState(() {
        _messages.add(ChatMessage(
          text: 'Có lỗi xảy ra khi thực hiện hành động.',
          isUser: false,
          timestamp: DateTime.now(),
        ));
        _isLoading = false;
      });
    }
  }

  void _handleNavigation(Map<String, dynamic> navigationData) {
    final route = navigationData['route'] as String?;
    final parameters = navigationData['parameters'] as Map<String, dynamic>?;

    if (route != null) {
      // Navigate using your app's navigation system
      Navigator.pushNamed(context, route, arguments: parameters);
    }
  }

  Future<void> _showImagePickerDialog() async {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Chọn từ thư viện'),
                onTap: () async {
                  Navigator.pop(context);
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
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_camera),
                title: const Text('Chụp ảnh'),
                onTap: () async {
                  Navigator.pop(context);
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
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSelectedImagePreview() {
    return Container(
      margin: const EdgeInsets.all(8),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: Image.file(
              _selectedImage!,
              width: 50,
              height: 50,
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: AppColor.DEFAULT,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(
                Icons.smart_toy,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 8),
            const Text(
              'TICBOT Enhanced',
              style: TextStyle(color: AppColor.DEFAULT_2),
            ),
          ],
        ),
        backgroundColor: AppColor.WHITE,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: () async {
              await _chatService.refreshEnhancedCache();
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Đã cập nhật dữ liệu mới')),
                );
              }
            },
            icon: const Icon(Icons.refresh, color: AppColor.DEFAULT),
          ),
        ],
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
          if (_isLoading) _buildLoadingIndicator(),
          if (_selectedImage != null) _buildSelectedImagePreview(),
          _buildInputArea(),
        ],
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Row(
        children: [
          const SizedBox(width: 16),
          const SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
          const SizedBox(width: 8),
          const Text(
            'TICBOT đang suy nghĩ...',
            style: TextStyle(
              color: Colors.grey,
              fontStyle: FontStyle.italic,
            ),
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
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: AppColor.DEFAULT,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(
                Icons.smart_toy,
                color: Colors.white,
                size: 16,
              ),
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
                  _buildActionButtons(message.actions!),
                ],
                const SizedBox(height: 4),
                Text(
                  _formatTimestamp(message.timestamp),
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          if (message.isUser) ...[
            const SizedBox(width: 8),
            CircleAvatar(
              radius: 16,
              backgroundColor: AppColor.DEFAULT_2,
              child: Text(
                widget.user.fullName.isNotEmpty ? widget.user.fullName[0].toUpperCase() : 'U',
                style: const TextStyle(color: Colors.white, fontSize: 14),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildActionButtons(List<ChatAction> actions) {
    return Wrap(
      spacing: 8,
      runSpacing: 4,
      children: actions.map((action) {
        return ElevatedButton.icon(
          onPressed: () => _handleActionTap(action),
          icon: _getActionIcon(action.type),
          label: Text(
            action.label,
            style: const TextStyle(fontSize: 12),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: _getActionColor(action.type),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
        );
      }).toList(),
    );
  }

  Icon _getActionIcon(String actionType) {
    switch (actionType) {
      case 'show_movies':
        return const Icon(Icons.movie, size: 16);
      case 'show_showtimes':
        return const Icon(Icons.schedule, size: 16);
      case 'show_seats':
        return const Icon(Icons.event_seat, size: 16);
      case 'show_cinemas':
        return const Icon(Icons.location_city, size: 16);
      case 'navigate':
        return const Icon(Icons.arrow_forward, size: 16);
      case 'api_call':
        return const Icon(Icons.refresh, size: 16);
      default:
        return const Icon(Icons.touch_app, size: 16);
    }
  }

  Color _getActionColor(String actionType) {
    switch (actionType) {
      case 'show_movies':
        return Colors.purple;
      case 'show_showtimes':
        return Colors.blue;
      case 'show_seats':
        return Colors.green;
      case 'show_cinemas':
        return Colors.orange;
      case 'navigate':
        return AppColor.DEFAULT;
      case 'api_call':
        return Colors.grey;
      default:
        return AppColor.DEFAULT_2;
    }
  }

  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, -1),
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
            onPressed: () => _sendMessage(_messageController.text, imageFile: _selectedImage),
            backgroundColor: AppColor.DEFAULT,
            mini: true,
            child: const Icon(Icons.send, color: Colors.white),
          ),
        ],
      ),
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return 'Vừa xong';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes} phút trước';
    } else if (difference.inDays < 1) {
      return '${difference.inHours} giờ trước';
    } else {
      return '${timestamp.day}/${timestamp.month}';
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }
}
