import 'dart:io';

import 'package:flutter/material.dart';

import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../const.dart';

import 'package:share/share.dart';

import '../utils/helper.dart';
import 'viewphotos.dart';

final Directory _newPhotoDir = Directory(
    photoDir);

class ImageScreen extends StatefulWidget {
  const ImageScreen({Key? key}) : super(key: key);
  @override
  ImageScreenState createState() => ImageScreenState();
}

class ImageScreenState extends State<ImageScreen> {
  List<String> imageList = [];
  bool isAdLoaded = false;
  late BannerAd _topBannerAd;
  late BannerAd _bottomBannerAd;
  late InterstitialAd _interstitialAd;

  @override
  void initState() {
    super.initState();
    _loadInterstitialAd();
    imageList = _newPhotoDir
        .listSync()
        .map((item) => item.path)
        .where((item) => item.endsWith('.jpg'))
        .toList(growable: false);

    _topBannerAd = BannerAd(
      adUnitId: adUnitId,
      size: AdSize.fluid,
      request: const AdRequest(),
      listener: const BannerAdListener(),
    )..load();

    _bottomBannerAd = BannerAd(
      adUnitId: adUnitId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: const BannerAdListener(),
    )..load();
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
    if (!Directory(_newPhotoDir.path).existsSync()) {
      return Scaffold(
        body: Column(
          children: [
            Image.asset(
              'assets/images/install-whatsapp.jpeg',
            ),
            const SizedBox(height: 10),
            const Text(
              "Your Friend's Status Will Be Available Here",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 22.0, fontWeight: FontWeight.bold),
            ),
            Container(
              margin: const EdgeInsets.symmetric(vertical: 20),
              height: 60,
              child: AdWidget(ad: _bottomBannerAd),
            ),
          ],
        ),
      );
    }
    return Scaffold(
      body: Column(
        children: [
          Container(
            margin: const EdgeInsets.symmetric(vertical: 10),
            height: 70,
            child: AdWidget(ad: _topBannerAd),
          ),
          Expanded(
            child: imageList.isEmpty
                ? Column(children: [
                    Image.asset("assets/images/Photos-rafiki.png"),
                    Text(
                      'Sorry, No Image Found!',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                  ])
                : SingleChildScrollView(
                    child: _buildSelectedItems(),
                  ),
          ),
          Container(
            margin: const EdgeInsets.symmetric(vertical: 4),
            height: 60,
            child: AdWidget(ad: _bottomBannerAd),
          ),
        ],
      ),
    );
  }

  _buildSelectedItems() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: GridView.builder(
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 8.0,
          mainAxisSpacing: 8.0,
        ),
        itemCount: imageList.length,
        itemBuilder: (context, index) {
          String data = imageList[index];
          return Stack(
            children: [
              Container(
                width: MediaQuery.of(context).size.width,
                height: 200,
                decoration: BoxDecoration(
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.grey,
                      spreadRadius: 2,
                      blurRadius: 2,
                      offset: Offset(0, 0),
                    ),
                  ],
                  borderRadius: BorderRadius.circular(20),
                ),
                margin: const EdgeInsets.all(10.0),
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ViewPhotos(
                          imgPath: data,
                        ),
                      ),
                    );
                  },
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Image.file(
                      File(data),
                      fit: BoxFit.cover,
                      filterQuality: FilterQuality.medium,
                    ),
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
                      await _showInterstitialAd(data);
                    } else if (value == 'share') {
                      Share.shareFiles([data], text: 'Check out this file:');
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
}
