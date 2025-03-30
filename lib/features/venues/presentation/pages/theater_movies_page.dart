import 'package:flutter/material.dart';

class TheaterMoviesPage extends StatelessWidget {
  final String theaterName;
  final String theaterAddress;

  const TheaterMoviesPage({
    super.key,
    required this.theaterName,
    required this.theaterAddress,
  });

  @override
  Widget build(BuildContext context) {
    // Sample data - In real app, this would come from your API/database
    final List<Map<String, dynamic>> movies = [
      {
        'title': 'Avengers: Secret Wars',
        'poster': 'assets/images/movie1.jpg',
        'duration': '2h 35m',
        'rating': 'PG-13',
        'formats': ['2D', '3D', 'IMAX'],
        'showtimes': [
          '10:30',
          '13:45',
          '17:00',
          '20:15',
          '22:30',
        ],
      },
      {
        'title': 'The Batman 2',
        'poster': 'assets/images/movie2.jpg',
        'duration': '2h 45m',
        'rating': 'PG-13',
        'formats': ['2D', 'IMAX'],
        'showtimes': [
          '11:00',
          '14:15',
          '17:30',
          '20:45',
        ],
      },
    ];

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              theaterName,
              style: const TextStyle(
                color: Colors.black87,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              theaterAddress,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.normal,
              ),
            ),
          ],
        ),
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: movies.length,
        itemBuilder: (context, index) {
          final movie = movies[index];
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
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(16),
                        bottomLeft: Radius.circular(16),
                      ),
                      child: Image.asset(
                        movie['poster'] as String,
                        width: 120,
                        height: 180,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          width: 120,
                          height: 180,
                          color: Colors.grey[200],
                          child: Icon(
                            Icons.movie,
                            size: 48,
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              movie['title'] as String,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Icon(
                                  Icons.access_time,
                                  size: 16,
                                  color: Colors.grey.shade600,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  movie['duration'] as String,
                                  style: TextStyle(
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    border: Border.all(color: Theme.of(context).primaryColor),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    movie['rating'] as String,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Theme.of(context).primaryColor,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Wrap(
                              spacing: 8,
                              children: (movie['formats'] as List<String>).map((format) {
                                return Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade100,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    format,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey.shade700,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  height: 1,
                  color: Colors.grey.shade100,
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.calendar_today,
                            size: 16,
                            color: Theme.of(context).primaryColor,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Showtimes',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: (movie['showtimes'] as List<String>).map((time) {
                          return Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () {
                                // TODO: Navigate to booking page
                              },
                              borderRadius: BorderRadius.circular(20),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: Theme.of(context).primaryColor.withOpacity(0.5),
                                  ),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  time,
                                  style: TextStyle(
                                    color: Theme.of(context).primaryColor,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
} 