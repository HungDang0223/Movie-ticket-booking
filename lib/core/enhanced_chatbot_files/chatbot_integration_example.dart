import 'package:flutter/material.dart';
import 'package:movie_tickets/features/authentication/data/models/user_model.dart';
import 'package:movie_tickets/core/services/networking/ai_chatbot_service.dart';
import 'enhanced_chat_screen.dart';
import 'enhanced_ai_chatbot_service.dart';

/// Example 1: Basic Integration
/// Replace your existing ChatScreen with EnhancedChatScreen
class BasicIntegrationExample extends StatelessWidget {
  final UserModel user;

  const BasicIntegrationExample({Key? key, required this.user}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return EnhancedChatScreen(
      user: user,
      initialMessage: "Xin chào! Tôi muốn xem phim.",
    );
  }
}

/// Example 2: Custom Action Handling
/// Handle specific actions in your own navigation system
class CustomActionHandlingExample extends StatelessWidget {
  final UserModel user;

  const CustomActionHandlingExample({Key? key, required this.user}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return EnhancedChatScreen(
      user: user,
      onActionTap: (ChatAction action) {
        _handleCustomAction(context, action);
      },
    );
  }

  void _handleCustomAction(BuildContext context, ChatAction action) {
    switch (action.type) {
      case 'show_movies':
        // Navigate to your custom movies page
        Navigator.pushNamed(context, '/movies');
        break;
      case 'show_showtimes':
        // Navigate to showtimes with movie ID
        final movieId = action.parameters?['movieId'];
        Navigator.pushNamed(context, '/showtimes', arguments: {'movieId': movieId});
        break;
      case 'show_seats':
        // Navigate to seat selection
        final showingId = action.parameters?['showingId'];
        Navigator.pushNamed(context, '/seat_booking', arguments: {'showingId': showingId});
        break;
      case 'show_cinemas':
        // Navigate to cinemas list
        Navigator.pushNamed(context, '/cinemas');
        break;
      case 'navigate':
        // Handle standard navigation
        Navigator.pushNamed(context, action.route!, arguments: action.parameters);
        break;
      default:
        // Handle unknown actions
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Action not supported: ${action.type}')),
        );
    }
  }
}

/// Example 3: Programmatic Service Usage
/// Use the service directly without UI
class ProgrammaticServiceExample {
  final EnhancedAIChatbotService _chatService = EnhancedAIChatbotService();
  final UserModel user;

  ProgrammaticServiceExample(this.user);

  Future<void> initializeAndChat() async {
    // Initialize the service
    _chatService.initialize(language: 'vi');
    await _chatService.startChatWithReservation(user);

    // Send a message
    final response = await _chatService.sendMessage("Có phim gì đang chiếu?");
    print('Bot response: ${response.message}');

    // Handle actions if any
    if (response.actions != null && response.actions!.isNotEmpty) {
      for (final action in response.actions!) {
        print('Available action: ${action.label} (${action.type})');

        // Execute an action
        if (action.type == 'show_movies') {
          final actionResponse = await _chatService.executeAction(action);
          print('Action response: ${actionResponse.message}');
        }
      }
    }
  }

  Future<void> searchForSpecificMovie(String movieName) async {
    final response = await _chatService.sendMessage("Tìm phim $movieName");
    print('Search response: ${response.message}');
  }

  Future<void> checkSeatAvailability(int showingId) async {
    final action = ChatAction(
      type: 'show_seats',
      label: 'Check seats',
      parameters: {'showingId': showingId},
    );

    final response = await _chatService.executeAction(action);
    print('Seat availability: ${response.message}');
  }
}

/// Example 4: Custom Chat Widget
/// Create your own chat interface using the service
class CustomChatWidget extends StatefulWidget {
  final UserModel user;

  const CustomChatWidget({Key? key, required this.user}) : super(key: key);

  @override
  State<CustomChatWidget> createState() => _CustomChatWidgetState();
}

