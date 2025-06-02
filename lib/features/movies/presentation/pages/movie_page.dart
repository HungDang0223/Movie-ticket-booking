import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:localization/localization.dart';
import 'package:movie_tickets/core/constants/app_color.dart';
import 'package:movie_tickets/features/movies/presentation/bloc/movie_bloc/movie_bloc.dart';
import 'package:movie_tickets/features/movies/presentation/bloc/movie_bloc/movie_event.dart';
import 'package:movie_tickets/features/movies/presentation/bloc/movie_bloc/movie_state.dart';
import 'package:movie_tickets/features/movies/data/models/movie_model.dart';

class MoviePage extends StatefulWidget {
  const MoviePage({Key? key}) : super(key: key);

  @override
  State<MoviePage> createState() => _MoviePageState();
}

class _MoviePageState extends State<MoviePage> with TickerProviderStateMixin {
  late TabController _tabController;
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    
    // Load showing movies by default
    context.read<MovieBloc>().add(const GetListShowingMoviesEvent());
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onTabChanged() {
    if (_tabController.index == 0) {
      // Đang chiếu tab
      context.read<MovieBloc>().add(const GetListShowingMoviesEvent());
    } else {
      // Sắp chiếu tab
      context.read<MovieBloc>().add(const GetListUpcomingMoviesEvent());
    }
  }

  void _onSearchChanged(String value) {
    setState(() {
      _searchQuery = value;
    });
    // Có thể thêm debounce ở đây nếu cần
    // TODO: Implement search logic with BLoC
    // if (_tabController.index == 0) {
    //   context.read<MovieBloc>().add(SearchShowingMoviesEvent(value));
    // } else {
    //   context.read<MovieBloc>().add(SearchUpcomingMoviesEvent(value));
    // }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Phim', style: TextStyle(fontSize: 20),),
        centerTitle: true,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Search Bar Section
          _buildSearchBar(),
          
          // Tab Bar Section
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            decoration: BoxDecoration(
              color: theme.brightness == Brightness.dark 
                ? Colors.grey[800] 
                : Colors.grey[200],
              borderRadius: BorderRadius.circular(25.0),
            ),
            child: TabBar(
              controller: _tabController,
              onTap: (_) => _onTabChanged(),
              indicator: BoxDecoration(
                borderRadius: BorderRadius.circular(25.0),
                color: theme.primaryColor,
              ),
              indicatorSize: TabBarIndicatorSize.tab,
              dividerColor: Colors.transparent,
              labelColor: Colors.white,
              unselectedLabelColor: theme.brightness == Brightness.dark 
                ? Colors.grey[400] 
                : Colors.grey[700],
              labelStyle: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
              unselectedLabelStyle: const TextStyle(
                fontWeight: FontWeight.normal,
                fontSize: 16,
              ),
              tabs: const [
                Tab(text: 'Đang chiếu'),
                Tab(text: 'Sắp chiếu'),
              ],
            ),
          ),
          
          // Tab Bar View
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildMovieList(isShowing: true),
                _buildMovieList(isShowing: false),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    final theme = Theme.of(context);
    
