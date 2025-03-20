import 'dart:math';

import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:movie_tickets/core/configs/size_config.dart';
import 'package:movie_tickets/core/constants/my_const.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text("Đặt Vé Xem Phim"),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {},
          ),
        ],
        backgroundColor: Colors.transparent,
      ),
      body: SingleChildScrollView(
        child: Column(
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
                                MovieFlipCarousel(movies: List.generate(5, (index) => "https://images.unsplash.com/photo-1741091742846-99cca6f6437b?q=80&w=1372&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D")),
                                MovieFlipCarousel(movies: List.generate(5, (index) => "https://images.unsplash.com/photo-1741091742846-99cca6f6437b?q=80&w=1372&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D")),
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
              
              decoration: BoxDecoration(
                color: AppColor.DEFAULT,
                borderRadius: BorderRadius.only(topLeft: Radius.circular(10), topRight: Radius.circular(10))
              ),
            )
          ],
        ),
      ),
    );
  }
}

class MovieFlipCarousel extends StatefulWidget {
  final List<String> movies;

  MovieFlipCarousel({required this.movies});

  @override
  _MovieFlipCarouselState createState() => _MovieFlipCarouselState();
}

class _MovieFlipCarouselState extends State<MovieFlipCarousel> {
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 0.6, initialPage: widget.movies.length * 10);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PageView.builder(
      controller: _pageController,
      itemBuilder: (context, index) {
        int actualIndex = index % widget.movies.length;
        return AnimatedBuilder(
          animation: _pageController,
          builder: (context, child) {
            double value = 0.0;
            if (_pageController.position.haveDimensions) {
              value = _pageController.page! - index;
            }
            double tilt = (1 - (value.abs() * 0.3)).clamp(0.8, 1.0);
            return Transform(
              alignment: Alignment.center,
              transform: Matrix4.identity()
                ..setEntry(3, 2, 0.001)
                ..rotateY((value) * pi / 4)
                ..scale(tilt),
              child: InkWell(
                onTap: () => Navigator.of(context).pushNamed('/movie_detail'),
                child: Opacity(
                  opacity: tilt,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      image: DecorationImage(
                        image: NetworkImage(widget.movies[actualIndex]),
                        fit: BoxFit.cover,
                      ),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 10,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
