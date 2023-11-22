import 'dart:convert';
import 'dart:math';

import 'package:http/http.dart';
import 'package:radio_braulio/models/radio_station.dart';

class RadioRepository {
  Future<List<RadioStation>> getStationsList({
    String country = 'es',
    int limit = 100,
  }) async {
    List<String> domains = [
      'https://at1.api.radio-browser.info',
      'https://nl1.api.radio-browser.info',
      'https://de1.api.radio-browser.info',
    ];
    domains.shuffle();
    String uri =
        '${domains.first}/json/stations/bycountrycodeexact/$country';
    Response response = await get(Uri.parse(uri));
    if (response.statusCode != 200) return [];

    String answer = utf8.decode(response.bodyBytes);
    List list = jsonDecode(answer);
    list = list
        .where((e) => e['favicon'].isNotEmpty && e['url'].contains('https'))
        .toList();
    list.sort((a, b) => b['votes'].compareTo(a['votes']));
    limit = min(limit, list.length);
    list = list.sublist(0, limit);

    return list.map((r) => RadioStation.fromJson(r)).toList();
  }
}
