import 'dart:async';
import 'digit.dart';
import 'package:flutter/material.dart';

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
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  @override
  void initState() {
    Timer.periodic(Duration(milliseconds: 30), (timer) {
      setState(() {
        _counter += 3;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final ds =
        ((x) => x.substring(x.length - 2))("0${(_counter % 100).toString()}");
    final s = ((x) =>
        x.substring(x.length - 2))("0${(_counter ~/ 100 % 60).toString()}");
    final m = ((x) =>
        x.substring(x.length - 2))("0${(_counter ~/ 100 ~/ 60).toString()}");
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
          child: Container(
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                  color: Colors.green.withAlpha(80),
                  border: Border.all(
                    width: 4,
                  )),
              child: Expanded(
                  child: FractionallySizedBox(
                      widthFactor: 0.95,
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
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}
