import 'package:flutter/material.dart';

class ConcertVenuesPage extends StatelessWidget {
  const ConcertVenuesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> venues = [
      {
        'name': 'My Dinh National Stadium',
        'image': 'images/sample_concert.jpg',
        'description': 'Large stadium for concerts and sports events',
        'address': 'Nam Tu Liem District, Hanoi',
        'capacity': '40,000 seats',
        'amenities': ['Parking', 'Food Court', 'VIP Lounges'],
        'color': Colors.blue.shade50,
        'upcoming': 3,
      },
      {
        'name': 'Hoa Binh Theater',
        'image': 'images/hoa_binh.png',
        'description': 'Indoor concert hall and performance venue',
        'address': '240 Ba Trieu Street, District 3, HCMC',
        'capacity': '1,500 seats',
        'amenities': ['Air Conditioning', 'Premium Sound System'],
        'color': Colors.purple.shade50,
        'upcoming': 5,
      },
      {
        'name': 'Saigon Exhibition and Convention Center',
        'image': 'images/secc.png',
        'description': 'Multi-purpose venue for concerts and events',
        'address': '799 Nguyen Van Linh, District 7, HCMC',
        'capacity': '5,000 seats',
        'amenities': ['Exhibition Space', 'Conference Rooms', 'Catering'],
        'color': Colors.green.shade50,
        'upcoming': 2,
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
                'Concert Venues',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Image.asset(
                    'assets/images/concert_banner.jpg',
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: Theme.of(context).primaryColor,
                      child: const Icon(
                        Icons.music_note,
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
                  final venue = venues[index];
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
                                venue['image'] as String,
                                height: 200,
                                width: double.infinity,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) => Container(
                                  height: 200,
                                  color: venue['color'] as Color,
                                  child: Icon(
                                    Icons.music_note,
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
                                      venue['capacity'] as String,
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
                            color: venue['color'] as Color,
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
                                      venue['name'] as String,
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
                                      color: Theme.of(context).primaryColor,
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(
                                          Icons.event,
                                          size: 16,
                                          color: Colors.white,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          '${venue['upcoming']} Events',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                venue['description'] as String,
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
                                      venue['address'] as String,
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey.shade700,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: (venue['amenities'] as List<String>).map((amenity) {
                                  return Container(
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
                                      amenity,
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Theme.of(context).primaryColor,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                              const SizedBox(height: 16),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: () {
                                    // TODO: Navigate to venue events page
                                  },
                                  style: ElevatedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  child: const Text('View Events'),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
                childCount: venues.length,
              ),
            ),
          ),
        ],
      ),
    );
  }
} 