    return Container(
      padding: const EdgeInsets.all(16.0),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colors.grey[400]!,
            width: 1,
          ),
          color: theme.brightness == Brightness.dark 
            ? Colors.grey[800] 
            : Colors.white,
        ),
        child: TextField(
          controller: _searchController,
          decoration: InputDecoration(
            hintText: 'Tìm kiếm phim...',
            hintStyle: TextStyle(color: Colors.grey[400]),
            prefixIcon: const Icon(Icons.search, color: AppColor.DEFAULT),
            suffixIcon: _searchQuery.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear, color: Colors.grey),
                    onPressed: () {
                      _searchController.clear();
                      _onSearchChanged('');
                    },
                  )
                : null,
            border: InputBorder.none,
            contentPadding: const EdgeInsets.all(16),
          ),
          onChanged: _onSearchChanged,
        ),
      ),
    );
  }

  Widget _buildMovieList({required bool isShowing}) {
    return BlocBuilder<MovieBloc, MovieState>(
      builder: (context, state) {
        if (state is MovieLoading) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        } else if (state is MovieLoadedSuccess) {
          List<MovieModel> filteredMovies = _filterMovies(state.movies);
          return _buildMovieGrid(filteredMovies);
        } else if (state is MovieLoadedFailed) {
          return _buildErrorWidget(state.errorMessage, isShowing);
        } else {
          return _buildEmptyWidget(isShowing);
        }
      },
    );
  }

  List<MovieModel> _filterMovies(List<MovieModel> movies) {
    if (_searchQuery.isEmpty) {
      return movies;
    }
    
    return movies.where((movie) {
      return movie.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
             movie.genre.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();
  }

  Widget _buildMovieGrid(List<MovieModel> movies) {
    if (movies.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.movie_outlined,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              _searchQuery.isNotEmpty 
                ? 'Không tìm thấy phim nào'
                : 'Không có phim nào',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
              ),
            ),
            if (_searchQuery.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                'Thử tìm kiếm với từ khóa khác',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[500],
                ),
              ),
            ],
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        if (_tabController.index == 0) {
          context.read<MovieBloc>().add(const RefreshShowingMoviesEvent());
        } else {
          context.read<MovieBloc>().add(const RefreshUpcomingMoviesEvent());
        }
      },
      child: GridView.builder(
        padding: const EdgeInsets.all(16.0),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.7,
          crossAxisSpacing: 16.0,
          mainAxisSpacing: 16.0,
        ),
        itemCount: movies.length,
        itemBuilder: (context, index) {
          final movie = movies[index];
          return _buildMovieCard(movie);
        },
      ),
    );
  }

  Widget _buildMovieCard(MovieModel movie) {
    final theme = Theme.of(context);
    
    return GestureDetector(
      onTap: () {
        // Navigate to movie detail
        context.read<MovieBloc>().add(GetMovieDetailEvent(movie.movieId));
      },
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 4,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(12),
                  ),
                  image: movie.posterUrl.isNotEmpty
                      ? DecorationImage(
                          image: NetworkImage(movie.posterUrl),
                          fit: BoxFit.cover,
                        )
                      : null,
                  color: Colors.grey[300],
                ),
                child: movie.posterUrl.isEmpty
                    ? const Center(
                        child: Icon(
                          Icons.movie,
                          size: 48,
                          color: Colors.grey,
                        ),
                      )
                    : Stack(
                        children: [
                          if (movie.rating > 0)
                            Positioned(
                              top: 8,
                              right: 8,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.7),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(
                                      Icons.star,
                                      color: Colors.amber,
                                      size: 14,
                                    ),
                                    const SizedBox(width: 2),
                                    Text(
                                      movie.rating.toStringAsFixed(1),
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                        ],
                      ),
              ),
            ),
            Expanded(
              flex: 3,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      movie.title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (movie.genre.isNotEmpty)
                      Text(
                        movie.genre,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.grey[600],
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    const Spacer(),
                    Row(
                      children: [
                        Icon(
                          Icons.access_time,
                          size: 14,
                          color: Colors.grey[600],
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${movie.duration} phút',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorWidget(String message, bool isShowing) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: Colors.red[400],
          ),
          const SizedBox(height: 16),
          Text(
            'Đã xảy ra lỗi',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.red[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              if (isShowing) {
                context.read<MovieBloc>().add(const GetListShowingMoviesEvent());
              } else {
                context.read<MovieBloc>().add(const GetListUpcomingMoviesEvent());
              }
            },
            child: const Text('Thử lại'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyWidget(bool isShowing) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.movie_outlined,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            isShowing ? 'Chưa có phim đang chiếu' : 'Chưa có phim sắp chiếu',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              if (isShowing) {
                context.read<MovieBloc>().add(const GetListShowingMoviesEvent());
              } else {
                context.read<MovieBloc>().add(const GetListUpcomingMoviesEvent());
              }
            },
            child: const Text('Tải lại'),
          ),
        ],
      ),
    );
  }
}