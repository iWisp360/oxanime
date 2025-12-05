import 'package:flutter/material.dart';
import 'package:oxanime/core/constants.dart';
import "package:oxanime/domain/sources.dart";

class AnimeResults extends SearchDelegate {
  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(icon: Icon(Icons.arrow_back), onPressed: () => close(context, null));
  }

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(icon: Icon(Icons.clear), onPressed: () => {query = ""}),
    ];
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return Placeholder();
  }

  @override
  Widget buildResults(BuildContext context) {
    return FutureBuilder(
      future: sources[0].query(query),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasData) {
          final List<SearchResult> resultsSeries = snapshot.data ?? [];
          if (resultsSeries.isEmpty == true) return Center(child: Text("No results"));

          return ListView.builder(
            itemCount: resultsSeries.length,
            itemBuilder: (context, index) {
              SearchResult? result = resultsSeries.elementAt(index);
              return ListTile(
                subtitle: Text(result.name),
                leading: Image.network(
                  result.imageUrl ?? PlaceHolders.emptyString,
                  fit: BoxFit.contain,
                  width: 50,
                  height: 100,
                ),
                onTap: () {
                  close(context, result);
                },
              );
            },
          );
        }
        return Text("Search Anime");
      },
    );
  }
}
