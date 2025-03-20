import 'package:flutter/material.dart';
import 'package:movie_tickets/core/configs/size_config.dart';
import 'package:movie_tickets/core/utils/multi_devices.dart';

import '../../../../core/constants/my_const.dart';

class MovieDescription extends StatelessWidget {
  const MovieDescription({
    super.key,
    required this.movieInfo,
  });

  final List<Map<String, String>> movieInfo;

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
                          image: const DecorationImage(
                            image: NetworkImage(tempNetwordImage),
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
                        margin: EdgeInsets.only(left: 10),
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                height: MultiDevices.getValueByScale(SizeConfig.screenHeight! * 0.11),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    Text(
                                      "Bộ tứ báo thủ".toUpperCase(),
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
                                          border: Border.all(width: 1, color: AppColor.BLACK_30),
                                        ),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            const Icon(Icons.calendar_month_outlined, color: AppColor.BLACK, size: 15),
                                            const SizedBox(width: 5),
                                            Text("29/01/2025", style: MultiDevices.getStyle(fontSize: 14)),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      Container(
                                        padding: const EdgeInsets.all(2),
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(5),
                                          border: Border.all(width: 1, color: AppColor.BLACK_30),
                                        ),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            const Icon(Icons.access_time, color: AppColor.BLACK, size: 15),
                                            const SizedBox(width: 5),
                                            Text("2 giờ 12 phút", style: MultiDevices.getStyle(fontSize: 14)),
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
                                      const Text("5139", style: TextStyle(color: AppColor.BLACK)),
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
        const Text(
          "Bộ tứ báo thù bao gồm Chết-Xi-Cà, Dì Bốn, Cậu Mười Một, Con Kiều chính thức xuất hiện cùng với phi vụ báo thù thế kỉ...",
          style: TextStyle(fontSize: 14, color: Colors.black),
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
          children: movieInfo.map((info) {
            return TableRow(
              children: [
                Text(
                  info["title"]!,
                  style: MultiDevices.getStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                Container(
                  margin: const EdgeInsets.only(right: 15, bottom: 4),
                  child: Text(info["value"]!, textAlign: TextAlign.start),
                ),
              ],
            );
          }).toList(),
        ),
      ],
    );
  }
}