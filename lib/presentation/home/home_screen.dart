import 'package:flutter/material.dart';

import 'widgets/video_feed_item.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Scaffold without AppBar for full-screen experience
    // To allow the system UI (status bar) to overlap the video, we normally
    // use a transparent status bar, or let the app naturally draw behind it.
    return Scaffold(
      backgroundColor: Colors.black,
      body: PageView.builder(
        scrollDirection: Axis.vertical,
        itemCount: 5, // Mock number of items
        itemBuilder: (context, index) {
          return const VideoFeedItem();
        },
      ),
    );
  }
}
