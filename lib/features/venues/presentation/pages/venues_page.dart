import 'package:flutter/material.dart';
import 'movie_venues_page.dart';
import 'theater_venues_page.dart';
import 'concert_venues_page.dart';

class VenuesPage extends StatefulWidget {
  const VenuesPage({super.key});

  @override
  State<VenuesPage> createState() => _VenuesPageState();
}

class _VenuesPageState extends State<VenuesPage> with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Entertainment Venues'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(
              icon: Icon(Icons.movie),
              text: 'Movies',
            ),
            Tab(
              icon: Icon(Icons.theater_comedy),
              text: 'Theaters',
            ),
            Tab(
              icon: Icon(Icons.music_note),
              text: 'Concerts',
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          MovieVenuesPage(),
          TheaterVenuesPage(),
          ConcertVenuesPage(),
        ],
      ),
    );
  }
} 