import 'dart:async';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'OITimer',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.cyan),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'OITimer'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counterMs = 0;
  int _counterPrev = 0;
  bool _counting = false;
  final int _fpms = 33; // frame rate per ms
  final AudioPlayer _audioPlayer = AudioPlayer();
  final List<int> _bells = [180000, 300000, 480000];
  final List<TextEditingController> _bellControllers = [
    TextEditingController(),
    TextEditingController(),
    TextEditingController()
  ];

  @override
  void initState() {
    super.initState();
    for (var i = 0; i < _bells.length; i++) {
      _bellControllers[i].text = (_bells[i] ~/ 1000 ~/ 60).toString();
    }
    Timer.periodic(Duration(milliseconds: _fpms), (timer) async {
      if (!_counting) return;
      _counterPrev = _counterMs;
      setState(() {
        _counterMs += _fpms;
      });
      if (_counterPrev < _bells[0] && _counterMs >= _bells[0]) {
        await _audioPlayer.play(AssetSource('sounds/ding1.mp3'));
      }
      if (_counterPrev < _bells[1] && _counterMs >= _bells[1]) {
        await _audioPlayer.play(AssetSource('sounds/ding2.mp3'));
      }
      if (_counterPrev < _bells[2] && _counterMs >= _bells[2]) {
        await _audioPlayer.play(AssetSource('sounds/ding3.mp3'));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final ds = ((x) =>
        x.substring(x.length - 2))("0${(_counterMs % 1000 ~/ 10).toString()}");
    final s = ((x) =>
        x.substring(x.length - 2))("0${(_counterMs ~/ 1000 % 60).toString()}");
    final m = ((x) =>
        x.substring(x.length - 2))("0${(_counterMs ~/ 1000 ~/ 60).toString()}");
    final bg = (_counterMs < _bells[0]
            ? Colors.green
            : (_counterMs < _bells[1]
                ? Colors.orange
                : (_counterMs < _bells[2] || _counterMs ~/ 1000 % 2 == 0
                    ? Colors.red
                    : Colors.grey)))
        .withAlpha(120);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Row(children: [
          Text("Bells:  ",
              style: TextStyle(fontSize: 30, fontWeight: FontWeight.w900)),
          Spacer(),
          Expanded(
            child: TextField(
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              controller: _bellControllers[0],
              textAlign: TextAlign.right,
              decoration: InputDecoration(labelText: 'first bell'),
            ),
          ),
          Spacer(),
          Expanded(
            child: TextField(
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              controller: _bellControllers[1],
              textAlign: TextAlign.right,
              decoration: InputDecoration(labelText: 'second bell'),
            ),
          ),
          Spacer(),
          Expanded(
            child: TextField(
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              controller: _bellControllers[2],
              textAlign: TextAlign.right,
              decoration: InputDecoration(labelText: 'third bell'),
            ),
          ),
          Spacer(),
          ElevatedButton(
              onPressed: () {
                for (var i = 0; i < _bells.length; i++) {
                  final int sec = int.parse(_bellControllers[i].text);
                  setState(() {
                    _bells[i] = sec * 1000 * 60;
                  });
                }
              },
              child: Text('update')),
        ]),
        Expanded(
            child: Padding(
                padding: const EdgeInsets.only(top: 10, bottom: 10),
                child: Container(
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                        color: bg,
                        border: Border.all(
                          width: 8,
                        )),
                    child: Center(
                        child: Stack(children: [
                      FittedBox(
                          fit: BoxFit.contain,
                          child: Text("88:88:88",
                              style: TextStyle(
                                  fontFamily: 'dseg7',
                                  fontSize: 1000,
                                  color: Colors.grey.withAlpha(40)))),
                      FittedBox(
                          fit: BoxFit.contain,
                          child: Text("$m:$s:$ds",
                              style: TextStyle(
                                  fontFamily: 'dseg7',
                                  fontSize: 1000,
                                  color: Colors.black.withAlpha(200)))),
                    ]))))),
        SizedBox(height: 100, child: Text("Yagshi 2025")),
      ])),
      floatingActionButton:
          Row(mainAxisAlignment: MainAxisAlignment.end, children: [
        FloatingActionButton(
          onPressed: () {
            setState(() {
              _counting = !_counting;
            });
          },
          tooltip: 'Increment',
          child: _counting
              ? const Icon(Icons.pause)
              : const Icon(Icons.play_arrow),
        ),
        FloatingActionButton(
          onPressed: () {
            setState(() {
              _counting = false;
              _counterMs = 0;
            });
          },
          tooltip: 'Increment',
          child: const Icon(Icons.restore),
        ),
      ]),
    );
  }
}
