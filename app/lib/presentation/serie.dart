import "package:flutter/material.dart";
import 'package:animebox/core/constants.dart';
import 'package:animebox/domain/series.dart';
import 'package:animebox/presentation/video.dart';

const headers = {"referer": "https://www.yourupload.com/"};

class SerieScreen extends StatelessWidget {
  final Future<Serie> serie;
  const SerieScreen({super.key, required this.serie});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return FutureBuilder(
      future: serie,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator(semanticsLabel: "Loading serie"));
        } else if (snapshot.hasData) {
          var serie = snapshot.data;
          if (serie == null) {
            return Center(child: Text("Serie didn't load"));
          }

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
                    style: Theme.of(
                      context,
                    ).textTheme.titleLarge?.copyWith(color: colorScheme.primary),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    serie.description ?? Placeholders.emptyString,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 24),
                  FutureBuilder(
                    future: serie.getChaptersRemote(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return CircularProgressIndicator(semanticsLabel: "Loading chapters");
                      } else if (snapshot.hasData) {
                        var chapters = snapshot.data;
                        if (chapters == null) {
                          return Center(child: Text("Chapters failed to load"));
                        }
                        serie.chapters = chapters;
                        return ExpansionTile(
                          title: Text("Chapters"),
                          children: List.generate(serie.chapters.length, (index) {
                            return ListTile(
                              title: Text(serie.chapters.elementAt(index).identifier),
                              trailing: const Icon(Icons.play_arrow),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => FutureBuilder(
                                      future: serie.chapters.elementAt(index).getChapterVideoUrls(),
                                      builder: (context, snapshot) {
                                        if (snapshot.connectionState == ConnectionState.waiting) {
                                          return Center(child: Text("Loading Video"));
                                        } else if (snapshot.hasData) {
                                          var chaptersUrls = snapshot.data;
                                          if (chaptersUrls == null) {
                                            return Center(child: Text("Loading video failed"));
                                          }
                                          return VideoPlayerScreen(
                                            videoUrl: chaptersUrls.first,
                                            headers: headers,
                                          );
                                        } else {
                                          return Center(child: Text("Loading video failed"));
                                        }
                                      },
                                    ),
                                  ),
                                );
                              },
                            );
                          }),
                        );
                      } else {
                        return Center(child: Text("Chapters failed to load"));
                      }
                    },
                  ),
                ],
              ),
            ),
          );
        } else {
          return Center(child: Text("Error while loading serie"));
        }
      },
    );
  }
}
