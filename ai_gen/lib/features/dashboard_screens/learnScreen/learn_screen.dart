// ignore_for_file: prefer_const_constructors

import 'dart:convert';
import 'dart:developer';
import 'package:ai_gen/core/translation/translation_keys.dart';
import 'package:ai_gen/core/utils/app_constants.dart';
import 'package:ai_gen/core/utils/themes/app_colors.dart';
import 'package:ai_gen/core/utils/themes/asset_paths.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

class YouTubeApi {
  final String apiKey;
  YouTubeApi({required this.apiKey});

  Future<List<Map<String, dynamic>>> fetchVideosFromPlaylist(
      String playlistId) async {
    try {
      final playlistUrl =
          'https://www.googleapis.com/youtube/v3/playlistItems?part=snippet&maxResults=20&playlistId=$playlistId&key=$apiKey';
      final playlistResponse = await http.get(Uri.parse(playlistUrl));

      if (playlistResponse.statusCode != 200) {
        log('Playlist API Error: ${playlistResponse.statusCode}');
        log('Response body: ${playlistResponse.body}');
        throw Exception(
            '${TranslationKeys.failedToLoadPlaylistVideos.tr}${playlistResponse.statusCode}');
      }

      final playlistJson = json.decode(playlistResponse.body);

      if (playlistJson['items'] == null ||
          (playlistJson['items'] as List).isEmpty) {
        log('No items found in playlist');
        return [];
      }

      final items = playlistJson['items'] as List;

      final videoIds = items
          .where((item) => item['snippet']?['resourceId']?['videoId'] != null)
          .map((item) => item['snippet']['resourceId']['videoId'])
          .join(',');

      if (videoIds.isEmpty) {
        log('No valid video IDs found');
        return items.cast<Map<String, dynamic>>();
      }

      final videoDetailsUrl =
          'https://www.googleapis.com/youtube/v3/videos?part=contentDetails&id=$videoIds&key=$apiKey';
      final videoDetailsResponse = await http.get(Uri.parse(videoDetailsUrl));

      if (videoDetailsResponse.statusCode != 200) {
        log('Video details API Error: ${videoDetailsResponse.statusCode}');
        log('Response body: ${videoDetailsResponse.body}');
        // Continue without durations instead of throwing error
        for (var item in items) {
          item['duration'] = 'N/A';
        }
        return items.cast<Map<String, dynamic>>();
      }

      final videoDetailsJson = json.decode(videoDetailsResponse.body);
      final durations = {
        for (var item in videoDetailsJson['items'] ?? [])
          item['id']: item['contentDetails']['duration']
      };

      for (var item in items) {
        final id = item['snippet']?['resourceId']?['videoId'];
        if (id != null && durations[id] != null) {
          item['duration'] = _formatDuration(durations[id]);
        } else {
          item['duration'] = TranslationKeys.na.tr;
        }
      }

      return items.cast<Map<String, dynamic>>();
    } catch (e) {
      log('Error fetching playlist: $e');
      rethrow;
    }
  }

  String _formatDuration(String isoDuration) {
    final regex = RegExp(r'PT(\d+H)?(\d+M)?(\d+S)?');
    final match = regex.firstMatch(isoDuration);

    if (match == null) return '0:00';

    final hours = match.group(1) != null
        ? int.parse(match.group(1)!.replaceAll('H', ''))
        : 0;
    final minutes = match.group(2) != null
        ? int.parse(match.group(2)!.replaceAll('M', ''))
        : 0;
    final seconds = match.group(3) != null
        ? int.parse(match.group(3)!.replaceAll('S', ''))
        : 0;

    if (hours > 0) {
      return '$hours:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    } else {
      return '$minutes:${seconds.toString().padLeft(2, '0')}';
    }
  }
}

class PlaylistScreen extends StatefulWidget {
  const PlaylistScreen({super.key});

  @override
  State<PlaylistScreen> createState() => _PlaylistScreenState();
}

