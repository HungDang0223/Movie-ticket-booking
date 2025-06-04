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
              top: -MultiDevices.getValueByScale(SizeConfig.screenHeight! * 0.1),
              left: 0,
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        width: MultiDevices.getValueByScale(SizeConfig.screenWidth! * 0.25),
                        height: MultiDevices.getValueByScale(SizeConfig.screenHeight! * 0.18),
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: NetworkImage(movie.posterUrl),
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
                        margin: const EdgeInsets.only(left: 10, right: 10),
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                height: MultiDevices.getValueByScale(SizeConfig.screenHeight! * 0.1),
                                width: MediaQuery.of(context).size.width * 0.65,
                                padding: const EdgeInsets.only(bottom: 10),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      movie.title,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      textAlign: TextAlign.start,
                                      style: MultiDevices.getStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.only(top: 10),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(2),
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(5),
                                            border: Border.all(width: 1, color: AppColor.GRAY1),
                                          ),
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              const Icon(Icons.calendar_month_outlined, color: AppColor.GRAY1, size: 14),
                                              const SizedBox(width: 5),
                                              Text(movie.releaseDate.toFormattedString(), style: MultiDevices.getStyle(fontSize: 12)),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(width: 5),
                                        Container(
                                          padding: const EdgeInsets.all(2),
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(4),
                                            border: Border.all(width: 1, color: AppColor.GRAY1),
                                          ),
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              const Icon(Icons.access_time, color: AppColor.GRAY1, size: 14),
                                              const SizedBox(width: 5),
                                              Text(movie.duration.formatDuration(), style: MultiDevices.getStyle(fontSize: 12)),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 10),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.favorite_border_outlined, color: AppColor.DEFAULT, size: MultiDevices.getValueByScale(20)),
                                        const SizedBox(width: 5),
                                        Text("5139", style: MultiDevices.getStyle(color: AppColor.WHITE, fontSize: 14)),
                                        const SizedBox(width: 10),
                                        InkWell(
                                          onTap: () {},
                                          child: Icon(Icons.share_outlined, color: AppColor.DEFAULT, size: MultiDevices.getValueByScale(20)),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
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
        SizedBox(height: MultiDevices.getValueByScale(SizeConfig.screenHeight! * 0.1)),
        Text(
          movie.synopsis,
          style: MultiDevices.getStyle(fontSize: 15),
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
                    child: Text(entry.key, style: MultiDevices.getStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: Text(entry.value.toString(), style: MultiDevices.getStyle(fontSize: 14),),
                  ),
                ],
              );
            }).toList(),
        ),
      ],
    );
  }
}