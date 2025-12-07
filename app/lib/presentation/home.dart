import "package:flutter/material.dart";
import "package:animebox/domain/series.dart";
import "package:animebox/domain/sources.dart";
import "package:animebox/presentation/serie.dart";
import "package:animebox/presentation/views.dart";
import "package:animebox/widgets/search.dart";

class OxAnimeHomeScreen extends StatefulWidget {
  const OxAnimeHomeScreen({super.key});
  @override
  State<OxAnimeHomeScreen> createState() => _OxAnimeHomeScreenState();
}

class _OxAnimeHomeScreenState extends State<OxAnimeHomeScreen> {
  int _selectedDestination = 0;

  static const List<Widget> _destinations = [HomeView(), SearchView()];

  void _onDestinationSelected(int index) {
    setState(() {
      _selectedDestination = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("OxAnime"),
        backgroundColor: Colors.cyanAccent,
        actions: [
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () async {
              final SearchResult selectedResult = await showSearch(
                context: context,
                delegate: AnimeResults(),
                query: "Date A Live",
              );

              final serie = Serie.createSerie(selectedResult);
              if (!mounted) return;
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SerieScreen(serie: serie)),
              );
            },
          ),
        ],
      ),
      body: _destinations.elementAt(_selectedDestination),
      bottomNavigationBar: NavigationBar(
        labelBehavior: NavigationDestinationLabelBehavior.onlyShowSelected,
        selectedIndex: _selectedDestination,
        onDestinationSelected: _onDestinationSelected,
        destinations: [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: "Home",
          ),

          NavigationDestination(
            icon: Icon(Icons.search_outlined),
            selectedIcon: Icon(Icons.search),
            label: "Browse",
          ),
        ],
      ),
    );
  }
}