class _PlaylistScreenState extends State<PlaylistScreen> {
  final String apiKey =
      'AIzaSyCWtlPFdwXBRqWSxtVG8ObtdPul2qKoV_U'; // YOUR_API_KEY

  final String playlistId = 'PLlui7giO4IcRwdgSlG_c7lH2bJssXE29b';

  late YouTubeApi _youtubeApi;
  late Future<List<Map<String, dynamic>>> _playlistVideosFuture;

  bool isGridView = false;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _youtubeApi = YouTubeApi(apiKey: apiKey);
    _playlistVideosFuture = _youtubeApi.fetchVideosFromPlaylist(playlistId);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _launchYouTubeVideo(String videoId) async {
    final Uri youtubeUrl =
        Uri.parse('https://www.youtube.com/watch?v=$videoId');
    if (await canLaunchUrl(youtubeUrl)) {
      await launchUrl(youtubeUrl, mode: LaunchMode.externalApplication);
    }
  }

  List<Map<String, dynamic>> _filterVideos(List<Map<String, dynamic>> videos) {
    if (_searchQuery.isEmpty) return videos;

    return videos.where((video) {
      final title = video['snippet']?['title']?.toString().toLowerCase() ?? '';
      final description =
          video['snippet']?['description']?.toString().toLowerCase() ?? '';
      final query = _searchQuery.toLowerCase();
      return title.contains(query) || description.contains(query);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 76.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),
            // Header Section
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        TranslationKeys.learn.tr,
                        style: const TextStyle(
                          fontFamily: AppConstants.appFontName,
                          fontSize: 48,
                          fontWeight: FontWeight.w700,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        TranslationKeys.learnDescription.tr,
                        style: TextStyle(
                             fontFamily: AppConstants.appFontName,
                          fontWeight: FontWeight.w500,
                          color: Color(0xff666666),
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  color: Colors.transparent,
                  child: Image.asset(
                    AssetsPaths.learnBackground,
                    //  color: Colors.black,
                    height: 187,
                    width: 400,
                    alignment: Alignment.topRight,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 32),

            // Search Bar with Filter Icon
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border:
                      Border.all(color: const Color(0xff999999), width: 1.4),
                ),
                child: TextField(
                  controller: _searchController,
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                  },
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: const Color(0xffF2F2F2),
                    hintText: TranslationKeys.search.tr,
                    hintStyle: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontFamily: AppConstants.appFontName,
                      fontSize: 16,
                      color: Color(0xff666666),
                    ),
                    prefixIcon:
                        const Icon(Icons.search, color: Color(0xff666666)),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.tune, color: Colors.grey),
                      onPressed: () {
                        // Add filter functionality here
                      },
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // View Toggle Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () => setState(() => isGridView = false),
                        icon: Icon(
                          Icons.view_list,
                          color: !isGridView ? Colors.blue : Colors.grey,
                        ),
                      ),
                      Container(
                        width: 1,
                        height: 24,
                        color: Colors.grey.shade300,
                      ),
                      IconButton(
                        onPressed: () => setState(() => isGridView = true),
                        icon: Icon(
                          Icons.grid_view,
                          color: isGridView ? Colors.blue : Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Videos List
            Expanded(
              child: FutureBuilder<List<Map<String, dynamic>>>(
                future: _playlistVideosFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                        child: CircularProgressIndicator(
                      color: AppColors.bluePrimaryColor,
                    ));
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(
                        child: Text(TranslationKeys.noVideosFound.tr));
                  }

                  final videos = _filterVideos(snapshot.data!);

                  if (videos.isEmpty) {
                    return Center(
                        child: Text(TranslationKeys.noVideosMatchSearch.tr));
                  }

                  return isGridView
                      ? GridView.builder(
                          itemCount: videos.length,
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: 1.2,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                          ),
                          itemBuilder: (context, index) =>
                              _buildVideoCard(videos[index], isGrid: true),
                        )
                      : ListView.separated(
                          itemCount: videos.length,
                          separatorBuilder: (context, index) =>
                              const SizedBox(height: 16),
                          itemBuilder: (context, index) =>
                              _buildVideoCard(videos[index]),
                        );
                },
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildVideoCard(Map<String, dynamic> video, {bool isGrid = false}) {
    final snippet = video['snippet'];
    if (snippet == null) return const SizedBox.shrink();

    final resourceId = snippet['resourceId'];
    if (resourceId == null) return const SizedBox.shrink();

    final videoId = resourceId['videoId'];
    if (videoId == null) return const SizedBox.shrink();

    final title = snippet['title'] ?? 'No Title';
    final description = snippet['description'] ?? 'No Description';
    final thumbnails = snippet['thumbnails'];
    final thumbnailUrl =
        thumbnails?['medium']?['url'] ?? thumbnails?['default']?['url'] ?? '';
    final duration = video['duration'] ?? 'N/A';

    // Determine category based on video content
    String category = 'Basics';
    //Color categoryColor = Colors.green.shade100;
    Color categoryTextColor = Colors.green;

    if (title.toLowerCase().contains('dataset') ||
        title.toLowerCase().contains('data')) {
      category = 'Dataset';
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 80),
      child: InkWell(
        onTap: () => _launchYouTubeVideo(videoId),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xffF2F2F2),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: const Color(0xff999999),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                spreadRadius: 0,
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: isGrid
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Three dots menu at the top
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          PopupMenuButton(
                            icon: const Icon(Icons.more_horiz,
                                color: Colors.grey, size: 20),
                            itemBuilder: (context) => [
                              const PopupMenuItem(
                                value: 'watch_later',
                                child: Text('Watch Later'),
                              ),
                              PopupMenuItem(
                                value: TranslationKeys.share.tr,
                                child: Text(TranslationKeys.share.tr),
                              ),
                            ],
                          ),
                        ],
                      ),
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Stack(
                            children: [
                              if (thumbnailUrl.isNotEmpty)
                                Image.network(
                                  thumbnailUrl,
                                  width: double.infinity,
                                  height: double.infinity,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      color: Colors.grey.shade300,
                                      child: const Icon(
                                          Icons.play_circle_outline,
                                          size: 50),
                                    );
                                  },
                                )
                              else
                                Container(
                                  color: Colors.grey.shade300,
                                  child: const Icon(Icons.play_circle_outline,
                                      size: 50),
                                ),
                              Positioned(
                                bottom: 8,
                                right: 8,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: Colors.black87,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    duration,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.transparent,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              category,
                              style: TextStyle(
                                color: categoryTextColor,
                                fontSize: 10,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  )
                : Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Stack(
                          children: [
                            if (thumbnailUrl.isNotEmpty)
                              Image.network(
                                thumbnailUrl,
                                width: 160,
                                height: 120,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    width: 160,
                                    height: 90,
                                    color: Colors.grey.shade300,
                                    child: const Icon(Icons.play_circle_outline,
                                        size: 30),
                                  );
                                },
                              )
                            else
                              Container(
                                width: 160,
                                height: 90,
                                color: Colors.grey.shade300,
                                child: const Icon(Icons.play_circle_outline,
                                    size: 30),
                              ),
                            Positioned(
                              bottom: 6,
                              right: 6,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.black87,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  duration,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Three dots menu at the top right
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Text(
                                    title,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                      height: 1.3,
                                    ),
                                  ),
                                ),
                                PopupMenuButton(
                                  icon: const Icon(Icons.more_horiz,
                                      color: Colors.grey),
                                  itemBuilder: (context) => [
                                    PopupMenuItem(
                                      value: TranslationKeys.watchLater.tr,
                                      child:
                                          Text(TranslationKeys.watchLater.tr),
                                    ),
                                    PopupMenuItem(
                                      value: TranslationKeys.share.tr,
                                      child: Text(
                                        TranslationKeys.share.tr,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              description.length > 100
                                  ? '${description.substring(0, 100)}...'
                                  : description,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade600,
                                height: 1.4,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.transparent,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                category,
                                style: TextStyle(
                                  color: categoryTextColor,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}
