import 'package:flutter/material.dart';

import 'common/youtube_player_widget.dart';

class DesktopClassUI extends StatelessWidget {
  final List<Map<String, String>> playlist;
  final String selectedVideoId;
  final String playListName;
  final Function(String) onVideoSelected;

  const DesktopClassUI({
    required this.playlist,
    required this.selectedVideoId,
    required this.playListName,
    required this.onVideoSelected,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Sidebar Playlist
        Container(
          width: 280,
          color: Colors.blueGrey[900],
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
               Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  playListName,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: playlist.length,
                  itemBuilder: (context, index) {
                    final item = playlist[index];
                    final isSelected = item['videoId'] == selectedVideoId;

                    return GestureDetector(
                      onTap: () => onVideoSelected(item['videoId']!),
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

        // Video Player
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
    );
  }
}