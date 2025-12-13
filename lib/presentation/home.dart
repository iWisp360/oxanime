import 'package:animebox/l10n/animebox_translations.dart';
import 'package:flutter/material.dart';

class AnimeBoxHome extends StatefulWidget {
  const AnimeBoxHome({super.key});

  @override
  State<AnimeBoxHome> createState() => _AnimeBoxHomeState();
}

class HomeElements {
  static List<NavigationDestination> getDestinations(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return [
      NavigationDestination(
        icon: Icon(Icons.home_outlined),
        selectedIcon: Icon(Icons.home),
        label: l10n!.navBarDest0,
      ),

      NavigationDestination(
        icon: Icon(Icons.video_collection_outlined),
        selectedIcon: Icon(Icons.video_collection),
        label: l10n.navBarDest1,
      ),
    ];
  }
}

class _AnimeBoxHomeState extends State<AnimeBoxHome> {
  int currentPageIndex = 0;

  NavigationDestinationLabelBehavior labelBehavior =
      NavigationDestinationLabelBehavior.onlyShowSelected;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Anime Box")),
      body: Placeholder(),
      backgroundColor: Theme.of(context).colorScheme.surface,
      bottomNavigationBar: NavigationBar(
        animationDuration: Duration(seconds: 1),
        destinations: HomeElements.getDestinations(context),
        labelBehavior: labelBehavior,
        selectedIndex: currentPageIndex,
        onDestinationSelected: (int index) {
          setState(() {
            currentPageIndex = index;
          });
        },
      ),
    );
  }
}
