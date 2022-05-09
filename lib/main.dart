import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:isar/isar.dart';
import 'package:isar_seed_sample/spot.dart';
import 'package:path_provider/path_provider.dart';

// パフォーマンス測定用
List<Map<String, dynamic>> generateJson(int count) {
  final json = <Map<String, dynamic>>[];
  final now = DateTime.now().microsecondsSinceEpoch;
  for (var i = 0; i < count; i++) {
    json.add({
      'name': 'name_$i',
      'latitude': 23.718989,
      'longitude': 37.973620,
      'createdAt': now,
      'updatedAt': now,
    });
  }
  return json;
}

Future<void> _loadSpots(Isar isar) async {
  try {
    final bytes = await rootBundle.load('assets/spots.json');
    final jsonStr = const Utf8Decoder().convert(bytes.buffer.asUint8List());
    final json = jsonDecode(jsonStr) as List;
    final now = DateTime.now();
    final spots = json.map((e) => Spot()
      ..name = e['name']
      ..longitude = double.parse(e['longitude'])
      ..latitude = double.parse(e['latitude'])
      ..createdAt = now
      ..updatedAt = now);
    isar.writeTxn((isar) async {
      await isar.spots.putAll(spots.toList());
    });
  } catch (e) {
    debugPrint(e.toString());
  }
}

Future<void> _loadSpotsUseImportJson(Isar isar) async {
  try {
    final bytes = await rootBundle.load('assets/spots.json');
    final jsonStr = const Utf8Decoder().convert(bytes.buffer.asUint8List());
    final json = jsonDecode(jsonStr) as List;
    final now = DateTime.now().microsecondsSinceEpoch;
    final importJson = json
        .map((e) => {
              'name': e['name'],
              'latitude': double.parse(e['latitude']),
              'longitude': double.parse(e['longitude']),
              'createdAt': now,
              'updatedAt': now,
            })
        .toList();
    isar.writeTxn((isar) async {
      await isar.spots.importJson(importJson);
    });
  } catch (e) {
    debugPrint(e.toString());
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final dir = await getApplicationSupportDirectory();

  final isar = await Isar.open(
      schemas: [SpotSchema], directory: dir.path, inspector: true);
  final exists = await isar.spots.count() > 0;
  if (!exists) {
    debugPrint('Loading spots... ${DateTime.now().millisecondsSinceEpoch}');
    await _loadSpots(isar);
    // await _loadSpotsUseImportJson(isar);
    debugPrint('finish ${DateTime.now().millisecondsSinceEpoch}');
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          // Column is also a layout widget. It takes a list of children and
          // arranges them vertically. By default, it sizes itself to fit its
          // children horizontally, and tries to be as tall as its parent.
          //
          // Invoke "debug painting" (press "p" in the console, choose the
          // "Toggle Debug Paint" action from the Flutter Inspector in Android
          // Studio, or the "Toggle Debug Paint" command in Visual Studio Code)
          // to see the wireframe for each widget.
          //
          // Column has various properties to control how it sizes itself and
          // how it positions its children. Here we use mainAxisAlignment to
          // center the children vertically; the main axis here is the vertical
          // axis because Columns are vertical (the cross axis would be
          // horizontal).
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'You have pushed the button this many times:',
            ),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headline4,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
