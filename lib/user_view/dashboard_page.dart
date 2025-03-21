import 'package:flutter/material.dart';
import 'common/dummy_playlist.dart';
import 'common/youtube_player_widget.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  String selectedVideoId = dummyPlaylist.first['videoId']!;

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
      body: Row(
        children: [
          // Sidebar - Playlist
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
                    itemCount: dummyPlaylist.length,
                    itemBuilder: (context, index) {
                      final item = dummyPlaylist[index];
                      final isSelected = item['videoId'] == selectedVideoId;

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
              color: Colors.grey[200],
              child: Column(
                children: [
                  // Video Player
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: YoutubePlayerWidget(videoId: selectedVideoId),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}