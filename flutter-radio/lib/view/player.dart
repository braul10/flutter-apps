import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:just_audio/just_audio.dart';
import 'package:radio_braulio/models/radio_station.dart';
import 'package:volume_controller/volume_controller.dart';

class Player extends StatefulWidget {
  final RadioStation radioStation;
  final Function previous;
  final Function next;

  Player(this.radioStation, this.previous, this.next);

  @override
  State<StatefulWidget> createState() => _PlayerState();
}

enum PlayerState { LOADING, PLAYING, PAUSED, ERROR }

class _PlayerState extends State<Player> with SingleTickerProviderStateMixin {
  final AudioPlayer _player = AudioPlayer();
  PlayerState state = PlayerState.LOADING;
  late RadioStation currentStation;
  double _volumeBeforeMute = 0;
  double _volumeValue = 0;
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 500),
    );
    _animation = Tween<double>(begin: 1.0, end: 0.8).animate(
      CurvedAnimation(
          parent: _controller, curve: Curves.fastEaseInToSlowEaseOut),
    );
    _controller.repeat(reverse: true);
    VolumeController().listener((volume) {
      setState(() => _volumeValue = volume);
    });
    currentStation = widget.radioStation;
    _init();
  }

  Future<void> _init() async {
    try {
      await _player.setUrl(widget.radioStation.url);
      _player.play();
      setState(() => state = PlayerState.PLAYING);
    } catch (e) {
      if (e.toString() == '(0) Source error')
        setState(() => state = PlayerState.ERROR);
    }
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  String getState() {
    switch (state) {
      case PlayerState.LOADING:
        return 'Cargando...';
      case PlayerState.PLAYING:
        return 'Reproduciendo';
      case PlayerState.PAUSED:
        return 'Pausado';
      default:
        return 'No disponible';
    }
  }

  void pause() {
    _player.pause();
    setState(() => state = PlayerState.PAUSED);
  }

  void play() {
    _player.play();
    setState(() => state = PlayerState.PLAYING);
  }

  void previousStation() async {
    try {
      setState(() => state = PlayerState.LOADING);
      currentStation = widget.previous(currentStation);
      await _player.stop();
      await _player.setUrl(currentStation.url);
      _player.play();
      setState(() => state = PlayerState.PLAYING);
    } catch (e) {
      if (e.toString() == '(0) Source error')
        setState(() => state = PlayerState.ERROR);
    }
  }

  void nextStation() async {
    try {
      setState(() => state = PlayerState.LOADING);
      currentStation = widget.next(currentStation);
      await _player.stop();
      await _player.setUrl(currentStation.url);
      _player.play();
      setState(() => state = PlayerState.PLAYING);
    } catch (e) {
      if (e.toString() == '(0) Source error')
        setState(() => state = PlayerState.ERROR);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Theme.of(context).colorScheme.secondary,
              Theme.of(context).colorScheme.tertiary,
              Theme.of(context).colorScheme.secondary,
            ],
          ),
        ),
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: MediaQuery.of(context).size.height * 0.05,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  InkWell(
                    onTap: () => Navigator.pop(context),
                    child: Icon(
                      Icons.cancel,
                      color: Colors.white,
                      size: 30,
                    ),
                  ),
                ],
              ),
              ScaleTransition(
                scale: _animation,
                child: Container(
                  height: MediaQuery.of(context).size.width * 0.6,
                  width: MediaQuery.of(context).size.width * 0.6,
                  child: CachedNetworkImage(
                    imageUrl: currentStation.favicon,
                    placeholder: (context, url) => CircularProgressIndicator(),
                    errorWidget: (context, url, error) => Icon(
                      Icons.music_note_outlined,
                      color: Theme.of(context).colorScheme.inversePrimary,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 20),
              Text(
                currentStation.name,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  letterSpacing: 1,
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 20),
              Divider(
                height: 1,
                thickness: 0.5,
                color: Colors.white,
              ),
              SizedBox(height: 20),
              Text(
                getState(),
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.robotoMono(
                  fontSize: 15,
                  color: state == PlayerState.ERROR
                      ? Colors.red
                      : state == PlayerState.PLAYING
                          ? Colors.green
                          : Colors.white,
                ),
              ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(
                          Radius.circular(10),
                        ),
                      ),
                    ),
                    child: Icon(
                      Icons.skip_previous_outlined,
                      color: Theme.of(context).colorScheme.tertiary,
                    ),
                    onPressed: () {
                      previousStation();
                    },
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(
                          Radius.circular(10),
                        ),
                      ),
                    ),
                    child: Icon(
                      state == PlayerState.PLAYING
                          ? Icons.pause
                          : Icons.play_arrow_outlined,
                      color: Theme.of(context).colorScheme.tertiary,
                    ),
                    onPressed: () {
                      if (state == PlayerState.PLAYING)
                        pause();
                      else if (state == PlayerState.PAUSED) play();
                    },
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(
                          Radius.circular(10),
                        ),
                      ),
                    ),
                    child: Icon(
                      Icons.skip_next_outlined,
                      color: Theme.of(context).colorScheme.tertiary,
                    ),
                    onPressed: () {
                      nextStation();
                    },
                  ),
                ],
              ),
              SizedBox(height: 30),
              Row(
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(
                          Radius.circular(10),
                        ),
                      ),
                    ),
                    child: Icon(
                      Icons.volume_off,
                      color: Theme.of(context).colorScheme.tertiary,
                    ),
                    onPressed: () {
                      if (_volumeValue == 0 && _volumeBeforeMute != 0) {
                        _volumeValue = _volumeBeforeMute;
                        _volumeBeforeMute = 0;
                        VolumeController().setVolume(_volumeValue);
                      } else {
                        _volumeBeforeMute = _volumeValue;
                        VolumeController().muteVolume();
                      }
                      setState(() {});
                    },
                  ),
                  SizedBox(width: 5),
                  Flexible(
                    child: Slider(
                      min: 0,
                      max: 1,
                      thumbColor: Theme.of(context).colorScheme.inversePrimary,
                      activeColor: Colors.white,
                      inactiveColor: Colors.white,
                      onChanged: (double value) {
                        _volumeValue = value;
                        VolumeController().setVolume(_volumeValue);
                        setState(() {});
                      },
                      value: _volumeValue,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
