import 'package:flutter/material.dart';

import 'theater_movies_page.dart';

class ChainTheatersPage extends StatelessWidget {
  final String chainName;
  final String chainLogo;

  const ChainTheatersPage({
    super.key,
    required this.chainName,
    required this.chainLogo,
  });

  @override
  Widget build(BuildContext context) {
    // Sample data - In real app, this would come from your API/database
    final Map<String, List<Map<String, dynamic>>> conveniences = {
      'Hà Nội': [
        {
          'name': '$chainName Vincom Royal City',
          'address': '72A Nguyễn Trãi, Thanh Xuân, Hà Nội',
          'features': ['IMAX', '4DX', 'Dolby Atmos'],
          'color': Colors.blue.shade50,
        },
        {
          'name': '$chainName Times City',
          'address': '458 Minh Khai, Hai Bà Trưng, Hà Nội',
          'features': ['SCREENX', 'Dolby Atmos'],
          'color': Colors.purple.shade50,
        },
      ],
      'Hồ Chí Minh': [
        {
          'name': '$chainName Landmark 81',
          'address': 'Landmark 81, Bình Thạnh, TP.HCM',
          'features': ['IMAX', '4DX', 'Dolby Atmos'],
          'color': Colors.green.shade50,
        },
        {
          'name': '$chainName Crescent Mall',
          'address': 'Crescent Mall, Quận 7, TP.HCM',
          'features': ['Gold Class', 'Dolby Atmos'],
          'color': Colors.orange.shade50,
        },
      ],
      'Đà Nẵng': [
        {
          'name': '$chainName Vincom Đà Nẵng',
          'address': '910 Ngô Quyền, Sơn Trà, Đà Nẵng',
          'features': ['4DX', 'Dolby Atmos'],
          'color': Colors.pink.shade50,
        },
      ],
    };

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        iconTheme: const IconThemeData(color: Colors.black87),
        title: Row(
          children: [
            Hero(
              tag: chainName,
              child: Image.asset(
                chainLogo,
                height: 32,
                errorBuilder: (context, error, stackTrace) => Icon(
                  Icons.movie,
                  color: Theme.of(context).primaryColor,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              chainName,
              style: const TextStyle(
                color: Colors.black87,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: conveniences.length,
        itemBuilder: (context, index) {
          final city = conveniences.keys.elementAt(index);
          final theaters = conveniences[city]!;
          
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
            child: Theme(
              data: Theme.of(context).copyWith(
                dividerColor: Colors.transparent,
              ),
              child: ExpansionTile(
                title: Row(
                  children: [
                    Icon(
                      Icons.location_city,
                      color: Theme.of(context).primaryColor,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      city,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
                childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                children: theaters.map((theater) {
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: theater['color'] as Color,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => TheaterMoviesPage(
                                theaterName: theater['name'] as String,
                                theaterAddress: theater['address'] as String,
                              ),
                            ),
                          );
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                theater['name'] as String,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
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
                              const SizedBox(height: 12),
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: (theater['features'] as List<String>).map((feature) {
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
                                      feature,
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Theme.of(context).primaryColor,
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
                    ),
                  );
                }).toList(),
              ),
            ),
          );
        },
      ),
    );
  }
}