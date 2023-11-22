class RadioStation {
  final String stationId;
  final String name;
  final String url;
  final String tags;
  final String favicon;

  RadioStation(this.stationId, this.name, this.url, this.tags, this.favicon);

  List<String> get tagsAsList => tags.split(',');

  RadioStation.fromJson(Map<String, dynamic> json)
      : stationId = json['stationuuid'],
        name = json['name'],
        url = json['url'],
        tags = json['tags'],
        favicon = json['favicon'];

  @override
  String toString() {
    return 'RadioStation{stationId: $stationId, name: $name, url: $url, tags: $tags, favicon: $favicon}';
  }
}
