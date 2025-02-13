import 'dart:async';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

const int lcdAlpha1 = 220; // for ON segment
const int lcdAlpha0 = 60; // for OFF segment

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

// 123 -> 00123 (n=5)
String nDigits(int x, int n, {pad = " "}) {
  return ((s) => s.substring(s.length - n))(pad * n + x.toString());
}

// limited to 7seg font
class _LCDDigit extends StatelessWidget {
  final String strFG, strBG;
  const _LCDDigit(this.strFG, this.strBG, {super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      FittedBox(
          fit: BoxFit.contain,
          child: Text(strBG,
              style: TextStyle(
                  fontFamily: 'dseg7',
                  fontSize: 1000,
                  color: Colors.grey.withAlpha(lcdAlpha0)))),
      FittedBox(
          fit: BoxFit.contain,
          child: Text(strFG,
              style: TextStyle(
                  fontFamily: 'dseg7',
                  fontSize: 1000,
                  color: Colors.black.withAlpha(lcdAlpha1)))),
    ]);
  }
}

class _BellsIndicator extends StatelessWidget {
  final List<bool> flags;
  final List<int> values;
  const _BellsIndicator(
      {this.flags = const [], this.values = const [], super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        FittedBox(
          child: Icon(Icons.notifications,
              size: 100,
              color: Colors.black.withAlpha(flags[0] ? lcdAlpha1 : lcdAlpha0)),
        ),
        FittedBox(
            child:
                _LCDDigit("${nDigits(values[0], 2, pad: "0")}    ", "88   ")),
        FittedBox(
            child: Row(children: [
          Icon(Icons.notifications,
              size: 100,
              color: Colors.black.withAlpha(flags[1] ? lcdAlpha1 : lcdAlpha0)),
          Icon(Icons.notifications,
              size: 100,
              color: Colors.black.withAlpha(flags[1] ? lcdAlpha1 : lcdAlpha0)),
        ])),
        FittedBox(
            child:
                _LCDDigit("${nDigits(values[1], 2, pad: "0")}    ", "88   ")),
        FittedBox(
            child: Row(children: [
          Icon(Icons.notifications,
              size: 100,
              color: Colors.black.withAlpha(flags[2] ? lcdAlpha1 : lcdAlpha0)),
          Icon(Icons.notifications,
              size: 100,
              color: Colors.black.withAlpha(flags[2] ? lcdAlpha1 : lcdAlpha0)),
          Icon(Icons.notifications,
              size: 100,
              color: Colors.black.withAlpha(flags[2] ? lcdAlpha1 : lcdAlpha0)),
        ])),
        FittedBox(
            child:
                _LCDDigit("${nDigits(values[2], 2, pad: "0")}    ", "88   ")),
      ],
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
  final AudioPlayer _audioPlayer1 = AudioPlayer();
  final AudioPlayer _audioPlayer2 = AudioPlayer();
  final AudioPlayer _audioPlayer3 = AudioPlayer();
  final List<int> _bells = [600000, 900000, 1200000];
  //final List<int> _bells = [5000, 10000, 15000];
  List<bool> _bellFlags = [false, false, false];
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
    (() async {
      await _audioPlayer1.setAsset('assets/ding1.mp3');
      await _audioPlayer2.setAsset('assets/ding2.mp3');
      await _audioPlayer3.setAsset('assets/ding3.mp3');
      await _audioPlayer1.load();
      await _audioPlayer2.load();
      await _audioPlayer3.load();
    })();
    Timer.periodic(Duration(milliseconds: _fpms), (timer) {
      if (!_counting) return;
      _counterPrev = _counterMs;
      setState(() {
        _counterMs += _fpms;
      });
      if (_counterPrev < _bells[0] && _counterMs >= _bells[0]) {
        setState(() {
          _bellFlags[0] = true;
        });
        _audioPlayer1.play();
      }
      if (_counterPrev < _bells[1] && _counterMs >= _bells[1]) {
        setState(() {
          _bellFlags[1] = true;
        });
        _audioPlayer2.play();
      }
      if (_counterPrev < _bells[2] && _counterMs >= _bells[2]) {
        setState(() {
          _bellFlags[2] = true;
        });
        _audioPlayer3.play();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final ds = nDigits(_counterMs % 1000 ~/ 10, 2, pad: "0");
    final s = nDigits(_counterMs ~/ 1000 % 60, 2, pad: "0");
    final m = nDigits(_counterMs ~/ 1000 ~/ 60, 2, pad: "0");
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
                        child: Column(children: [
                      Flexible(
                        flex: 2,
                        child: _BellsIndicator(
                            flags: _bellFlags,
                            values:
                                _bells.map((x) => x ~/ 1000 ~/ 60).toList()),
                      ),
                      Flexible(
                        flex: 8,
                        child: _LCDDigit("$m:$s:$ds", "88:88:88"),
                      ),
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
          tooltip: 'start/stop',
          child: _counting
              ? const Icon(Icons.pause)
              : const Icon(Icons.play_arrow),
        ),
        FloatingActionButton(
          onPressed: () async {
            await _audioPlayer1.stop();
            await _audioPlayer2.stop();
            await _audioPlayer3.stop();
            await _audioPlayer1.seek(Duration(seconds: 0));
            await _audioPlayer2.seek(Duration(seconds: 0));
            await _audioPlayer3.seek(Duration(seconds: 0));
            setState(() {
              _counting = false;
              _counterMs = 0;
              _bellFlags = [false, false, false];
            });
          },
          tooltip: 'reset',
          child: const Icon(Icons.restore),
        ),
      ]),
    );
  }
}
