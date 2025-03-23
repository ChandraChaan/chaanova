import 'package:flutter/material.dart';
import 'common/dummy_playlist.dart';
import 'common/youtube_player_widget.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  String selectedVideoId = 'DaAuuN7v1z8';

  Future<List<Map<String, String>>> fetchYouTubeVideos() async {
    const apiUrl =
        'https://www.googleapis.com/youtube/v3/search?order=date&part=snippet&channelId=UCZbAhPj18mNveRPnZE6YDvg&maxResults=100&key=AIzaSyCoaEo4-jRKUXhLTIWmxd1AFTqCeanAo5g';

    final response = await http.get(Uri.parse(apiUrl));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      final videos = (data['items'] as List)
          .where((item) => item['id']?['videoId'] != null)
          .map<Map<String, String>>((item) {
        return {
          "title": item['snippet']['title'],
          "videoId": item['id']['videoId'],
        };
      }).toList();

      return videos;
    } else {
      throw Exception("Failed to fetch YouTube videos");
    }
  }

  List<Map<String, String>> playlist = [];

  @override
  void initState() {
    super.initState();
    loadVideos();
  }

  Future<void> loadVideos() async {
    try {
      playlist = await fetchYouTubeVideos();
      // dummyPlaylist.clear();
      // dummyPlaylist.addAll(playlist);
      selectedVideoId = playlist.first['videoId']!;

      setState(() {});
    } catch (e) {
      print("❌ Failed to load videos: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Chaanova - Online Classes",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.blueGrey[800],
        elevation: 5,
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          bool isMobile = constraints.maxWidth < 800; // Responsive check

          return Column(
            children: [
              Expanded(
                child: Row(
                  children: [
                    // Sidebar - Playlist (Only for Desktop)
                    if (!isMobile)
                      Container(
                        width: 280,
                        color: Colors.blueGrey[900],
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Title
                            Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Text(
                                "Class Playlist",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),

                            // Video List
                            Expanded(
                              child: ListView.builder(
                                itemCount: playlist.length,
                                itemBuilder: (context, index) {
                                  final item = playlist[index];
                                  final isSelected =
                                      item['videoId'] == selectedVideoId;

                                  return GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        selectedVideoId = item['videoId']!;
                                      });
                                    },
                                    child: Container(
                                      margin: const EdgeInsets.symmetric(
                                          horizontal: 10, vertical: 5),
                                      decoration: BoxDecoration(
                                        color: isSelected
                                            ? Colors.blueGrey[700]
                                            : Colors.blueGrey[800],
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: ListTile(
                                        title: Text(
                                          item['title']!,
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 1,
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: isSelected
                                                ? FontWeight.bold
                                                : FontWeight.normal,
                                          ),
                                        ),
                                        leading: Icon(
                                          Icons.play_circle_filled,
                                          color: isSelected
                                              ? Colors.amberAccent
                                              : Colors.white70,
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),

                    // Video Player Area
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(16.0),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: YoutubePlayerWidget(videoId: selectedVideoId),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Playlist for Mobile - Scrollable at the bottom
              if (isMobile)
                Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                  color: Colors.blueGrey[900],
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: playlist.map((item) {
                        final isSelected = item['videoId'] == selectedVideoId;
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              selectedVideoId = item['videoId']!;
                            });
                          },
                          child: Container(
                            margin: const EdgeInsets.symmetric(horizontal: 6),
                            padding: const EdgeInsets.symmetric(
                                vertical: 6, horizontal: 12),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? Colors.amber
                                  : Colors.blueGrey[700],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              item['title']!,
                              style: TextStyle(
                                color: isSelected ? Colors.black : Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
