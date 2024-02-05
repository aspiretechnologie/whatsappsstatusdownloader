import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:share/share.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

import '../const.dart';
import '../utils/helper.dart';
import '../utils/video_play.dart';

final Directory _videoDir = Directory(photoDir);
bool isAdLoaded = false;

late InterstitialAd _interstitialAd;

class VideoScreen extends StatefulWidget {
  const VideoScreen({Key? key}) : super(key: key);
  @override
  VideoScreenState createState() => VideoScreenState();
}

class VideoScreenState extends State<VideoScreen> {
  @override
  Widget build(BuildContext context) {
    if (!Directory(_videoDir.path).existsSync()) {
      return Column(
        children: [
          Image.asset(
            'assets/images/install-whatsapp.jpeg',
          ),
          const SizedBox(
            height: 20,
          ),
          const Text(
            "Your Friend's Status Will Be Available Here",
            style: TextStyle(fontSize: 22.0, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
        ],
      );
    } else {
      return VideoGrid(directory: _videoDir);
    }
  }
}

class VideoGrid extends StatefulWidget {
  final Directory? directory;

  const VideoGrid({Key? key, this.directory}) : super(key: key);

  @override
  State<VideoGrid> createState() => _VideoGridState();
}

class _VideoGridState extends State<VideoGrid> {
  Future<String?> _getImage(videoPathUrl) async {
    final thumb = await VideoThumbnail.thumbnailFile(video: videoPathUrl);
    return thumb;
  }

  late BannerAd _bottomBannerAd;

  @override
  void initState() {
    _loadInterstitialAd();
    _bottomBannerAd = BannerAd(
      adUnitId: adUnitId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: const BannerAdListener(),
    )..load();
    super.initState();
  }

  void _loadInterstitialAd() {
    InterstitialAd.load(
      adUnitId: adUnitIdInterstitial,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (InterstitialAd ad) {
          setState(() {
            isAdLoaded = true;
          });
          _interstitialAd = ad;
        },
        onAdFailedToLoad: (LoadAdError error) {},
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final videoList = widget.directory!
        .listSync()
        .map((item) => item.path)
        .where((item) => item.endsWith('.mp4'))
        .toList(growable: false);

    return Scaffold(
      body: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 15.0),
        child: videoList.isEmpty
            ? Column(children: [
                Image.asset("assets/images/Video tutorial-bro.png"),
                Text(
                  'Sorry, No Videos Found.',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
              ])
            : GridView.builder(
                itemCount: videoList.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 1,
                  childAspectRatio: 1.65,
                  mainAxisSpacing: 8.0,
                ),
                itemBuilder: (context, index) {
                  return Stack(
                    children: [
                      InkWell(
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PlayStatus(
                              videoFile: videoList[index],
                            ),
                          ),
                        ),
                        child: ClipRRect(
                          borderRadius:
                              const BorderRadius.all(Radius.circular(12)),
                          child: Container(
                            width: MediaQuery.of(context).size.width,
                            height: 400,
                            decoration: const BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.bottomLeft,
                                end: Alignment.topRight,
                                stops: [0.1, 0.3, 0.5, 0.7, 0.9],
                                colors: [
                                  Color(0xffb7d8cf),
                                  Color(0xffb7d8cf),
                                  Color(0xffb7d8cf),
                                  Color(0xffb7d8cf),
                                  Color(0xffb7d8cf),
                                ],
                              ),
                            ),
                            child: FutureBuilder<String?>(
                                future: _getImage(videoList[index]),
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState ==
                                      ConnectionState.done) {
                                    if (snapshot.hasData) {
                                      return Hero(
                                        tag: videoList[index],
                                        child: Image.file(
                                          File(snapshot.data!),
                                          fit: BoxFit.cover,
                                        ),
                                      );
                                    } else {
                                      return const Center(
                                        child: CircularProgressIndicator(),
                                      );
                                    }
                                  } else {
                                    return Hero(
                                      tag: videoList[index],
                                      child: SizedBox(
                                        height: 280.0,
                                        child: Image.asset(
                                            'assets/images/video_loader.gif'),
                                      ),
                                    );
                                  }
                                }),
                            //new cod
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 7,
                        right: 0,
                        child: PopupMenuButton<String>(
                          icon: const Icon(Icons.more_vert, size: 27),
                          onSelected: (value) async {
                            if (value == 'save') {
                              final result = await ImageGallerySaver.saveFile(
                                  videoList[index]);
                              if (result != null &&
                                  result['isSuccess'] == true) {
                                Helper().showToast(
                                    context, "Video Saved Successfully");
                                Future.delayed(
                                    const Duration(milliseconds: 1000),
                                    () async {
                                  await _showInterstitialAd();
                                });
                              }
                            } else if (value == 'share') {
                              Share.shareFiles(
                                [videoList[index]],
                              );
                            }
                          },
                          itemBuilder: (BuildContext context) => [
                            const PopupMenuItem<String>(
                              value: 'save',
                              child: Row(
                                children: [
                                  Icon(Icons.save),
                                  SizedBox(width: 8),
                                  Text('Save'),
                                ],
                              ),
                            ),
                            const PopupMenuItem<String>(
                              value: 'share',
                              child: Row(
                                children: [
                                  Icon(Icons.share),
                                  SizedBox(width: 8),
                                  Text('Share'),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),
      ),
      bottomNavigationBar: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        height: 50,
        child: AdWidget(ad: _bottomBannerAd),
      ),
    );
  }

  _showInterstitialAd() async {
    if (isAdLoaded) {
      _interstitialAd.fullScreenContentCallback = FullScreenContentCallback(
        onAdShowedFullScreenContent: (InterstitialAd ad) {},
        onAdDismissedFullScreenContent: (InterstitialAd ad) {
          _loadInterstitialAd();
        },
        onAdFailedToShowFullScreenContent: (InterstitialAd ad, AdError error) {
          _loadInterstitialAd();
        },
      );
      await _interstitialAd.show();
    } else {}
  }
}
