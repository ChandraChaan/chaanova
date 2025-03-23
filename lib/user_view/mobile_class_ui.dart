import 'package:flutter/material.dart';
import 'common/youtube_player_widget.dart';

class MobileClassUI extends StatelessWidget {
  final List<Map<String, String>> playlist;
  final String selectedVideoId;
  final Function(String) onVideoSelected;

  const MobileClassUI({
    required this.playlist,
    required this.selectedVideoId,
    required this.onVideoSelected,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 🎥 Video Player
        AspectRatio(
          aspectRatio: 16 / 9,
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: YoutubePlayerWidget(videoId: selectedVideoId),
            ),
          ),
        ),

        const SizedBox(height: 10),

        // 🎵 Playlist Section Title
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            children: const [
              Text(
                "Class Playlist",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 8),

        // 🎞️ Horizontal Playlist
        Container(
          height: 100,
          margin: const EdgeInsets.only(bottom: 12),
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: playlist.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final item = playlist[index];
              final isSelected = item['videoId'] == selectedVideoId;

              return GestureDetector(
                onTap: () => onVideoSelected(item['videoId']!),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: 180,
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? Colors.amber.withOpacity(0.2)
                        : Colors.blueGrey[800],
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      if (isSelected)
                        BoxShadow(
                          color: Colors.amber.withOpacity(0.4),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                    ],
                    border: Border.all(
                      color: isSelected
                          ? Colors.amber
                          : Colors.transparent,
                      width: 1.5,
                    ),
                  ),
                  child: Row(
                    children: [
                      // Thumbnail
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          'https://img.youtube.com/vi/${item['videoId']}/0.jpg',
                          width: 60,
                          height: 60,
                          fit: BoxFit.cover,
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Title
                      Expanded(
                        child: Text(
                          item['title'] ?? 'Untitled',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: isSelected
                                ? Colors.amber
                                : Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}