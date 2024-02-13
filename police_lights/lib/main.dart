import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool on = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: InkWell(
        onTap: () {
          setState(() => on = !on);
        },
        child: on
            ? PoliceLights()
            : Container(
                color: Colors.black,
                child: Center(
                  child: Icon(
                    Icons.lightbulb,
                    color: Colors.grey,
                    size: 100,
                  ),
                ),
              ),
      ),
    );
  }
}

class PoliceLights extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _PoliceLightsState();
}

class _PoliceLightsState extends State<PoliceLights> {
  bool on = false;

  @override
  void initState() {
    super.initState();
    colorsAnimation();
  }

  Future<void> colorsAnimation() async {
    int shortInterval = 50;
    int longInterval = 300;
    if (this.mounted) setState(() => on = true);
    await Future.delayed(Duration(milliseconds: shortInterval));
    if (this.mounted) setState(() => on = false);
    await Future.delayed(Duration(milliseconds: shortInterval));
    if (this.mounted) setState(() => on = true);
    await Future.delayed(Duration(milliseconds: shortInterval));
    if (this.mounted) setState(() => on = false);
    await Future.delayed(Duration(milliseconds: shortInterval));
    if (this.mounted) setState(() => on = true);
    await Future.delayed(Duration(milliseconds: shortInterval));
    if (this.mounted) setState(() => on = false);
    await Future.delayed(Duration(milliseconds: shortInterval));
    if (this.mounted) setState(() => on = true);
    await Future.delayed(Duration(milliseconds: shortInterval));

    if (this.mounted) setState(() => on = false);
    await Future.delayed(Duration(milliseconds: longInterval));
    if (this.mounted) colorsAnimation();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: on ? Color(0xFF0000FF) : Colors.black,
    );
  }
}
