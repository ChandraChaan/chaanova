import 'package:flutter/material.dart';

class PlaylistSidebar extends StatelessWidget {
  final Function(String videoId) onVideoSelected;
  final List playlist;

  const PlaylistSidebar({super.key, required this.onVideoSelected, required this.playlist});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 250,
      color: Colors.grey[100],
      child: ListView(
        children: playlist.map((item) {
          return ListTile(
            title: Text(item['title']!),
            onTap: () => onVideoSelected(item['videoId']!),
          );
        }).toList(),
      ),
    );
  }
}