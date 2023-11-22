import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:radio_braulio/models/models.dart';
import 'package:radio_braulio/provider/providers.dart';
import 'package:radio_braulio/view/player.dart';
import 'package:radio_braulio/widgets/widgets.dart';

class StationsList extends StatefulWidget {
  @override
  State<StationsList> createState() => _StationsListState();
}

class _StationsListState extends State<StationsList>
    with SingleTickerProviderStateMixin {
  final RadioRepository radioRepository = RadioRepository();
  List<RadioStation>? allRadioStations;
  List<RadioStation>? radioStations;
  TextEditingController textController = TextEditingController();
  final List<Country> countries = [
    Country('es', '🇪🇸', 'España'),
    Country('ar', '🇦🇷', 'Argentina'),
    Country('au', '🇦🇺', 'Australia'),
    Country('br', '🇧🇷', 'Brasil'),
    Country('ca', '🇨🇦', 'Canada'),
    Country('cn', '🇨🇳', 'China'),
    Country('us', '🇺🇸', 'EEUU'),
    Country('fr', '🇫🇷', 'Francia'),
    Country('gb', '🇬🇧', 'Gran Bretaña'),
    Country('ie', '🇮🇪', 'Irlanda'),
    Country('it', '🇮🇹', 'Italia'),
    Country('jp', '🇯🇵', 'Japón'),
    Country('no', '🇳🇴', 'Noruega'),
    Country('pl', '🇵🇱', 'Polonia'),
    Country('pt', '🇵🇹', 'Portugal'),
    Country('ru', '🇷🇺', 'Rusia'),
    Country('se', '🇸🇪', 'Suecia'),
    Country('ch', '🇨🇭', 'Suiza'),
  ];
  late Country currentCountry;

  @override
  void initState() {
    super.initState();
    currentCountry = countries.first;
    _getData();
  }

  void _getData() async {
    setState(() {
      allRadioStations = null;
      radioStations = null;
    });
    allRadioStations = await radioRepository.getStationsList(
      country: currentCountry.code,
      limit: 200,
    );
    radioStations = allRadioStations;
    setState(() {});
  }

  RadioStation previous(RadioStation rs) {
    int currentIndex = allRadioStations!.indexOf(rs);
    if (currentIndex == -1)
      return rs;
    else if (currentIndex == 0)
      return allRadioStations![allRadioStations!.length - 1];
    else
      return allRadioStations![currentIndex - 1];
  }

  RadioStation next(RadioStation rs) {
    int currentIndex = allRadioStations!.indexOf(rs);
    if (currentIndex == -1)
      return rs;
    else if (currentIndex == allRadioStations!.length - 1)
      return allRadioStations![0];
    else
      return allRadioStations![currentIndex + 1];
  }

  String removeDiacritics(String text) => text
      .replaceAll('á', 'a')
      .replaceAll('é', 'e')
      .replaceAll('í', 'i')
      .replaceAll('ó', 'o')
      .replaceAll('ú', 'u');

  void search(String value) {
    if (value.isEmpty) {
      setState(() {
        radioStations = allRadioStations;
      });
    } else {
      radioStations = [];
      int i = 0;
      while (i < allRadioStations!.length) {
        String name = removeDiacritics(allRadioStations![i].name.toLowerCase());
        String searchValue = removeDiacritics(value.toLowerCase());
        if (name.contains(searchValue)) {
          radioStations!.add(allRadioStations![i]);
        }
        i++;
      }
      setState(() {});
    }
  }

  String getNumberOfRadios() =>
      allRadioStations != null ? allRadioStations!.length.toString() : '...';

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    final mediaQueryData = MediaQuery.of(context);
    return MediaQuery(
      data: mediaQueryData.copyWith(textScaleFactor: 1.0),
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.primary,
          title: Text(
            'Top ${getNumberOfRadios()} ${currentCountry.name} ${currentCountry.flag}',
          ),
          titleTextStyle: TextStyle(color: Colors.white, fontSize: 16),
          centerTitle: true,
          elevation: 5,
        ),
        body: allRadioStations == null
            ? LoadingSpinner()
            : Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 60,
                          padding: EdgeInsets.all(8),
                          child: TextField(
                            controller: textController,
                            autofocus: false,
                            cursorColor: Colors.white,
                            decoration: InputDecoration(
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: Theme.of(context).primaryColor,
                                  width: 1,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: Theme.of(context).focusColor,
                                  width: 2,
                                ),
                              ),
                              labelText: 'Buscar',
                              labelStyle: TextStyle(
                                  color: Theme.of(context).primaryColor),
                            ),
                            style: TextStyle(
                              color: Theme.of(context).primaryColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                            onChanged: (value) {
                              search(value);
                            },
                          ),
                        ),
                      ),
                      SizedBox(width: 5),
                      InkWell(
                        onTap: () {
                          FocusScopeNode currentFocus = FocusScope.of(context);
                          if (!currentFocus.hasPrimaryFocus)
                            currentFocus.unfocus();
                          textController.text = '';
                          search('');
                        },
                        child: Icon(
                          Icons.cancel,
                          color: Theme.of(context).colorScheme.primary,
                          size: 25,
                        ),
                      ),
                      SizedBox(width: 10),
                    ],
                  ),
                  Expanded(
                    child: ListView.separated(
                      itemCount: radioStations!.length,
                      itemBuilder: (BuildContext c, int i) {
                        return InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              PageRouteBuilder(
                                pageBuilder: (c, a1, a2) =>
                                    Player(radioStations![i], previous, next),
                                transitionsBuilder: (c, anim, a2, child) =>
                                    FadeTransition(opacity: anim, child: child),
                                transitionDuration: Duration(milliseconds: 500),
                              ),
                            );
                          },
                          child: Container(
                            height: 50,
                            child: Row(
                              children: [
                                SizedBox(width: 10),
                                Container(
                                  height: 30,
                                  width: 30,
                                  child: CachedNetworkImage(
                                    imageUrl: radioStations![i].favicon,
                                    placeholder: (context, url) =>
                                        CircularProgressIndicator(),
                                    errorWidget: (context, url, error) => Icon(
                                      Icons.music_note_outlined,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .inversePrimary,
                                    ),
                                  ),
                                ),
                                SizedBox(width: 20),
                                Expanded(
                                  child: Text(
                                    radioStations![i].name,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 15,
                                      fontWeight: FontWeight.normal,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                      separatorBuilder: (_, __) => Divider(
                        color: Theme.of(context).primaryColorDark,
                        height: 0,
                        thickness: 0,
                      ),
                    ),
                  ),
                ],
              ),
        floatingActionButton: Container(
          margin: EdgeInsets.only(right: 5, bottom: 5),
          child: ElevatedButton.icon(
            icon: Icon(
              Icons.map,
              color: Colors.green[100],
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
              textStyle: TextStyle(color: Colors.white),
              padding: EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 10,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(
                  Radius.circular(25),
                ),
              ),
            ),
            label: Text(
              'Países',
              style: TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
            ),
            onPressed: () {
              showCountries();
            },
          ),
        ),
      ),
    );
  }

  void showCountries() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return Container(
          height: 500,
          color: Theme.of(context).scaffoldBackgroundColor,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: 15),
                Text(
                  'Países',
                  style: TextStyle(
                    color: Theme.of(context).primaryColorDark,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                SizedBox(height: 15),
                Column(
                    children: countries
                        .map((c) => InkWell(
                              onTap: () {
                                currentCountry = c;
                                _getData();
                                Navigator.pop(context);
                              },
                              child: c.modalItem(),
                            ))
                        .toList()),
              ],
            ),
          ),
        );
      },
    );
  }
}

class Country {
  final String code;
  final String flag;
  final String name;

  Country(this.code, this.flag, this.name);

  Widget modalItem() {
    return Container(
      height: 45,
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Colors.blueGrey,
            width: 0.5,
          ),
        ),
      ),
      width: double.infinity,
      child: Center(
        child: Text(
          '$flag $name',
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            letterSpacing: 1,
            color: Colors.black,
            fontSize: 18,
          ),
        ),
      ),
    );
  }

  @override
  String toString() {
    return 'Country{code: $code, flag: $flag, name: $name}';
  }
}
