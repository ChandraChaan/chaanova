import 'package:flutter/material.dart';
import 'dummy_playlist.dart';

class PlaylistSidebar extends StatelessWidget {
  final Function(String videoId) onVideoSelected;

  const PlaylistSidebar({super.key, required this.onVideoSelected});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 250,
      color: Colors.grey[100],
      child: ListView(
        children: dummyPlaylist.map((item) {
          return ListTile(
            title: Text(item['title']!),
            onTap: () => onVideoSelected(item['videoId']!),
          );
        }).toList(),
      ),
    );
  }
}