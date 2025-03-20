import 'package:flutter/material.dart';
import 'package:movie_tickets/core/configs/size_config.dart';
import 'package:movie_tickets/core/constants/strings.dart';
import 'package:movie_tickets/core/utils/multi_devices.dart';

import '../../../../core/constants/my_const.dart';
import '../widgets/widgets.dart';

class MovieDetailScreen extends StatefulWidget {
  MovieDetailScreen({super.key});

  @override
  State<MovieDetailScreen> createState() => _MovieDetailScreenState();
}

class _MovieDetailScreenState extends State<MovieDetailScreen> {
  final size = SizeConfig();

  final List<Map<String, String>> movieInfo = [
    {"title": "Kiểm duyệt", "value": "T16 - Phim dành cho 16+"},
    {"title": "Thể loại", "value": "Hài, Tình cảm"},
    {"title": "Đạo diễn", "value": "Trấn Thành"},
    {"title": "Diễn viên", "value": "Trấn Thành, Lê Giang, Lê Dương Bảo Lâm, Uyển Ân, Trấn Thành, Lê Giang, Lê Dương Bảo Lâm, Uyển Ân, "},
    {"title": "Ngôn ngữ", "value": "Tiếng Việt - Phụ đề Tiếng Anh"},
  ];

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
        title: const Text("Phim", style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.menu, color: Colors.black),
            onPressed: () {},
          ),
        ],
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const MovieTrailer(),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      MovieDescription(movieInfo: movieInfo),
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
            left: 0,
            right: 0,
            child: BookingButton(),
          ),
        ],
      )

    );
  }
}

class MovieTrailer extends StatelessWidget {
  const MovieTrailer({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Image.network(
      tempNetwordImage,
      width: double.infinity,
      height: MultiDevices.getValueByScale(SizeConfig.screenHeight! * 0.3),
      fit: BoxFit.cover,
    );
  }
}
