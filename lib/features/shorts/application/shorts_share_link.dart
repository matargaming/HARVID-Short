Uri shortShareUrl({
  required String seriesId,
  required String episodeId,
}) {
  return Uri.https('shortigo.app', '/series/$seriesId/episodes/$episodeId');
}

String shortShareText({
  required String seriesTitle,
  required int episodeOrder,
  required String seriesId,
  required String episodeId,
}) {
  final url = shortShareUrl(seriesId: seriesId, episodeId: episodeId);
  return 'Watch $seriesTitle EP.$episodeOrder on ShortiGo\n$url';
}
