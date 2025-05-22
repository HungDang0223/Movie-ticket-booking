import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:movie_tickets/core/configs/size_config.dart';
import 'package:movie_tickets/core/constants/my_const.dart';
import 'package:movie_tickets/features/movies/data/models/movie_model.dart';
import 'package:movie_tickets/features/movies/presentation/bloc/movie_bloc/movie_bloc.dart';
import 'package:movie_tickets/features/movies/presentation/bloc/movie_bloc/movie_event.dart';
import 'package:movie_tickets/features/movies/presentation/bloc/movie_bloc/movie_state.dart';
import 'package:movie_tickets/features/movies/presentation/widgets/home_app_bar.dart';
import 'package:movie_tickets/features/movies/presentation/widgets/movie_card.dart';
import 'package:movie_tickets/features/movies/presentation/widgets/persistent_header.dart';
import 'package:movie_tickets/injection.dart';
import 'dart:async';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int selectedIndex = 0;
  late ScrollController _scrollController;
  bool _isScrolled = false;
  bool _isMoviesLoaded = false;

  // Thêm biến để theo dõi trang hiện tại của MovieCard PageView
  int _currentMovieCardIndex = 0;

  // Background image url - có thể thay đổi khi swipe qua card mới
  String _backgroundImageUrl = "https://images.unsplash.com/photo-1741091742846-99cca6f6437b?q=80&w=1372&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D";

  // Tạo biến để giữ reference đến MovieBloc
  late MovieBloc _movieBloc;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _scrollController = ScrollController();
    _scrollController.addListener(_listenToScrollChange);

    // Lấy MovieBloc một lần và lưu vào biến
    _movieBloc = sl<MovieBloc>();

    // Trigger loading movies khi trang được khởi tạo
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _movieBloc.add(const GetListShowingMoviesEvent());
      log('GetListShowingMoviesEvent triggered');
    });
  }

  void _listenToScrollChange() {
    if (_scrollController.offset >= 32) { // Reduced threshold
      if (!_isScrolled) {
        setState(() {
          _isScrolled = true;
        });
      }
    } else {
      if (_isScrolled) {
        setState(() {
          _isScrolled = false;
        });
      }
    }
  }

  // Thêm hàm để cập nhật background khi chuyển trang MovieCard
  void _updateBackground(int index, List<MovieModel> movies) {
    if (_currentMovieCardIndex != index && movies.isNotEmpty) {
      setState(() {
        _currentMovieCardIndex = index;
        // Lấy posterUrl từ movie hiện tại làm background
        _backgroundImageUrl = movies[index % movies.length].posterUrl;
      });
    }
  }

  Future<void> _handleRefresh() async {
    final completer = Completer<void>();

    // Sử dụng MovieBloc đã lưu trữ
    final subscription = _movieBloc.stream.listen((state) {
      log('Refresh state received: $state');
      if (state is MovieLoaded || state is MovieLoadedFailed) {
        if (!completer.isCompleted) {
          completer.complete();
        }
      }
    });

    // Add the event to fetch movies
    _movieBloc.add(const GetListShowingMoviesEvent());
    log('Refresh: GetListShowingMoviesEvent triggered');

    // Wait for completion
    await completer.future;

    // Clean up subscription
    subscription.cancel();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
          backgroundColor: Colors.transparent,
          body: RefreshIndicator(
            onRefresh: _handleRefresh,
            color: AppColor.DEFAULT,
            displacement: 60,
            child: Stack(
              children: [
                // Background Image - Đặt ở đầu Stack để hiển thị ở dưới cùng
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 500),
                  transitionBuilder: (Widget child, Animation<double> animation) {
                    return FadeTransition(opacity: animation, child: child);
                  },
                  child: Container(
                    key: ValueKey<String>(_backgroundImageUrl),
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: NetworkImage(_backgroundImageUrl),
                        fit: BoxFit.cover,
                        opacity: 0.8,
                      ),
                    ),
                  ),
                ),

                // Gradient overlay để nội dung dễ đọc hơn
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withOpacity(0.7),
                        Colors.black.withOpacity(0.5),
                        Colors.black.withOpacity(0.3),
                      ],
                    ),
                  ),
                ),

                // Main content
                CustomScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  controller: _scrollController,
                  slivers: [
                    HomeAppBar(isScrolled: _isScrolled),
                    PersistentHeader(isScrolled: _isScrolled),

                    SliverToBoxAdapter(
                      child: BlocProvider.value(
                        value: _movieBloc, // Sử dụng MovieBloc đã lưu trữ
                        child: BlocConsumer<MovieBloc, MovieState>(
                            listenWhen: (previous, current) {
                              // Log để debug
                              log('Previous state: $previous, Current state: $current');
                              return true;
                            },
                            listener: (context, state) {
                              // Cập nhật trạng thái đã load
                              if (state is MovieLoaded) {
                                log('BlocConsumer detected MovieLoaded state');
                                setState(() {
                                  _isMoviesLoaded = true;
                                });
                              }
                            },
                            buildWhen: (previous, current) {
                              log('buildWhen - Previous: $previous, Current: $current');
                              return true; // Luôn rebuild để đảm bảo UI cập nhật
                            },
                            builder: (context, state) {
                              log('Building UI for state: $state');

                              if (state is MovieInitial || (state is MovieLoading && !_isMoviesLoaded)) {
                                return Container(
                                  height: SizeConfig.screenHeight! * 0.8,
                                  color: Colors.transparent,
                                  child: const Center(
                                    child: CircularProgressIndicator(
                                      color: AppColor.DEFAULT,
                                    ),
                                  ),
                                );
                              }

                              if (state is MovieLoadedFailed) {
                                _isMoviesLoaded = false;
                                return SizedBox(
                                  height: SizeConfig.screenHeight! * 0.8,
                                  child: Center(
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          'Failed to load movies\n${state.errorMessage}',
                                          textAlign: TextAlign.center,
                                          style: const TextStyle(color: Colors.white),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              }

                              if (state is MovieLoaded) {
                                final movies = state.movies;
                                log('Movies loaded: ${movies.length}');

                                // Cập nhật background ban đầu từ phim đầu tiên (nếu có)
                                if (movies.isNotEmpty && _backgroundImageUrl == "https://images.unsplash.com/photo-1741091742846-99cca6f6437b?q=80&w=1372&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D") {
                                  WidgetsBinding.instance.addPostFrameCallback((_) {
                                    setState(() {
                                      _backgroundImageUrl = movies[0].posterUrl;
                                    });
                                  });
                                }

                                return Column(
                                  children: [
                                    // Banner quảng cáo
                                    CarouselSlider(
                                      options: CarouselOptions(
                                          aspectRatio: 3/1,
                                          autoPlay: true,
                                          autoPlayAnimationDuration: const Duration(milliseconds: 1500),
                                          disableCenter: true,
                                          enlargeCenterPage: true,
                                          enlargeStrategy: CenterPageEnlargeStrategy.height
                                      ),
                                      items: List.generate(3, (index) {
                                        return Builder(
                                          builder: (context) {
                                            return Container(
                                              margin: const EdgeInsets.symmetric(horizontal: 5.0),
                                              decoration: BoxDecoration(
                                                borderRadius: BorderRadius.circular(10),
                                                image: const DecorationImage(
                                                  image: NetworkImage("https://images.unsplash.com/photo-1741091742846-99cca6f6437b?q=80&w=1372&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D"),
                                                  fit: BoxFit.cover,
                                                ),
                                              ),
                                            );
                                          },
                                        );
                                      }),
                                    ),

                                    // TabBar và MovieCard
                                    SizedBox(
                                      height: MediaQuery.of(context).size.height * 0.6,
                                      child: Column(
                                        children: [
                                          TabBar(
                                            controller: _tabController,
                                            tabs: const [
                                              Tab(text: "Phim Đang Chiếu"),
                                              Tab(text: "Phim Sắp Chiếu"),
                                            ],
                                            labelColor: AppColor.DEFAULT,
                                            indicatorColor: AppColor.DEFAULT,
                                            unselectedLabelColor: Colors.white,
                                            indicatorSize: TabBarIndicatorSize.tab,
                                          ),
                                          const SizedBox(height: 15,),
                                          Flexible(
                                            child: TabBarView(
                                              controller: _tabController,
                                              children: [
                                                // Đang chiếu tab - truyền callback để cập nhật background
                                                MovieCardWithCallback(
                                                  movies: List.generate(movies.length, (index) {
                                                    return movies[index];
                                                  }),
                                                  onPageChanged: (index) {
                                                    _updateBackground(index, movies);
                                                  },
                                                ),
                                                // Sắp chiếu tab - truyền callback để cập nhật background
                                                MovieCardWithCallback(
                                                  movies: List.generate(movies.length, (index) {
                                                    return movies[index];
                                                  }),
                                                  onPageChanged: (index) {
                                                    _updateBackground(index, movies);
                                                  },
                                                ),
                                              ],
                                            ),
                                          ),
                                          const SizedBox(height: 5,),
                                          Text(
                                            movies.isNotEmpty && _currentMovieCardIndex < movies.length
                                                ? movies[_currentMovieCardIndex].title
                                                : "",
                                            style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold
                                            ),
                                          )
                                        ],
                                      ),
                                    ),

                                    Container(
                                      height: 200,
                                      decoration: const BoxDecoration(
                                          color: AppColor.DEFAULT,
                                          borderRadius: BorderRadius.only(
                                              topLeft: Radius.circular(10),
                                              topRight: Radius.circular(10)
                                          )
                                      ),
                                    )
                                  ],
                                );
                              }

                              return const SizedBox(
                                height: 200,
                                child: Center(
                                  child: Text(
                                    "No movies available",
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ),
                              );
                            }),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          )
      ),
    );
  }
}

// Wrapper cho MovieCard với callback để cập nhật background
class MovieCardWithCallback extends StatelessWidget {
  final List<MovieModel> movies;
  final Function(int) onPageChanged;

  const MovieCardWithCallback({super.key,
    required this.movies,
    required this.onPageChanged,
  });

  @override
  Widget build(BuildContext context) {
    return MovieCard(
      movies: movies,
      onPageChanged: onPageChanged,
    );
  }
}