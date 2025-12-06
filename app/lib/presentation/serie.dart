import 'package:oxanime/core/constants.dart';
import 'package:oxanime/domain/series.dart';
import "package:flutter/material.dart";
import 'package:oxanime/presentation/video.dart';

const headers = {"referer": "https://www.yourupload.com/"};

class SerieScreen extends StatelessWidget {
  final Serie serie;
  const SerieScreen({super.key, required this.serie});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(serie.name),
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.network(serie.imageUrl),
            const SizedBox(height: 16),

            // Description Section
            Text(
              'Description',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(color: colorScheme.primary),
            ),
            const SizedBox(height: 8),
            Text(
              serie.description ?? Placeholders.emptyString,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 24),
            ExpansionTile(
              title: Text("Chapters"),
              children: List.generate(serie.chapters!.length, (index) {
                return ListTile(
                  title: Text(serie.chapters!.elementAt(index).identifier),
                  trailing: const Icon(Icons.play_arrow),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => VideoPlayerScreen(
                          videoUrl: serie.chapters!.elementAt(index).videoUrls.first,
                          headers: headers,
                        ),
                      ),
                    );
                  },
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}
