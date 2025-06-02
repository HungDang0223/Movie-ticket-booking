import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:localization/localization.dart';
import 'package:movie_tickets/core/constants/app_color.dart';

class MyAppBar extends StatefulWidget implements PreferredSizeWidget {
  final Function(String)? onLocationSelected;
  const MyAppBar({super.key, this.onLocationSelected});

  @override
  State<MyAppBar> createState() => _MyAppBarState();
  
  @override
  // TODO: implement preferredSize
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class _MyAppBarState extends State<MyAppBar> {
  @override
  Widget build(BuildContext context) {
    return AppBar(
      elevation: 0,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColor.DEFAULT.withOpacity(0.1),
                AppColor.DEFAULT_2.withOpacity(0.05),
              ],
            ),
          ),
        ),
        title: Text(
          'cinemas.cinema'.i18n(),
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
      ),
      actions: [
        IconButton(
          icon: Icon(Icons.location_on, color: AppColor.DEFAULT),
          onPressed: () => _showLocationPicker(),
        ),
      ],
    );
  }

  void _showLocationPicker() {
    
  }

}