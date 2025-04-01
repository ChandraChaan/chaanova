import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'dashboard_page.dart';

class FolderPage extends StatefulWidget {
  const FolderPage({super.key});

  @override
  State<FolderPage> createState() => _FolderPageState();
}

class _FolderPageState extends State<FolderPage> {
  List<Map<String, String>> playlists = [];
  bool isLoading = false;

  Future<void> fetchChannelPlaylists() async {
    setState(() => isLoading = true);

    const channelId = 'UCZbAhPj18mNveRPnZE6YDvg';
    const apiKey = 'AIzaSyCoaEo4-jRKUXhLTIWmxd1AFTqCeanAo5g';
    final url =
        'https://www.googleapis.com/youtube/v3/playlists?part=snippet&channelId=$channelId&maxResults=50&key=$apiKey';

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final fetched = (data['items'] as List).map<Map<String, String>>((item) {
          final snippet = item['snippet'];
          return {
            'id': item['id'],
            'title': snippet['title'],
            'thumbnail': snippet['thumbnails']['medium']?['url'] ??
                snippet['thumbnails']['default']?['url'] ??
                'https://via.placeholder.com/320x180.png?text=No+Thumbnail',
          };
        }).toList();

        setState(() => playlists = fetched);
      } else {
        throw Exception("Failed to load playlists");
      }
    } catch (e) {
      print("❌ Error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load playlists')),
      );
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  void initState() {
    super.initState();
    fetchChannelPlaylists();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Folders'),
        backgroundColor: Colors.blueGrey[900],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : GridView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: playlists.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 16 / 9,
        ),
        itemBuilder: (context, index) {
          final playlist = playlists[index];
          return GestureDetector(
            onTap: () {
              print("📂 Clicked playlist: ${playlist['title']}");
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => DashboardPage(playListId: "${playlist['id']}",)),
              );
            },
            child: Container(
              decoration: BoxDecoration(
                color: Colors.blueGrey[800],
                borderRadius: BorderRadius.circular(12),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 4,
                    offset: Offset(2, 2),
                  )
                ],
              ),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      playlist['thumbnail']!,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      gradient: LinearGradient(
                        colors: [
                          Colors.black.withOpacity(0.6),
                          Colors.transparent,
                        ],
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                      ),
                    ),
                    alignment: Alignment.bottomLeft,
                    padding: const EdgeInsets.all(12),
                    child: Text(
                      playlist['title'] ?? '',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}