import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:unsplash_client/unsplash_client.dart';
import 'package:wifi_demo/full_image.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final client = UnsplashClient(
    settings: const ClientSettings(
      credentials: AppCredentials(
        accessKey: 'qh51WdyRSZ1JzBbGTzWxqYOTu9rHhEBS-yxNBgRvAGg',
        secretKey: 'NZF2Sbf5ak3c5pDRFYLEHD-iEFVLyXL9-G_YxUws_C4',
      ),
    ),
  );

  List<Photo> photoList = [];
  final ScrollController _scrollController = ScrollController();
  bool isLoading = false;

  String errorShow = "";

  @override
  void initState() {
    super.initState();
    getPhotos();
    _scrollController.addListener(_scrollListener);
  }

  Future<void> getPhotos() async {
    if (isLoading) return;

    setState(() {
      isLoading = true;
    });

    try {
      final photos = await client.photos.random(count: 30).goAndGet();
      setState(() {
        photoList.addAll(photos);
        isLoading = false;
      });
    } catch (e) {
      log('Error fetching photos: $e');

      setState(() {
        isLoading = false;
        errorShow = e.toString();
      });
    }
  }

  String _getAppBarTitle(double screenWidth) {
    if (screenWidth >= 1024) {
      return 'Desktop View';
    } else if (screenWidth >= 600) {
      return 'Tablet View';
    } else {
      return 'Mobile View';
    }
  }

  void _scrollListener() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent * 0.8 &&
        !isLoading) {
      getPhotos();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            if (errorShow.isNotEmpty) {
              return Center(
                child: Text(
                  errorShow,
                  style: const TextStyle(
                    color: Colors.red,
                    fontSize: 18,
                  ),
                  textAlign: TextAlign.center,
                ),
              );
            }

            return CustomScrollView(
              controller: _scrollController,
              slivers: [
                SliverAppBar(
                  expandedHeight: 200.0,
                  floating: false,
                  pinned: true,
                  // backgroundColor: Colors.amber,
                  flexibleSpace: FlexibleSpaceBar(
                    title: Text(
                      _getAppBarTitle(constraints.maxWidth),
                      style: const TextStyle(fontSize: 18),
                    ),
                    background: ClipRRect(
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(40),
                        bottomRight: Radius.circular(40),
                      ),
                      child: Image.network(
                        'https://images.unsplash.com/photo-1726392660865-cbf2dc1459b6?q=80&w=1975&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.all(8.0),
                  sliver: SliverGrid(
                    gridDelegate:
                        const SliverGridDelegateWithMaxCrossAxisExtent(
                      maxCrossAxisExtent: 300,
                      mainAxisSpacing: 16,
                      crossAxisSpacing: 16,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        if (index == photoList.length) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }
                        final photo = photoList[index];
                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => FullImageView(
                                  imageUrl: photo.urls.small.toString(),
                                ),
                              ),
                            );
                          },
                          child: Hero(
                            tag: "image",
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Image.network(
                                photo.urls.small.toString(),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        );
                      },
                      childCount: photoList.length + (isLoading ? 1 : 0),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
