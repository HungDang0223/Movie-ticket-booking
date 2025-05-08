import 'dart:developer';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/services.dart';
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

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int selectedIndex = 0;
  late ScrollController _scrollController;
  bool _isScrolled = false;
  bool _isMoviesLoaded = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _scrollController = ScrollController();
    _scrollController.addListener(_listenToScrollChange);
    
    // Initialize MovieBloc and trigger loading
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final movieBloc = sl<MovieBloc>();
      movieBloc.add(const GetListShowingMoviesEvent());
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
          onRefresh: () async {
            sl<MovieBloc>().add(const GetListShowingMoviesEvent());
          },
          color: AppColor.DEFAULT,
          child: CustomScrollView(
            controller: _scrollController,
            slivers: [
              HomeAppBar(isScrolled: _isScrolled),
              // Only show the search bar when not scrolled
              
              SliverToBoxAdapter(
                child: BlocBuilder<MovieBloc, MovieState>(
                  builder: (context, state) {
                    log('Current state: $state'); // Debug log
                    
                    // Show loading for Initial and Loading states
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

                    // Handle failure state
                    if (state is MovieLoadedFailed) {
                      return Container(
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
                              const SizedBox(height: 16),
                              ElevatedButton(
                                onPressed: () {
                                  sl<MovieBloc>().add(const GetListShowingMoviesEvent());
                                },
                                child: const Text('Retry'),
                              ),
                            ],
                          ),
                        ),
                      );
                    }

                    // Handle success state
                    if (state is MovieLoaded) {
                      final movies = state.movies;
                      _isMoviesLoaded = true;
                      
                      return Column(
                        children: [
                          Stack(
                            children: [
                              Positioned.fill(
                                child: Container(
                                  decoration: const BoxDecoration(
                                    image: DecorationImage(
                                          image: NetworkImage(
                                              "https://images.unsplash.com/photo-1741091742846-99cca6f6437b?q=80&w=1372&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D"),
                                          fit: BoxFit.cover,
                                          opacity: 0.4)
                                  ),
                                ),
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  PersistentHeader(isScrolled: _isScrolled),
                                  // Banner quảng cáo
                                  CarouselSlider(
                                    options: CarouselOptions(
                                      // height: 150.0,
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
                                  
                                  // TabBar moved below the banner
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
                                        ),
                                        const SizedBox(height: 15,),
                                        Flexible(
                                          child: TabBarView(
                                            controller: _tabController,
                                            children: [
                                              MovieCard(movies: List.generate(movies.length, (index) {
                                                return movies[index];
                                              })),
                                              MovieCard(movies: List.generate(movies.length, (index) {
                                                return movies[index];
                                              })),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(height: 5,),
                                        const Text("name name name")
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          Container(
                            height: 200,
                            
                            decoration: const BoxDecoration(
                              color: AppColor.DEFAULT,
                              borderRadius: BorderRadius.only(topLeft: Radius.circular(10), topRight: Radius.circular(10))
                            ),
                          )
                        ],
                      );
                    }

                    // Default state - should rarely be seen
                    return const SizedBox(
                      height: 200,
                      child: Center(
                        child: Text(
                          "Loading movies...", 
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    );
                  }),
              ),
            ],
          ),
        )
        ),
    );
}}