class _CustomChatWidgetState extends State<CustomChatWidget> {
  final EnhancedAIChatbotService _chatService = EnhancedAIChatbotService();
  final TextEditingController _controller = TextEditingController();
  final List<String> _messages = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _initializeChat();
  }

  Future<void> _initializeChat() async {
    _chatService.initialize(language: 'vi');
    await _chatService.startChatWithReservation(widget.user);
  }

  Future<void> _sendMessage(String message) async {
    if (message.trim().isEmpty) return;

    setState(() {
      _messages.add('You: $message');
      _isLoading = true;
    });

    _controller.clear();

    try {
      final response = await _chatService.sendMessage(message);
      setState(() {
        _messages.add('Bot: ${response.message}');
        _isLoading = false;
      });

      // Handle actions
      if (response.actions != null) {
        for (final action in response.actions!) {
          setState(() {
            _messages.add('Action: ${action.label}');
          });
        }
      }
    } catch (e) {
      setState(() {
        _messages.add('Error: $e');
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Custom Chat')),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(_messages[index]),
                );
              },
            ),
          ),
          if (_isLoading) const LinearProgressIndicator(),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      hintText: 'Type a message...',
                    ),
                    onSubmitted: _sendMessage,
                  ),
                ),
                IconButton(
                  onPressed: () => _sendMessage(_controller.text),
                  icon: const Icon(Icons.send),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

/// Example 5: Error Handling and Retry Logic
class RobustChatExample extends StatefulWidget {
  final UserModel user;

  const RobustChatExample({Key? key, required this.user}) : super(key: key);

  @override
  State<RobustChatExample> createState() => _RobustChatExampleState();
}

class _RobustChatExampleState extends State<RobustChatExample> {
  final EnhancedAIChatbotService _chatService = EnhancedAIChatbotService();
  int _retryCount = 0;
  static const int maxRetries = 3;

  Future<AIChatResponse?> _sendMessageWithRetry(String message) async {
    for (int attempt = 0; attempt < maxRetries; attempt++) {
      try {
        final response = await _chatService.sendMessage(message);
        _retryCount = 0; // Reset on success
        return response;
      } catch (e) {
        _retryCount++;
        print('Attempt ${attempt + 1} failed: $e');

        if (attempt == maxRetries - 1) {
          // Last attempt failed
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to send message after $maxRetries attempts'),
              action: SnackBarAction(
                label: 'Retry',
                onPressed: () => _sendMessageWithRetry(message),
              ),
            ),
          );
          return null;
        }

        // Wait before retry
        await Future.delayed(Duration(seconds: attempt + 1));
      }
    }
    return null;
  }

  Future<void> _refreshChatService() async {
    try {
      await _chatService.refreshEnhancedCache();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Chat service refreshed successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to refresh: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Robust Chat'),
        actions: [
          IconButton(
            onPressed: _refreshChatService,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: EnhancedChatScreen(
        user: widget.user,
        onActionTap: (action) async {
          try {
            final response = await _chatService.executeAction(action);
            // Handle response
            print('Action executed: ${response.message}');
          } catch (e) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Action failed: $e')),
            );
          }
        },
      ),
    );
  }
}

/// Example 6: Testing Helper
class ChatbotTestHelper {
  static Future<void> testBasicFunctionality() async {
    final service = EnhancedAIChatbotService();
    final user = UserModel(
      userId: "1",
        fullName: 'Test User',
        email: 'test@example.com',
        phoneNumber: '1234567890', 
        dateOfBirth: DateTime.now(),
        address: 'Test Address',
        rankId: 1,
        totalPaid: 0,
        totalPoints: 0,
    );

    try {
      // Test initialization
      service.initialize(language: 'vi');
      await service.startChatWithReservation(user);
      print('✅ Service initialized successfully');

      // Test basic message
      final response1 = await service.sendMessage("Xin chào");
      print('✅ Basic message: ${response1.message}');

      // Test movie query
      final response2 = await service.sendMessage("Có phim gì đang chiếu?");
      print('✅ Movie query: ${response2.message}');
      print('✅ Actions count: ${response2.actions?.length ?? 0}');

      // Test action execution
      if (response2.actions != null && response2.actions!.isNotEmpty) {
        final actionResponse = await service.executeAction(response2.actions!.first);
        print('✅ Action executed: ${actionResponse.message}');
      }

      print('🎉 All tests passed!');
    } catch (e) {
      print('❌ Test failed: $e');
    }
  }
}

/// Usage Examples:
///
/// 1. Replace existing chat screen:
/// ```dart
/// Navigator.push(context, MaterialPageRoute(
///   builder: (context) => BasicIntegrationExample(user: currentUser),
/// ));
/// ```
///
/// 2. Use with custom action handling:
/// ```dart
/// Navigator.push(context, MaterialPageRoute(
///   builder: (context) => CustomActionHandlingExample(user: currentUser),
/// ));
/// ```
///
/// 3. Use service programmatically:
/// ```dart
/// final chatExample = ProgrammaticServiceExample(currentUser);
/// await chatExample.initializeAndChat();
/// ```
///
/// 4. Run tests:
/// ```dart
/// await ChatbotTestHelper.testBasicFunctionality();
/// ```
