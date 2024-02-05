import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:share/share.dart';

import 'package:video_player/video_player.dart';
import '../const.dart';
import '/utils/video_controller.dart';
import 'helper.dart';

class PlayStatus extends StatefulWidget {
  final String videoFile;

  const PlayStatus({
    Key? key,
    required this.videoFile,
  }) : super(key: key);

  @override
  State<PlayStatus> createState() => _PlayStatusState();
}

class _PlayStatusState extends State<PlayStatus> {
  VideoPlayerController? _videoPlayerController;
  @override
  void initState() {
    super.initState();
    _loadInterstitialAd();
    _videoPlayerController = VideoPlayerController.file(File(widget.videoFile))
      ..initialize().then((_) {});
  }

  Future<void> saveVideo() async {
    try {
      final result = await ImageGallerySaver.saveFile(widget.videoFile);
      if (result != null && result['isSuccess'] == true) {

      } else {
        Helper().showToast(context, "Failed To Save Video");
      }
    } catch (e) {
      Helper().showToast(context, "Error While Saving The File Video");
    } finally {
      _videoPlayerController?.dispose();
      Helper().showToast(context, "Video Saved Successfully",);
      Future.delayed(const Duration(milliseconds: 1000),
              () async {
            await _showInterstitialAd();
          });
    }
  }
  bool isAdLoaded = false;

  late InterstitialAd _interstitialAd;


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
    return Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          elevation: 0.0,
          backgroundColor: Colors.transparent,
          leading: IconButton(
            color: Colors.white,
            icon: const Icon(
              Icons.close,
              color: Colors.white,
            ),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        body: SafeArea(
          child: StatusVideo(
            videoPlayerController:
            VideoPlayerController.file(File(widget.videoFile)),
            looping: true,
            videoSrc: widget.videoFile,
          ),
        ),
        floatingActionButton: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            FloatingActionButton(
              child: const Icon(Icons.share_rounded, size: 27),
              onPressed: () async {
                try {
                  Share.shareFiles([widget.videoFile]);
                } catch (e) {
                  print(e);
                }
              },
            ),
            const SizedBox(height: 20),
            FloatingActionButton(
              child: const Icon(Icons.save),
              onPressed: () async {
                await saveVideo();
              },
            ),
            const SizedBox(height: 90),
          ],
        ));
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
