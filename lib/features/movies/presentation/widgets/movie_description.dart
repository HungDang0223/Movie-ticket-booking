import 'package:flutter/material.dart';
import 'package:movie_tickets/core/configs/size_config.dart';
import 'package:movie_tickets/core/extensions/date_time_ext.dart';
import 'package:movie_tickets/core/extensions/num_ext.dart';
import 'package:movie_tickets/core/utils/multi_devices.dart';
import 'package:movie_tickets/features/movies/data/models/movie_model.dart';

import '../../../../core/constants/my_const.dart';

class MovieDescription extends StatelessWidget {
  const MovieDescription({
    super.key,
    required this.movie,
  });

  final MovieModel movie;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Stack(
          clipBehavior: Clip.none,
          children: [
            const Row(),
            Positioned(
              top: -MultiDevices.getValueByScale(SizeConfig.screenHeight! * 0.11),
              left: 0,
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        width: MultiDevices.getValueByScale(SizeConfig.screenWidth! * 0.28),
                        height: MultiDevices.getValueByScale(SizeConfig.screenHeight! * 0.22),
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: NetworkImage(movie.posterUrl ?? tempNetwordImage),
                            fit: BoxFit.cover,
                          ),
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: const [
                            BoxShadow(
                              color: AppColor.BLACK2,
                              offset: Offset(1, 0.5),
                              blurRadius: 5,
                            )
                          ],
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.only(left: 10, right: 10),
                        
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                height: MultiDevices.getValueByScale(SizeConfig.screenHeight! * 0.10),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    Text(
                                      movie.title,
                                      overflow: TextOverflow.ellipsis,
                                      style: MultiDevices.getStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: AppColor.WHITE,
                                      ),
                                    ),
                                    const SizedBox(height: 8,)
                                  ],
                                ),
                              ),
                              const SizedBox(height: 5),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(2),
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(5),
                                          border: Border.all(width: 1, color: AppColor.WHITE),
                                        ),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            const Icon(Icons.calendar_month_outlined, color: AppColor.WHITE, size: 14),
                                            const SizedBox(width: 5),
                                            Text(movie.releaseDate.toFormattedString(), style: MultiDevices.getStyle(fontSize: 12)),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(width: 5),
                                      Container(
                                        padding: const EdgeInsets.all(2),
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(5),
                                          border: Border.all(width: 1, color: AppColor.WHITE),
                                        ),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            const Icon(Icons.access_time, color: AppColor.WHITE, size: 14),
                                            const SizedBox(width: 5),
                                            Text(movie.duration.formatDuration(), style: MultiDevices.getStyle(fontSize: 12)),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 5),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(Icons.favorite_border_outlined, color: AppColor.DEFAULT, size: 17),
                                      const SizedBox(width: 5),
                                      const Text("5139", style: TextStyle(color: AppColor.WHITE)),
                                      const SizedBox(width: 10),
                                      InkWell(
                                        onTap: () {},
                                        child: Icon(Icons.share_outlined, color: AppColor.DEFAULT, size: MultiDevices.getValueByScale(17)),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        SizedBox(height: MultiDevices.getValueByScale(SizeConfig.screenHeight! * 0.11) + 10),
        Text(
          movie.synopsis,
          style: TextStyle(fontSize: 15, color: AppColor.WHITE),
          textAlign: TextAlign.justify,
          maxLines: 4,
          overflow: TextOverflow.clip,
        ),
        const SizedBox(height: 10),
        Table(
          columnWidths: const {
            0: FlexColumnWidth(1),
            1: FlexColumnWidth(2),
          },
          children: movie.movieInfo().entries.map((entry) {
              return TableRow(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: Text(entry.key, style: TextStyle(fontWeight: FontWeight.bold, color: AppColor.WHITE)),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: Text(entry.value.toString(), style: MultiDevices.getStyle(),),
                  ),
                ],
              );
            }).toList(),
        ),
      ],
    );
  }
}