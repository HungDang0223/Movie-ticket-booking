import 'package:flutter/material.dart';
import 'chain_theaters_page.dart';

class MovieVenuesPage extends StatelessWidget {
  const MovieVenuesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> cinemaChains = [
      {
        'name': 'CGV Cinemas',
        'logo': 'assets/images/cgv_logo.png',
        'color': Colors.red.shade50,
      },
      {
        'name': 'BHD Star Cineplex',
        'logo': 'assets/images/bhd_logo.png',
        'color': Colors.blue.shade50,
      },
      {
        'name': 'Cinestar',
        'logo': 'assets/images/cinestar_logo.png',
        'color': Colors.orange.shade50,
      },
      {
        'name': 'Galaxy Cinema',
        'logo': 'assets/images/galaxy_logo.png',
        'color': Colors.purple.shade50,
      },
      {
        'name': 'Lotte Cinema',
        'logo': 'assets/images/lotte_logo.png',
        'color': Colors.pink.shade50,
      },
    ];

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.grey.shade100,
            Colors.white,
          ],
        ),
      ),
      child: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.85,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        itemCount: cinemaChains.length,
        itemBuilder: (context, index) {
          final chain = cinemaChains[index];
          return Hero(
            tag: chain['name'] as String,
            child: Material(
              child: InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ChainTheatersPage(
                        chainName: chain['name'] as String,
                        chainLogo: chain['logo'] as String,
                      ),
                    ),
                  );
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: chain['color'] as Color,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        spreadRadius: 1,
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            child: Image.asset(
                              chain['logo'] as String,
                              fit: BoxFit.contain,
                              errorBuilder: (context, error, stackTrace) => Icon(
                                Icons.movie,
                                size: 64,
                                color: Theme.of(context).primaryColor,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.1),
                                spreadRadius: 1,
                                blurRadius: 5,
                              ),
                            ],
                          ),
                          child: Text(
                            chain['name'] as String,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey.shade800,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
} 