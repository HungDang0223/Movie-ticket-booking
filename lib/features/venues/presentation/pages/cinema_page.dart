import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:localization/localization.dart';
import 'package:movie_tickets/core/constants/app_color.dart';
import 'package:movie_tickets/features/venues/data/models/cinema.dart';
import 'package:movie_tickets/features/venues/presentation/bloc/cinema_bloc.dart';
import 'package:movie_tickets/features/venues/presentation/bloc/cinema_event.dart';
import 'package:movie_tickets/features/venues/presentation/bloc/cinema_state.dart';
import 'package:movie_tickets/features/venues/presentation/widgets/app_bar.dart';
import 'package:movie_tickets/injection.dart';
import 'package:shimmer/shimmer.dart';

class CinemaPage extends StatefulWidget {
  const CinemaPage({Key? key}) : super(key: key);

  @override
  State<CinemaPage> createState() => _CinemaPageState();
}

class _CinemaPageState extends State<CinemaPage>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  String? selectedCity;
  final TextEditingController _searchController = TextEditingController();
  final CinemaBloc bloc = sl<CinemaBloc>();

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _loadInitialData();
  }

  void _initializeAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));

    _fadeController.forward();
    _slideController.forward();
  }

  void _loadInitialData() {
    // Uncomment when you have the actual bloc
    bloc.add(GetCinemas());
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSearchAndFilter(),
                const SizedBox(height: 24),
                Expanded(
                  child: _buildCinemaContent(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return MyAppBar(
      onLocationSelected: (cityName) {
        setState(() {
          selectedCity = cityName;
        });
        context.read<CinemaBloc>().add(GetCinemasByCityName(cityName));
      },
    );
  }

  Widget _buildSearchAndFilter() {
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Colors.grey[400]!,
              width: 1,
            ),
          ),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'cinemas.searchCinemas'.i18n(),
              hintStyle: TextStyle(color: Colors.grey[400]),
              prefixIcon: const Icon(Icons.search, color: AppColor.DEFAULT),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.all(16),
            ),
            onChanged: (value) {
              // Implement search logic
              // context.read<CinemaBloc>().add(SearchCinemasEvent(value));
            },
          ),
        ),
        const SizedBox(height: 16),
        _buildCityFilter(),
      ],
    );
  }

  Widget _buildCityFilter() {
    return Container(
      height: 50,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _buildCityChip('common.all'.i18n(), selectedCity == null),
          _buildCityChip('Hồ Chí Minh', selectedCity == 'Hồ Chí Minh'),
          _buildCityChip('Hà Nội', selectedCity == 'Hà Nội'),
          _buildCityChip('Huế', selectedCity == 'Huế'),
          _buildCityChip('Đà Nẵng', selectedCity == 'Đà Nẵng')
        ],
      ),
    );
  }

  Widget _buildCityChip(String cityName, bool isSelected) {
    return Padding(
      padding: const EdgeInsets.only(right: 12),
      child: FilterChip(
        label: Text(
          cityName,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.grey[600],
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        selected: isSelected,
        onSelected: (selected) {
          setState(() {
            selectedCity = selected ? cityName : null;
          });
          // Uncomment when you have the actual bloc
          if (selected) {
            bloc.add(GetCinemasByCityName(cityName));
          } else {
            bloc.add(GetCinemas());
          }
        },
        selectedColor: AppColor.DEFAULT,
        checkmarkColor: Colors.white,
        elevation: isSelected ? 4 : 2,
        shadowColor: AppColor.DEFAULT.withOpacity(0.3),
      ),
    );
  }

  Widget _buildCinemaContent() {
    // Replace this with actual BlocBuilder when you have the bloc
    return BlocBuilder<CinemaBloc, CinemaState>(
      bloc: bloc,
      builder: (context, state) {
        if (state is CinemaLoading) {
          return _buildLoadingState();
        } else if (state is CinemaLoadedSuccess) {
          return _buildCinemaByCity(state.cinemas);
        } else if (state is CinemaLoadedFailure) {
          return _buildErrorState(state.message);
        }
        return _buildEmptyState();
      },
    );
  }

  Widget _buildLoadingState() {
    return Column(
      children: List.generate(5, (index) => _buildShimmerCard()),
    );
  }

  Widget _buildShimmerCard() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Shimmer.fromColors(
        baseColor: Colors.grey[300]!,
        highlightColor: Colors.grey[100]!,
        child: Container(
          height: 120,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }

  Widget _buildCinemaByCity(CinemaResponse cinemaResponse) {
    final cities = cinemaResponse.cinemasByCity.keys.toList();
    
    if (cities.isEmpty) {
      return _buildEmptyState();
    }

    return Expanded(
      child: ListView.builder(
        shrinkWrap: false,
        scrollDirection: Axis.vertical,
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: cities.length,
        itemBuilder: (context, index) {
          String cityName = cities[index];
          List<Cinema> cinemas = cinemaResponse.cinemasByCity[cityName] ?? [];
          
          return AnimatedContainer(
            duration: Duration(milliseconds: 300 + (index * 100)),
            child: _buildCityExpandTile(cityName, cinemas, index),
          );
        },
      ),
    );
  }

  Widget _buildCityExpandTile(String cityName, List<Cinema> cinemas, int index) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TweenAnimationBuilder<double>(
        duration: Duration(milliseconds: 600 + (index * 150)),
        tween: Tween(begin: 0.0, end: 1.0),
        builder: (context, value, child) {
          return Transform.translate(
            offset: Offset(0, 30 * (1 - value)),
            child: Opacity(
              opacity: value,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: AppColor.DEFAULT.withOpacity(0.5),
                    width: 1,
                  ),
                ),
                child: Theme(
                  data: Theme.of(context).copyWith(
                    dividerColor: Colors.transparent,
                  ),
                  child: ExpansionTile(
                    tilePadding: const EdgeInsets.symmetric(horizontal: 20),
                    // Add your children widgets here
                    title: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                cityName,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppColor.DEFAULT.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            '${cinemas.length}',
                            style: const TextStyle(
                              color: AppColor.DEFAULT,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ],
                    ),
                    trailing: const Icon(
                      Icons.expand_more,
                      color: AppColor.DEFAULT,
                    ),
                    children: [
                      Container(
                        margin: const EdgeInsets.only(top: 8),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          children: cinemas.asMap().entries.map((cinemaEntry) {
                            int cinemaIndex = cinemaEntry.key;
                            Cinema cinema = cinemaEntry.value;
                            return _buildCinemaCardInTile(cinema, cinemaIndex);
                          }).toList(),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCinemaCardInTile(Cinema cinema, int index) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        border: // only set border top for the first item, other set bottom border
            index == 0 ? Border.symmetric(horizontal: BorderSide(color: AppColor.DEFAULT.withOpacity(0.5), width: 1)) : Border(bottom: BorderSide(color: AppColor.DEFAULT.withOpacity(0.5), width: 1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => _onCinemaTap(cinema),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: _buildCinemaInfoCompact(cinema),
                ),
                _buildActionButtonSmall(cinema),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCinemaInfoCompact(Cinema cinema) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          cinema.cinemaName,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            const Icon(Icons.location_on, size: 14, color: AppColor.DEFAULT),
            const SizedBox(width: 4),
            Expanded(
              child: Text(
                cinema.location,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionButtonSmall(Cinema cinema) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColor.DEFAULT, AppColor.DEFAULT_2],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: AppColor.DEFAULT.withOpacity(0.3),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: () {
          debugPrint('Tapped on cinema: ${cinema.cinemaName}');
          Navigator.of(context).pushNamed('/cinema_detail', arguments: cinema);
        },
        child: const Icon(
          Icons.arrow_forward_ios,
          color: Colors.white,
          size: 14,
        ),
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return Container(
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'Oops! Something went wrong',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.grey[500],
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => _loadInitialData(),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColor.DEFAULT,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Try Again'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          Icon(
            Icons.movie_outlined,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No cinemas found',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Try adjusting your search or filter criteria',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  void _onCinemaTap(Cinema cinema) {
    // Navigate to cinema detail page or showtimes
    // Navigator.pushNamed(context, '/cinema-detail', arguments: cinema);
  }

  
}