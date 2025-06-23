import 'package:movie_tickets/core/services/networking/ai_chatbot_service.dart';
import 'package:movie_tickets/features/movies/data/models/movie_model.dart';
import 'package:movie_tickets/features/booking/data/datasources/showing_movie_remote_data_source.dart';
import 'package:movie_tickets/features/booking/data/models/seat.dart';
import 'package:movie_tickets/features/cinema/data/models/cinema.dart';
import 'package:movie_tickets/core/constants/enums.dart';

class ChatbotUtils {

  // Format movies list message
  static String formatMoviesMessage(List<MovieModel> movies, String language) {
    if (movies.isEmpty) {
      return language == 'vi'
        ? 'Hiện tại không có phim nào đang chiếu.'
        : 'No movies are currently showing.';
    }

    final header = language == 'vi'
      ? '🎬 Danh sách phim đang chiếu:\n\n'
      : '🎬 Currently showing movies:\n\n';

    final movieList = movies.take(5).map((movie) {
      final duration = movie.duration > 0 ? ' (${movie.duration} phút)' : '';
      return '• ${movie.title}$duration';
    }).join('\n');

    final footer = movies.length > 5
      ? (language == 'vi'
          ? '\n\n... và ${movies.length - 5} phim khác'
          : '\n\n... and ${movies.length - 5} more movies')
      : '';

    return '$header$movieList$footer';
  }

  // Create movie action buttons
  static List<ChatAction> createMovieActions(List<MovieModel> movies, String language) {
    final actions = <ChatAction>[];

    // Add individual movie actions (limit to 3 for UI)
    for (int i = 0; i < movies.length && i < 3; i++) {
      final movie = movies[i];
      actions.add(ChatAction(
        type: 'show_showtimes',
        label: language == 'vi'
          ? '🕐 Suất chiếu ${movie.title}'
          : '🕐 ${movie.title} Showtimes',
        parameters: {'movieId': movie.movieId},
      ));
    }

    // Add booking action for first movie
    if (movies.isNotEmpty) {
      actions.add(ChatAction(
        type: 'navigate',
        label: language == 'vi'
          ? '🎫 Đặt vé ${movies.first.title}'
          : '🎫 Book ${movies.first.title}',
        route: '/showing_movie_booking',
        parameters: {'movieId': movies.first.movieId},
      ));
    }

    return actions;
  }

  // Format showtimes message
  static String formatShowtimesMessage(List<ShowingMovieResponse> showingResponses, String language) {
    if (showingResponses.isEmpty) {
      return language == 'vi'
        ? 'Không có suất chiếu nào cho phim này hôm nay.'
        : 'No showtimes available for this movie today.';
    }

    final header = language == 'vi'
      ? '🕐 Suất chiếu hôm nay:\n\n'
      : '🕐 Today\'s showtimes:\n\n';

    // Flatten all showing movies from all responses
    final allShowings = showingResponses.expand((response) => response.showingMovies).toList();

    final showtimeList = allShowings.take(5).map((showing) {
      final time = showing.startTime;
      final cinema = showing.cinemaName;
      final screen = showing.screenName;
      return '• $time - $cinema $screen';
    }).join('\n');

    return '$header$showtimeList';
  }

  // Create showtime action buttons
  static List<ChatAction> createShowtimeActions(List<ShowingMovieResponse> showingResponses, String language) {
    final actions = <ChatAction>[];

    // Flatten all showing movies from all responses
    final allShowings = showingResponses.expand((response) => response.showingMovies).toList();

    // Add seat checking actions (limit to 3)
    for (int i = 0; i < allShowings.length && i < 3; i++) {
      final showing = allShowings[i];
      final time = showing.startTime;
      actions.add(ChatAction(
        type: 'show_seats',
        label: language == 'vi'
          ? '💺 Xem ghế $time'
          : '💺 Check seats $time',
        parameters: {'showingId': showing.showingId, 'showtime': time},
      ));
    }

    // Add direct booking action
    if (allShowings.isNotEmpty) {
      final firstShowing = allShowings.first;
      actions.add(ChatAction(
        type: 'navigate',
        label: language == 'vi'
          ? '🎫 Đặt vé ngay'
          : '🎫 Book now',
        route: '/seat_booking',
        parameters: {
          'showingMovie': firstShowing.toJson(),
        },
      ));
    }

    return actions;
  }

