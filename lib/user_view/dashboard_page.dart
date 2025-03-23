import 'package:flutter/material.dart';
import 'common/dummy_playlist.dart';
import 'common/youtube_player_widget.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

import 'desktop_class_ui.dart';
import 'mobile_class_ui.dart';

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
          bool isMobile = constraints.maxWidth < 800;
          return isMobile
              ? MobileClassUI(
            playlist: playlist,
            selectedVideoId: selectedVideoId,
            onVideoSelected: (id) => setState(() {
              selectedVideoId = id;
            }),
          )
              : DesktopClassUI(
            playlist: playlist,
            selectedVideoId: selectedVideoId,
            onVideoSelected: (id) => setState(() {
              selectedVideoId = id;
            }),
          );
        },
      ),
    );
  }
}
