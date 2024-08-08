import 'package:cached_s5_audio/cached_s5_audio.dart';
import 'package:cached_s5_audio_exmaple/src/s5.dart';
import 'package:cached_s5_manager/cached_s5_manager.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:s5/s5.dart';

void main() {
  runApp(const Demo());
}

class Demo extends StatelessWidget {
  const Demo({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: CachedS5AudioDemo(),
    );
  }
}

class CachedS5AudioDemo extends StatefulWidget {
  const CachedS5AudioDemo({super.key});

  @override
  State<CachedS5AudioDemo> createState() => _CachedS5AudioDemoState();
}

class _CachedS5AudioDemoState extends State<CachedS5AudioDemo> {
  String? cid;
  final TextEditingController _cidController = TextEditingController(
      text: "z2H7G8Z25ajNkXqn3o1A5Eam7pmdPangcNk2VFViqM993fhxpDhg");
  S5? s5;
  Logger logger = Logger();
  CachedS5Manager? cacheManager;
  @override
  void initState() {
    _initS5();
    _initCache();
    super.initState();
  }

  void _initCache() async {
    cacheManager?.init();
  }

  void _initS5() async {
    // this is an EXAMPLE s5 node, use your own for maximum performance
    s5 = await initS5("https://s5.jptr.tech", "hive", null);
    cacheManager = CachedS5Manager(s5: s5!);
    setState(() {}); // to update UI
  }

  void _submitCID() async {
    if (s5 != null) {
      setState(() {
        cid = _cidController.text;
      });
    }
  }

  void _clearCache() async {
    cacheManager?.clear();
  }

  void _clearImage() async {
    setState(() {
      cid = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        children: [
          Row(
            children: [
              const Text("S5 Status:"),
              (s5 == null)
                  ? const CircularProgressIndicator()
                  : const Icon(Icons.check),
            ],
          ),
          TextField(
            controller: _cidController,
            decoration: const InputDecoration(labelText: "CID: z2..."),
          ),
          const SizedBox(
            height: 10,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                  onPressed: _submitCID, child: const Text("Submit CID")),
              ElevatedButton(
                  onPressed: _clearCache, child: const Text("Clear Cache")),
              ElevatedButton(
                  onPressed: _clearImage,
                  child: const Text("Clear loaded audio"))
            ],
          ),
          const SizedBox(
            height: 10,
          ),
          (cid != null && s5 != null)
              ? CachedS5Audio(
                  cid: cid!,
                  s5: s5!,
                )
              : Container(),
        ],
      ),
    );
  }
}
