import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';

import 'package:url_launcher/url_launcher.dart';

class Helper {
  static final Helper _helper = Helper._internal();
  BuildContext? ctx;

  factory Helper() {
    return _helper;
  }

  Helper._internal();

  setContext(BuildContext context) {
    ctx = context;
  }

  BuildContext getContext() {
    return ctx!;
  }

  void launchURL(String url) async {
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    } else {
      throw 'Could not launch $url';
    }
  }

  void showToast(context, message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(
      message,
      style: TextStyle(
          fontSize: 25, fontFamily: GoogleFonts.grapeNuts().fontFamily),
    )));
  }

  void saveImage(String imgPath, context) async {
    final myUri = Uri.parse(imgPath);
    final originalImageFile = File.fromUri(myUri);
    late Uint8List bytes;
    await originalImageFile.readAsBytes().then((value) {
      bytes = Uint8List.fromList(value);
    }).catchError((onError) {});
    await ImageGallerySaver.saveImage(Uint8List.fromList(bytes));
    showToast(
      context,
      "Image Saved Successfully",
    );
  }
}
