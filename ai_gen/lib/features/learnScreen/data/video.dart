// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'package:youtube_player_flutter/youtube_player_flutter.dart';

// class YouTubeApi {
//   final String apiKey;

//   YouTubeApi({required this.apiKey});

//   /// Fetches videos from a specific YouTube playlist.
//   /// Returns a list of maps, where each map represents a video.
//   Future<List<Map<String, dynamic>>> fetchVideosFromPlaylist(
//       String playlistId) async {
//     final String url =
//         'https://www.googleapis.com/youtube/v3/playlistItems?part=snippet&playlistId=$playlistId&key=$apiKey&maxResults=50';

//     try {
//       final response = await http.get(Uri.parse(url));

//       if (response.statusCode == 200) {
//         final Map<String, dynamic> data = json.decode(response.body);
//         return List<Map<String, dynamic>>.from(data['items']);
//       } else {
//         // Handle different error codes from YouTube API
//         print(
//             'Failed to load videos from playlist. Status code: ${response.statusCode}');
//         print('Response body: ${response.body}');
//         throw Exception(
//             'Failed to load videos from playlist: ${response.statusCode}. Check your API key and playlist ID.');
//       }
//     } catch (e) {
//       print('Error fetching videos: $e');
//       throw Exception(
//           'Error fetching videos: $e. Please check your internet connection and API key/playlist ID.');
//     }
//   }
// }
// class PlaylistScreen extends StatefulWidget {
//   const PlaylistScreen({super.key});

//   @override
//   State<PlaylistScreen> createState() => _PlaylistScreenState();
// }

// class _PlaylistScreenState extends State<PlaylistScreen> {
//   final String apiKey =
//       'AIzaSyCWtlPFdwXBRqWSxtVG8ObtdPul2qKoV_U'; // YOUR_API_KEY
//   // **IMPORTANT: REPLACE THIS WITH YOUR ACTUAL YOUTUBE PLAYLIST ID**
//   // Example: 'PLFGbC8G3-M1Tz1wB501h1jJ9wM7jB2L3F'
//   final String playlistId = 'YOUR_PLAYLIST_ID';

//   late YouTubeApi _youtubeApi;
//   late Future<List<Map<String, dynamic>>> _playlistVideosFuture;

//   @override
//   void initState() {
//     super.initState();
//     _youtubeApi = YouTubeApi(apiKey: apiKey);
//     _playlistVideosFuture = _youtubeApi.fetchVideosFromPlaylist(playlistId);
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('YouTube Playlist'),
//       ),
//       body: FutureBuilder<List<Map<String, dynamic>>>(
//         future: _playlistVideosFuture,
//         builder: (context, snapshot) {
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return const Center(child: CircularProgressIndicator());
//           } else if (snapshot.hasError) {
//             return Center(child: Text('Error: ${snapshot.error}'));
//           } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
//             return const Center(
//                 child: Text(
//                     'No videos found in the playlist or invalid playlist ID.'));
//           } else {
//             final videos = snapshot.data!;
//             return ListView.builder(
//               itemCount: videos.length,
//               itemBuilder: (context, index) {
//                 final videoSnippet = videos[index]['snippet'];
//                 final videoTitle = videoSnippet['title'];
//                 final videoThumbnailUrl =
//                     videoSnippet['thumbnails']['medium']['url'];
//                 final videoId = videoSnippet['resourceId']['videoId'];

//                 return Card(
//                   margin: const EdgeInsets.all(8.0),
//                   child: InkWell(
//                     onTap: () {
//                       Navigator.push(
//                         context,
//                         MaterialPageRoute(
//                           builder: (context) => VideoPlayerScreen(
//                             videoId: videoId,
//                             videoTitle: videoTitle,
//                           ),
//                         ),
//                       );
//                     },
//                     child: Padding(
//                       padding: const EdgeInsets.all(8.0),
//                       child: Row(
//                         children: [
//                           Image.network(
//                             videoThumbnailUrl,
//                             width: 120,
//                             height: 90,
//                             fit: BoxFit.cover,
//                           ),
//                           const SizedBox(width: 10),
//                           Expanded(
//                             child: Text(
//                               videoTitle,
//                               style: const TextStyle(
//                                 fontSize: 16,
//                                 fontWeight: FontWeight.bold,
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                 );
//               },
//             );
//           }
//         },
//       ),
//     );
//   }
// }

// class VideoPlayerScreen extends StatefulWidget {
//   final String videoId;
//   final String videoTitle;

//   const VideoPlayerScreen({
//     super.key,
//     required this.videoId,
//     required this.videoTitle,
//   });

//   @override
//   State<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
// }

// class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
//   late YoutubePlayerController _controller;

//   @override
//   void initState() {
//     super.initState();
//     _controller = YoutubePlayerController(
//       initialVideoId: widget.videoId,
//       flags: const YoutubePlayerFlags(
//         autoPlay: true,
//         mute: false,
//         disableDragSeek: false,
//         loop: false,
//         isLive: false,
//         forceHD: false,
//         enableCaption: true,
//       ),
//     )..addListener(listener); // Add a listener for player state changes
//   }

//   void listener() {
//     if (_controller.value.playerState == PlayerState.ended) {
//       // You can add logic here for when the video ends, e.g., navigate back
//       print('Video ended!');
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return YoutubePlayerBuilder(
//       player: YoutubePlayer(
//         controller: _controller,
//         showVideoProgressIndicator: true,
//         progressIndicatorColor: Colors.blueAccent,
//         onReady: () {
//           print('Player is ready.');
//         },
//         bottomActions: [
//           CurrentPosition(),
//           ProgressBar(isExpanded: true),
//           RemainingDuration(),
//           FullScreenButton(),
//         ],
//       ),
//       builder: (context, player) {
//         return Scaffold(
//           appBar: AppBar(
//             title: Text(widget.videoTitle),
//           ),
//           body: Column(
//             children: [
//               player, // The YouTube player widget
//               Padding(
//                 padding: const EdgeInsets.all(8.0),
//                 child: Text(
//                   widget.videoTitle,
//                   style: const TextStyle(
//                     fontSize: 20,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//               ),
//               // You can add more video details or controls here
//             ],
//           ),
//         );
//       },
//     );
//   }

//   @override
//   void dispose() {
//     _controller.dispose(); // Dispose the controller to prevent memory leaks
//     super.dispose();
//   }
// }
