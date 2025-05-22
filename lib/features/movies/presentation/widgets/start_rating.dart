import 'package:flutter/material.dart';

class EnhancedStarRatingDisplay extends StatefulWidget {
  final int rating;
  final double size;
  final Color color;
  final Color unselectedColor;
  final bool showLabel;
  final String? customLabel;
  final bool animate;

  const EnhancedStarRatingDisplay({
    super.key,
    required this.rating,
    this.size = 20.0,
    this.color = Colors.amber,
    this.unselectedColor = Colors.grey,
    this.showLabel = false,
    this.customLabel,
    this.animate = true,
  });

  @override
  State<EnhancedStarRatingDisplay> createState() => _EnhancedStarRatingDisplayState();
}

class _EnhancedStarRatingDisplayState extends State<EnhancedStarRatingDisplay>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late List<Animation<double>> _starAnimations;

  final List<String> _ratingLabels = [
    'Terrible',
    'Bad', 
    'Okay',
    'Good',
    'Excellent'
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _starAnimations = List.generate(5, (index) {
      return Tween<double>(
        begin: 0.0,
        end: 1.0,
      ).animate(CurvedAnimation(
        parent: _controller,
        curve: Interval(
          index * 0.1,
          0.5 + (index * 0.1),
          curve: Curves.elasticOut,
        ),
      ));
    });

    if (widget.animate) {
      _controller.forward();
    } else {
      _controller.value = 1.0;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(5, (index) {
            final isSelected = index < widget.rating;
            
            return AnimatedBuilder(
              animation: _starAnimations[index],
              builder: (context, child) {
                return Transform.scale(
                  scale: widget.animate ? _starAnimations[index].value : 1.0,
                  child: Container(
                    margin: EdgeInsets.symmetric(horizontal: widget.size * 0.05),
                    child: Icon(
                      isSelected ? Icons.star : Icons.star_border,
                      color: isSelected ? widget.color : widget.unselectedColor.withOpacity(0.4),
                      size: widget.size,
                    ),
                  ),
                );
              },
            );
          }),
        ),
        if (widget.showLabel) ...[
          const SizedBox(width: 8),
          AnimatedOpacity(
            opacity: widget.animate ? _controller.value : 1.0,
            duration: const Duration(milliseconds: 500),
            child: Text(
              widget.customLabel ?? 
              (widget.rating > 0 ? _ratingLabels[widget.rating - 1] : 'Not rated'),
              style: TextStyle(
                color: widget.rating > 0 ? widget.color : Colors.grey,
                fontSize: widget.size * 0.7,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ],
    );
  }
}

// Animated Star Rating Display with gradient effect
class GradientStarRatingDisplay extends StatelessWidget {
  final int rating;
  final double size;
  final List<Color> gradientColors;
  final bool showScore;

  const GradientStarRatingDisplay({
    super.key,
    required this.rating,
    this.size = 24.0,
    this.gradientColors = const [Colors.orange, Colors.amber],
    this.showScore = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: gradientColors),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: gradientColors.first.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.star,
            color: Colors.white,
            size: size,
          ),
          const SizedBox(width: 4),
          if (showScore)
            Text(
              rating.toString(),
              style: TextStyle(
                color: Colors.white,
                fontSize: size * 0.8,
                fontWeight: FontWeight.bold,
              ),
            ),
        ],
      ),
    );
  }
}

// Circular Progress Star Rating
class CircularStarRating extends StatefulWidget {
  final int rating;
  final double size;
  final Color backgroundColor;
  final Color foregroundColor;

  const CircularStarRating({
    super.key,
    required this.rating,
    this.size = 60.0,
    this.backgroundColor = Colors.grey,
    this.foregroundColor = Colors.amber,
  });

  @override
  State<CircularStarRating> createState() => _CircularStarRatingState();
}

class _CircularStarRatingState extends State<CircularStarRating>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _animation = Tween<double>(
      begin: 0.0,
      end: widget.rating / 5.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          AnimatedBuilder(
            animation: _animation,
            builder: (context, child) {
              return CircularProgressIndicator(
                value: _animation.value,
                strokeWidth: 4,
                backgroundColor: widget.backgroundColor.withOpacity(0.3),
                valueColor: AlwaysStoppedAnimation<Color>(widget.foregroundColor),
              );
            },
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.star,
                color: widget.foregroundColor,
                size: widget.size * 0.3,
              ),
              Text(
                widget.rating.toString(),
                style: TextStyle(
                  fontSize: widget.size * 0.2,
                  fontWeight: FontWeight.bold,
                  color: widget.foregroundColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}