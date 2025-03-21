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
        title: const Text("Chaanova - Online Classes"),
        backgroundColor: Colors.blueGrey,
      ),
      body: Row(
        children: [
          // Sidebar
          Container(
            width: 250,
            color: Colors.grey[200],
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text(
                    "Class Playlist",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: dummyPlaylist.length,
                    itemBuilder: (context, index) {
                      final item = dummyPlaylist[index];
                      return ListTile(
                        title: Text(item['title']!),
                        onTap: () {
                          setState(() {
                            selectedVideoId = item['videoId']!;
                          });
                        },
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
              color: Colors.white,
              child: YoutubePlayerWidget(videoId: selectedVideoId),
            ),
          ),
        ],
      ),
    );
  }
}