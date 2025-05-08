import 'package:flutter/material.dart';
import 'package:movie_tickets/core/configs/size_config.dart';
import 'package:movie_tickets/core/constants/strings.dart';
import 'package:movie_tickets/core/utils/multi_devices.dart';
import 'package:movie_tickets/features/movies/data/models/movie_model.dart';

import '../../../../core/constants/my_const.dart';
import '../widgets/widgets.dart';

class MovieDetailScreen extends StatefulWidget {
  final MovieModel movie;
  MovieDetailScreen({super.key, required this.movie});

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
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text("Phim", style: TextStyle(color: AppColor.DEFAULT)),
        backgroundColor: Colors.white,
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
        decoration: BoxDecoration(
          color: AppColor.BLACK2
        ),
        child: Stack(
          children: [
            SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  MovieTrailer(posterUrl: widget.movie.posterUrl ,trailerUrl: widget.movie.trailerUrl),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        MovieDescription(movie: widget.movie),
                        const SizedBox(height: 10),
                        const MovieCommentView(),
                        const SizedBox(height: 10),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const Positioned(
              bottom: 10,
              left: 10,
              right: 10,
              child: BookingButton(),
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
      posterUrl ?? tempNetwordImage,
      width: double.infinity,
      height: MultiDevices.getValueByScale(SizeConfig.screenHeight! * 0.3),
      fit: BoxFit.cover,
    );
  }
}
