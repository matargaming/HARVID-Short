abstract class SocialActionsGateway {
  Future<void> setEpisodeLiked({
    required String episodeId,
    required bool liked,
  });

  Future<void> setSeriesSaved({
    required String seriesId,
    required bool saved,
  });

  Future<void> recordEpisodeShare({required String episodeId});

  Future<void> setSeriesFollowed({
    required String seriesId,
    required bool followed,
  });
}
