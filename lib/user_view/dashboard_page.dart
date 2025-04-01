import 'package:flutter/material.dart';
import 'common/dummy_playlist.dart';
import 'common/youtube_player_widget.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

import 'desktop_class_ui.dart';
import 'mobile_class_ui.dart';

class DashboardPage extends StatefulWidget {
  final String playListId;
  final String playListName;

  const DashboardPage({super.key, required this.playListId, required this.playListName});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  String selectedVideoId = '';
  List<Map<String, String>> playlist = [];
  bool isLoading = false;

  Future<List<Map<String, String>>> fetchYouTubeVideos(String playlistId) async {
    final apiUrl =
        'https://www.googleapis.com/youtube/v3/playlistItems?part=snippet&maxResults=50&playlistId=$playlistId&key=AIzaSyCoaEo4-jRKUXhLTIWmxd1AFTqCeanAo5g';

    final response = await http.get(Uri.parse(apiUrl));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      final videos = (data['items'] as List)
          .where((item) => item['snippet']?['resourceId']?['videoId'] != null)
          .map<Map<String, String>>((item) {
        return {
          "title": item['snippet']['title'],
          "videoId": item['snippet']['resourceId']['videoId'],
        };
      }).toList();

      return videos;
    } else {
      throw Exception("Failed to fetch YouTube videos");
    }
  }

  Future<void> loadVideos() async {
    try {
      setState(() => isLoading = true);
      playlist = await fetchYouTubeVideos(widget.playListId);
      if (playlist.isNotEmpty) {
        selectedVideoId = playlist.first['videoId']!;
      }
      setState(() => isLoading = false);
    } catch (e) {
      print("❌ Failed to load videos: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to load videos")),
      );
      setState(() => isLoading = false);
    }
  }

  @override
  void initState() {
    super.initState();
    loadVideos();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white,),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Enhance - Online Classes",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: Colors.white),
        ),
        backgroundColor: Colors.blueGrey[800],
        elevation: 5,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : playlist.isEmpty
          ? const Center(child: Text("No videos found in this playlist."))
          : LayoutBuilder(
        builder: (context, constraints) {
          bool isMobile = constraints.maxWidth < 800;
          return isMobile
              ? MobileClassUI(
            playlist: playlist,
            playListName: widget.playListName,
            selectedVideoId: selectedVideoId,
            onVideoSelected: (id) => setState(() {
              selectedVideoId = id;
            }),
          )
              : DesktopClassUI(
            playlist: playlist,
            playListName: widget.playListName,
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