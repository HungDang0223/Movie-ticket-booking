import 'package:flutter/material.dart';

class StarRatingSelector extends StatefulWidget {
  final Function(int) onRatingSelected;

  const StarRatingSelector({
    super.key,
    required this.onRatingSelected,
  });

  @override
  _StarRatingSelectorState createState() => _StarRatingSelectorState();
}

class _StarRatingSelectorState extends State<StarRatingSelector> {
  int _rating = 0;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        return GestureDetector(
          onTap: () {
            setState(() {
              _rating = index + 1;
              widget.onRatingSelected(_rating);
            });
          },
          child: Padding(
            padding: const EdgeInsets.all(4.0),
            child: Icon(
              index < _rating ? Icons.star : Icons.star_border,
              size: 36.0,
              color: Colors.amber,
            ),
          ),
        );
      }),
    );
  }
}