import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:radio_braulio/models/models.dart';
import 'package:radio_braulio/provider/providers.dart';
import 'package:radio_braulio/view/player.dart';
import 'package:radio_braulio/widgets/widgets.dart';

class StationsGrid extends StatefulWidget {
  @override
  State<StationsGrid> createState() => _StationsGridState();
}

class _StationsGridState extends State<StationsGrid>
    with SingleTickerProviderStateMixin {
  final RadioRepository radioRepository = RadioRepository();
  List<RadioStation>? radioStations;

  @override
  void initState() {
    super.initState();
    _getData();
  }

  void _getData() async {
    radioStations = await radioRepository.getStationsList(
      country: 'es',
      limit: 200,
    );
    //radioStations!.shuffle();
    setState(() {});
  }

  RadioStation previous(RadioStation rs) {
    int currentIndex = radioStations!.indexOf(rs);
    if (currentIndex == -1)
      return rs;
    else if (currentIndex == 0)
      return radioStations![radioStations!.length - 1];
    else
      return radioStations![currentIndex - 1];
  }

  RadioStation next(RadioStation rs) {
    int currentIndex = radioStations!.indexOf(rs);
    if (currentIndex == -1)
      return rs;
    else if (currentIndex == radioStations!.length - 1)
      return radioStations![0];
    else
      return radioStations![currentIndex + 1];
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    final mediaQueryData = MediaQuery.of(context);
    return MediaQuery(
        data: mediaQueryData.copyWith(textScaleFactor: 1.0),
        child: Scaffold(
          appBar: AppBar(
            backgroundColor: Theme.of(context).colorScheme.primary,
            title: const Text('Top 200 spanish radio stations'),
            titleTextStyle: TextStyle(color: Colors.white, fontSize: 18),
            centerTitle: true,
            elevation: 5,
          ),
          body: radioStations == null
              ? LoadingSpinner()
              : SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Container(
                    padding: EdgeInsets.all(8),
                    height: double.infinity,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Theme.of(context).colorScheme.secondary,
                          Theme.of(context).colorScheme.tertiary,
                        ],
                      ),
                    ),
                    child: Wrap(
                      spacing: 5,
                      runSpacing: 10,
                      alignment: WrapAlignment.spaceEvenly,
                      direction: Axis.vertical,
                      children: radioStations!
                          .map((rs) => InkWell(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    PageRouteBuilder(
                                      pageBuilder: (c, a1, a2) =>
                                          Player(rs, previous, next),
                                      transitionsBuilder:
                                          (c, anim, a2, child) =>
                                              FadeTransition(
                                                  opacity: anim, child: child),
                                      transitionDuration:
                                          Duration(milliseconds: 500),
                                    ),
                                  );
                                },
                                child: RadioStationWidget(rs),
                              ))
                          .toList(),
                    ),
                  ),
                ),
        ));
  }
}

class RadioStationWidget extends StatefulWidget {
  final RadioStation rs;

  RadioStationWidget(this.rs);

  @override
  State<StatefulWidget> createState() => _RadioStationWidgetState();
}

class _RadioStationWidgetState extends State<RadioStationWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  Random r = Random();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 800),
    );
    double begin = 0.8 + r.nextDouble() * 0.25;
    double end = 0.8 + r.nextDouble() * 0.25;
    _animation = Tween<double>(begin: begin, end: end).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOutBack,
      ),
    );
    _controller.repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _animation,
      child: Container(
        height: 90 + r.nextDouble() * 30,
        width: 90,
        padding: EdgeInsets.all(2),
        decoration: BoxDecoration(
          border: Border.all(
            color: Theme.of(context).colorScheme.inversePrimary,
            width: 1,
          ),
          borderRadius: BorderRadius.all(
            Radius.circular(10),
          ),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Theme.of(context).colorScheme.tertiary,
              Theme.of(context).colorScheme.primary,
              Theme.of(context).colorScheme.inversePrimary,
            ],
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              height: 40,
              width: 40,
              child: CachedNetworkImage(
                imageUrl: widget.rs.favicon,
                placeholder: (context, url) => CircularProgressIndicator(),
                errorWidget: (context, url, error) => Icon(
                  Icons.music_note_outlined,
                  color: Theme.of(context).colorScheme.inversePrimary,
                ),
              ),
            ),
            Text(
              widget.rs.name,
              maxLines: 2,
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