  // Format seats availability message
  static String formatSeatsMessage(List<SeatStatusUpdate> seatStatuses, String language) {
    if (seatStatuses.isEmpty) {
      return language == 'vi'
        ? 'Không thể tải thông tin ghế.'
        : 'Unable to load seat information.';
    }

    final availableSeats = seatStatuses.where((seat) => seat.status == SeatStatus.Available).length;
    final reservedSeats = seatStatuses.where((seat) => seat.status == SeatStatus.Reserved).length;
    final tempReservedSeats = seatStatuses.where((seat) => seat.status == SeatStatus.TempReserved).length;
    final soldSeats = seatStatuses.where((seat) => seat.status == SeatStatus.Sold).length;

    if (language == 'vi') {
      return '''💺 Tình trạng ghế:

✅ Còn trống: $availableSeats ghế
🟡 Đang giữ: $tempReservedSeats ghế
🔒 Đã đặt: $reservedSeats ghế
❌ Đã bán: $soldSeats ghế

Tổng cộng: ${seatStatuses.length} ghế''';
    } else {
      return '''💺 Seat availability:

✅ Available: $availableSeats seats
🟡 Temp Reserved: $tempReservedSeats seats
🔒 Reserved: $reservedSeats seats
❌ Sold: $soldSeats seats

Total: ${seatStatuses.length} seats''';
    }
  }

  // Create seat action buttons
  static List<ChatAction> createSeatActions(int showingId, String language) {
    return [
      ChatAction(
        type: 'navigate',
        label: language == 'vi'
          ? '💺 Chọn ghế ngay'
          : '💺 Select seats now',
        route: '/seat_booking',
        parameters: {'showingId': showingId},
      ),
      ChatAction(
        type: 'api_call',
        label: language == 'vi'
          ? '🔄 Cập nhật tình trạng ghế'
          : '🔄 Refresh seat status',
        apiEndpoint: '/seat-status/$showingId',
        parameters: {'showingId': showingId},
      ),
    ];
  }

  // Format cinemas list message
  static String formatCinemasMessage(List<Cinema> cinemas, String language) {
    if (cinemas.isEmpty) {
      return language == 'vi'
        ? 'Không có rạp chiếu phim nào.'
        : 'No cinemas available.';
    }

    final header = language == 'vi'
      ? '🏢 Danh sách rạp chiếu phim:\n\n'
      : '🏢 Cinema list:\n\n';

    final cinemaList = cinemas.take(5).map((cinema) {
      final address = cinema.location.isNotEmpty ? ' - ${cinema.location}' : '';
      return '• ${cinema.cinemaName}$address';
    }).join('\n');

    final footer = cinemas.length > 5
      ? (language == 'vi'
          ? '\n\n... và ${cinemas.length - 5} rạp khác'
          : '\n\n... and ${cinemas.length - 5} more cinemas')
      : '';

    return '$header$cinemaList$footer';
  }

  // Create cinema action buttons
  static List<ChatAction> createCinemaActions(List<Cinema> cinemas, String language) {
    final actions = <ChatAction>[];

    // Add individual cinema actions (limit to 3)
    for (int i = 0; i < cinemas.length && i < 3; i++) {
      final cinema = cinemas[i];
      actions.add(ChatAction(
        type: 'navigate',
        label: language == 'vi'
          ? '🎬 Phim tại ${cinema.cinemaName}'
          : '🎬 Movies at ${cinema.cinemaName}',
        route: '/cinema_detail',
        parameters: {'cinemaId': cinema.cinemaId},
      ));
    }

    return actions;
  }



  // Helper method to format date
  static String formatDate(DateTime date, String language) {
    if (language == 'vi') {
      return '${date.day}/${date.month}/${date.year}';
    } else {
      return '${date.month}/${date.day}/${date.year}';
    }
  }

  // Helper method to get greeting based on time
  static String getTimeBasedGreeting(String language) {
    final hour = DateTime.now().hour;

    if (language == 'vi') {
      if (hour < 12) return 'Chào buổi sáng';
      if (hour < 18) return 'Chào buổi chiều';
      return 'Chào buổi tối';
    } else {
      if (hour < 12) return 'Good morning';
      if (hour < 18) return 'Good afternoon';
      return 'Good evening';
    }
  }

  // Helper method to validate movie search
  static MovieModel? findMovieByName(List<MovieModel> movies, String searchTerm) {
    final lowerSearchTerm = searchTerm.toLowerCase();

    // Exact match first
    for (final movie in movies) {
      if (movie.title.toLowerCase() == lowerSearchTerm) {
        return movie;
      }
    }

    // Partial match
    for (final movie in movies) {
      if (movie.title.toLowerCase().contains(lowerSearchTerm)) {
        return movie;
      }
    }

    return null;
  }

  // Helper method to create error response
  static AIChatResponse createErrorResponse(String message, String language) {
    return AIChatResponse(
      message: message,
      actions: [
        ChatAction(
          type: 'navigate',
          label: language == 'vi' ? '🏠 Về trang chủ' : '🏠 Go to home',
          route: '/home',
        ),
      ],
    );
  }
}
