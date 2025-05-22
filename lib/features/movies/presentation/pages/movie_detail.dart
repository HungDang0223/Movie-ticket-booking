import 'package:flutter/material.dart';
import 'package:movie_tickets/core/configs/size_config.dart';
import 'package:movie_tickets/core/utils/multi_devices.dart';
import 'package:movie_tickets/features/movies/data/models/movie_model.dart';

import '../../../../core/constants/my_const.dart';
import '../widgets/widgets.dart';

class MovieDetailScreen extends StatefulWidget {
  final MovieModel movie;
  const MovieDetailScreen({super.key, required this.movie});

  @override
  State<MovieDetailScreen> createState() => _MovieDetailScreenState();
}

class _MovieDetailScreenState extends State<MovieDetailScreen> {
  final size = SizeConfig();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
    });
  }

  @override
  Widget build(BuildContext context) {
    size.init;
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.movie.title, style: const TextStyle(color: AppColor.DEFAULT), overflow: TextOverflow.ellipsis,),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColor.DEFAULT),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.menu, color: AppColor.DEFAULT),
            onPressed: () {},
          ),
        ],
      ),
      body: Container(
        child: Stack(
          children: [
            SingleChildScrollView(
              child: Container(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    MovieTrailer(posterUrl: widget.movie.posterUrl ,trailerUrl: widget.movie.trailerUrl),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          MovieDescription(movie: widget.movie),
                          const SizedBox(height: 10),
                          EnhancedMovieCommentView(
                            movie: widget.movie// Optional
                          ),
                          const SizedBox(height: 10),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              bottom: 10,
              left: 10,
              right: 10,
              child: BookingButton(movie: widget.movie,),
            ),
          ],
        ),
      )

    );
  }
}

class MovieTrailer extends StatelessWidget {
  final String? trailerUrl;
  final String posterUrl;
  const MovieTrailer({
    super.key, required this.trailerUrl, required this.posterUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Image.network(
      posterUrl,
      width: double.infinity,
      height: MultiDevices.getValueByScale(SizeConfig.screenHeight! * 0.25),
      fit: BoxFit.cover,
    );
  }
}
