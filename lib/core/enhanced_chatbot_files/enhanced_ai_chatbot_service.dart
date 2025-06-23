import 'package:movie_tickets/core/services/networking/ai_chatbot_service.dart';
import 'package:movie_tickets/features/authentication/data/models/user_model.dart';
import 'package:movie_tickets/features/booking/domain/repositories/showing_movie_repository.dart';
import 'package:movie_tickets/features/booking/domain/repositories/booking_seat_repository.dart';
import 'package:movie_tickets/features/cinema/domain/repositories/cinema_repository.dart';
import 'package:movie_tickets/injection.dart';
import 'chatbot_utils.dart';

class EnhancedAIChatbotService extends AIChatbotService {
  // Additional repositories for enhanced functionality
  final ShowingMovieRepository showingMovieRepository = sl<ShowingMovieRepository>();
  final BookingSeatRepository bookingSeatRepository = sl<BookingSeatRepository>();
  final CinemaRepository cinemaRepository = sl<CinemaRepository>();

  // Cache for enhanced data
  List<dynamic>? _cachedCinemas;

  // Local language tracking since parent's _language is private
  String _currentLanguage = 'vi';

  @override
  void initialize({String language = 'vi'}) {
    _currentLanguage = language;
    super.initialize(language: language);
    _loadEnhancedCache();
  }

  Future<void> _loadEnhancedCache() async {
    try {
      // Load cinemas cache
      final cinemaResult = await cinemaRepository.getCinemas();
      if (cinemaResult.isSuccess && cinemaResult.data != null) {
        _cachedCinemas = cinemaResult.data!.cinemasByCity.values.expand((cinemaList) => cinemaList).toList();
      }
    } catch (e) {
      print('Error loading enhanced cache: $e');
    }
  }

  @override
  Future<void> startChatWithReservation(UserModel? user) async {
    await super.startChatWithReservation(user);
    // Additional initialization if needed
    await _loadEnhancedCache();
  }

  @override
  Future<AIChatResponse> executeAction(ChatAction action, {Map<String, dynamic>? additionalData}) async {
    switch (action.type) {
      case 'show_movies':
        return await _handleShowMovies(action);
      case 'show_showtimes':
        return await _handleShowShowtimes(action);
      case 'show_seats':
        return await _handleShowSeats(action);
      case 'show_cinemas':
        return await _handleShowCinemas(action);
      default:
        return await super.executeAction(action, additionalData: additionalData);
    }
  }

  Future<AIChatResponse> _handleShowMovies(ChatAction action) async {
    try {
      final result = await movieRepository.getListShowingMovies();
      if (result.isSuccess && result.data != null) {
        final movies = result.data!;

        final message = ChatbotUtils.formatMoviesMessage(movies, _currentLanguage);
        final actions = ChatbotUtils.createMovieActions(movies, _currentLanguage);

        return AIChatResponse(
          message: message,
          actions: actions,
        );
      } else {
        return AIChatResponse(
          message: _currentLanguage == 'vi'
            ? 'Không thể tải danh sách phim. Vui lòng thử lại sau.'
            : 'Unable to load movie list. Please try again later.',
        );
      }
    } catch (e) {
      return AIChatResponse(
        message: _currentLanguage == 'vi'
          ? 'Có lỗi xảy ra khi tải danh sách phim.'
          : 'An error occurred while loading the movie list.',
      );
    }
  }

  Future<AIChatResponse> _handleShowShowtimes(ChatAction action) async {
    try {
      final movieId = action.parameters?['movieId'];
      if (movieId == null) {
        return AIChatResponse(
          message: _currentLanguage == 'vi'
            ? 'Không tìm thấy thông tin phim.'
            : 'Movie information not found.',
        );
      }

      final date = DateTime.now();
      final result = await showingMovieRepository.getShowingMoviesByMovieId(movieId, date);

      if (result.isSuccess && result.data != null) {
        final showings = result.data!;

        final message = ChatbotUtils.formatShowtimesMessage(showings, _currentLanguage);
        final actions = ChatbotUtils.createShowtimeActions(showings, _currentLanguage);

        return AIChatResponse(
          message: message,
          actions: actions,
        );
      } else {
        return AIChatResponse(
          message: _currentLanguage == 'vi'
            ? 'Không có suất chiếu nào cho phim này hôm nay.'
            : 'No showtimes available for this movie today.',
        );
      }
    } catch (e) {
      return AIChatResponse(
        message: _currentLanguage == 'vi'
          ? 'Có lỗi xảy ra khi tải suất chiếu.'
          : 'An error occurred while loading showtimes.',
      );
    }
  }

  Future<AIChatResponse> _handleShowSeats(ChatAction action) async {
    try {
      final showingId = action.parameters?['showingId'];
      if (showingId == null) {
        return AIChatResponse(
          message: _currentLanguage == 'vi'
            ? 'Không tìm thấy thông tin suất chiếu.'
            : 'Showtime information not found.',
        );
      }

      final seatStatuses = await bookingSeatRepository.getSeatStatusesByShowing(showingId);

      final message = ChatbotUtils.formatSeatsMessage(seatStatuses, _currentLanguage);
      final actions = ChatbotUtils.createSeatActions(showingId, _currentLanguage);

      return AIChatResponse(
        message: message,
        actions: actions,
      );
    } catch (e) {
      return AIChatResponse(
        message: _currentLanguage == 'vi'
          ? 'Có lỗi xảy ra khi tải thông tin ghế.'
          : 'An error occurred while loading seat information.',
      );
    }
  }

  Future<AIChatResponse> _handleShowCinemas(ChatAction action) async {
    try {
      final result = await cinemaRepository.getCinemas();
      if (result.isSuccess && result.data != null) {
        // Extract all cinemas from the cinemasByCity map
        final cinemas = result.data!.cinemasByCity.values.expand((cinemaList) => cinemaList).toList();

        final message = ChatbotUtils.formatCinemasMessage(cinemas, _currentLanguage);
        final actions = ChatbotUtils.createCinemaActions(cinemas, _currentLanguage);

        return AIChatResponse(
          message: message,
          actions: actions,
        );
      } else {
        return AIChatResponse(
          message: _currentLanguage == 'vi'
            ? 'Không thể tải danh sách rạp. Vui lòng thử lại sau.'
            : 'Unable to load cinema list. Please try again later.',
        );
      }
    } catch (e) {
      return AIChatResponse(
        message: _currentLanguage == 'vi'
          ? 'Có lỗi xảy ra khi tải danh sách rạp.'
          : 'An error occurred while loading the cinema list.',
      );
    }
  }

  // Method to refresh all caches
  Future<void> refreshEnhancedCache() async {
    await _loadEnhancedCache();
    // Refresh movies cache by calling parent's method indirectly
    await movieRepository.getListShowingMovies();
    // The parent class will handle its own cache refresh when needed
  }

  // Method to clear specific caches
  void clearEnhancedCache() {
    _cachedCinemas = null;
  }
}
