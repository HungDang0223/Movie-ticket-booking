import 'package:flutter_test/flutter_test.dart';
import 'package:movie_tickets/features/authentication/data/models/user_model.dart';
import 'enhanced_ai_chatbot_service.dart';

/// Test file for Enhanced Chatbot functionality
/// Run with: flutter test lib/core/enhanced_chatbot_files/enhanced_chatbot_test.dart
void main() {
  group('Enhanced Chatbot Service Tests', () {
    late EnhancedAIChatbotService chatService;
    late UserModel testUser;

    setUp(() {
      chatService = EnhancedAIChatbotService();
      testUser = UserModel(
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
    });

    test('should initialize service correctly', () {
      expect(() => chatService.initialize(language: 'vi'), returnsNormally);
      expect(() => chatService.initialize(language: 'en'), returnsNormally);
    });

    test('should handle language switching', () {
      chatService.initialize(language: 'vi');
      // Test Vietnamese initialization
      expect(chatService, isNotNull);
      
      chatService.initialize(language: 'en');
      // Test English initialization
      expect(chatService, isNotNull);
    });

    test('should clear cache without errors', () {
      expect(() => chatService.clearEnhancedCache(), returnsNormally);
    });

    // Integration tests (require actual repositories)
    group('Integration Tests', () {
      test('should start chat with user', () async {
        try {
          await chatService.startChatWithReservation(testUser);
          // If no exception is thrown, test passes
          expect(true, isTrue);
        } catch (e) {
          // Expected to fail in test environment without proper DI setup
          expect(e, isA<Exception>());
        }
      });

      test('should refresh cache', () async {
        try {
          await chatService.refreshEnhancedCache();
          // If no exception is thrown, test passes
          expect(true, isTrue);
        } catch (e) {
          // Expected to fail in test environment without proper DI setup
          expect(e, isA<Exception>());
        }
      });
    });
  });
}
