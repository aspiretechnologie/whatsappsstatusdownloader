import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'package:share/share.dart';

import '../const.dart';
import '../utils/helper.dart';

class ViewPhotos extends StatefulWidget {
  final String imgPath;
  const ViewPhotos({
    Key? key,
    required this.imgPath,
  }) : super(key: key);

  @override
  State<ViewPhotos> createState() => _ViewPhotosState();
}

class _ViewPhotosState extends State<ViewPhotos> {
  var filePath;
  final String imgShare = 'Image.file(File(widget.imgPath),)';

  final LinearGradient backgroundGradient = const LinearGradient(
    colors: [
      Color(0x00000000),
      Color(0x00333333),
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  bool isAdLoaded = false;
  late InterstitialAd _interstitialAd;
  @override
  void initState() {
    _loadInterstitialAd();
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

  _showInterstitialAd(data) async {
    if (isAdLoaded) {
      _interstitialAd.fullScreenContentCallback = FullScreenContentCallback(
        onAdShowedFullScreenContent: (InterstitialAd ad) {},
        onAdDismissedFullScreenContent: (InterstitialAd ad) {
          Helper().saveImage(data, context);
          _loadInterstitialAd();
        },
        onAdFailedToShowFullScreenContent: (InterstitialAd ad, AdError error) {
          _loadInterstitialAd();
        },
      );
      await _interstitialAd.show();
    } else {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.black12,
        appBar: AppBar(
          elevation: 0.0,
          backgroundColor: Colors.transparent,
          leading: IconButton(
            color: Colors.indigo,
            icon: const Icon(
              Icons.close,
              color: Colors.white,
            ),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        body: Center(
          child: Image.file(
            File(widget.imgPath),
            fit: BoxFit.cover,
          ),
        ),
        floatingActionButton: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            FloatingActionButton(
              child: const Icon(Icons.share),
              onPressed: () async {
                Share.shareFiles(
                  [widget.imgPath],
                );
              },
            ),
            const SizedBox(height: 20),
            FloatingActionButton(
              child: const Icon(Icons.save),
              onPressed: () async {
                _showInterstitialAd(widget.imgPath);
              },
            ),
            const SizedBox(height: 20),
          ],
        ));
  }
}
