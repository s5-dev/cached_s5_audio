import 'dart:typed_data';

import 'package:audioplayers/audioplayers.dart';
import 'package:cached_s5_manager/cached_s5_manager.dart';
import 'package:flutter/foundation.dart';
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
  Duration? _duration;
  Duration? _position;
  late CachedS5Manager cacheManager;
  String get _durationText => _duration?.toString().split('.').first ?? '';
  String get _positionText => _position?.toString().split('.').first ?? '';

  @override
  void initState() {
    cacheManager = CachedS5Manager(s5: widget.s5);
    _populateAudioFromCID();
    super.initState();
  }

  // This grabs the contents of the CID
  _populateAudioFromCID() async {
    Uint8List audioBytesLoc = await cacheManager.getBytesFromCID(widget.cid);
    await player.setSourceBytes(audioBytesLoc);
    setState(() {
      audioBytes = audioBytesLoc;
    });
    player.onDurationChanged.listen((duration) => setState(() {
          _duration = duration;
        }));
    player.onPositionChanged.listen((event) async {
      // keep the setstates to 1 per second to keep redraws to a min
      if (event != _position) {
        setState(() {
          _position = event;
        });
      }
    });
  }

  // Toggles play and pause based on current state
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
        Stack(
          children: [
            Slider(
              onChanged: (value) {
                final duration = _duration;
                if (duration == null) {
                  return;
                }
                final position = value * duration.inMilliseconds;
                player.seek(Duration(milliseconds: position.round()));
              },
              value: (_position != null &&
                      _duration != null &&
                      _position!.inMilliseconds > 0 &&
                      _position!.inMilliseconds < _duration!.inMilliseconds)
                  ? _position!.inMilliseconds / _duration!.inMilliseconds
                  : 0.0,
            ),
            Positioned.fill(
              child: Align(
                alignment: Alignment.bottomRight,
                child: Text(
                  _position != null
                      ? '$_positionText / $_durationText'
                      : _duration != null
                          ? _durationText
                          : '',
                  style: const TextStyle(fontSize: 8.0),
                ),
              ),
            )
          ],
        )
      ],
    );
  }
}
