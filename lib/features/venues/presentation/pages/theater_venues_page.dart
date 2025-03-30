import 'package:flutter/material.dart';

class TheaterVenuesPage extends StatelessWidget {
  const TheaterVenuesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theaters = [
      {
        'name': 'Nhà Hát Kịch Hà Nội',
        'image': 'assets/images/hanoi_theater.png',
        'description': 'Traditional Vietnamese theater performances',
        'address': '42 Trang Tien, Hoan Kiem, Ha Noi',
        'type': 'Traditional Theater',
        'capacity': '500 seats',
        'color': Colors.amber.shade50,
      },
      {
        'name': 'Nhà Hát Chèo Việt Nam',
        'image': 'assets/images/cheo_theater.png',
        'description': 'Traditional Cheo performances',
        'address': '69 Nguyen Du, Hai Ba Trung, Ha Noi',
        'type': 'Cheo Theater',
        'capacity': '300 seats',
        'color': Colors.green.shade50,
      },
      {
        'name': 'Nhà Hát Tuổi Trẻ',
        'image': 'assets/images/youth_theater.png',
        'description': 'Contemporary theater performances',
        'address': '11 Ngo Thi Nham, Hai Ba Trung, Ha Noi',
        'type': 'Modern Theater',
        'capacity': '400 seats',
        'color': Colors.purple.shade50,
      },
    ];

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200,
            backgroundColor: Theme.of(context).primaryColor,
            flexibleSpace: FlexibleSpaceBar(
              title: const Text(
                'Theater Venues',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Image.asset(
                    'assets/images/theater_banner.jpg',
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: Theme.of(context).primaryColor,
                      child: const Icon(
                        Icons.theater_comedy,
                        size: 64,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.7),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final theater = theaters[index];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Stack(
                          children: [
                            ClipRRect(
                              borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(16),
                              ),
                              child: Image.asset(
                                theater['image'] as String,
                                height: 200,
                                width: double.infinity,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) => Container(
                                  height: 200,
                                  color: theater['color'] as Color,
                                  child: Icon(
                                    Icons.theater_comedy,
                                    size: 64,
                                    color: Theme.of(context).primaryColor,
                                  ),
                                ),
                              ),
                            ),
                            Positioned(
                              top: 16,
                              right: 16,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.7),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(
                                      Icons.event_seat,
                                      size: 16,
                                      color: Colors.white,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      theater['capacity'] as String,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: theater['color'] as Color,
                            borderRadius: const BorderRadius.vertical(
                              bottom: Radius.circular(16),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      theater['name'] as String,
                                      style: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(20),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.05),
                                          blurRadius: 4,
                                        ),
                                      ],
                                    ),
                                    child: Text(
                                      theater['type'] as String,
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Theme.of(context).primaryColor,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                theater['description'] as String,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey.shade700,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Icon(
                                    Icons.location_on,
                                    size: 16,
                                    color: Colors.grey.shade700,
                                  ),
                                  const SizedBox(width: 4),
                                  Expanded(
                                    child: Text(
                                      theater['address'] as String,
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey.shade700,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: () {
                                    // TODO: Navigate to theater shows page
                                  },
                                  style: ElevatedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  child: const Text('View Shows'),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
                childCount: theaters.length,
              ),
            ),
          ),
        ],
      ),
    );
  }
} 