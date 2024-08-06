import 'dart:typed_data';

import 'package:audioplayers/audioplayers.dart';
import 'package:cached_s5_manager/cached_s5_manager.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:s5/s5.dart';

class CachedS5Audio extends StatefulWidget {
  final String cid;
  final S5 s5;
  final CachedS5Manager? cacheManager;
  const CachedS5Audio(
      {super.key, required this.cid, required this.s5, this.cacheManager});

  @override
  State<CachedS5Audio> createState() => CachedS5AudioState();
}

class CachedS5AudioState extends State<CachedS5Audio> {
  Uint8List? audioBytes;
  final player = AudioPlayer();
  Logger logger = Logger();
  int position = 0;
  late CachedS5Manager cacheManager;

  // This grabs the contents of the CID
  _populateAudioFromCID() async {
    // FI
    Uint8List audioBytesLoc = await cacheManager.getBytesFromCID(widget.cid);
    await player.setSourceBytes(audioBytesLoc);
    setState(() {
      audioBytes = audioBytesLoc;
    });
    player.onPositionChanged.listen((event) {
      // keep the setstates to 1 per second to keep redraws to a min
      if (event.inSeconds != position) {
        setState(() {
          position = event.inSeconds;
        });
      }
    });
  }

  _playPause() async {
    if (player.state == PlayerState.playing) {
      await player.pause();
      setState(() {});
    } else {
      await player.resume();
      setState(() {});
    }
  }

  @override
  void initState() {
    cacheManager = CachedS5Manager(s5: widget.s5);
    _populateAudioFromCID();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Center(
          child: (audioBytes != null)
              ? IconButton(
                  onPressed: _playPause,
                  icon: Icon((player.state == PlayerState.playing)
                      ? Icons.pause
                      : Icons.play_arrow))
              : CircularProgressIndicator(),
        ),
      ],
    );
  }
}
