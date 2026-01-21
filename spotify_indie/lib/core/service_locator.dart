import 'package:get_it/get_it.dart';
import '../features/music/data/repositories/music_repository.dart';
import 'services/audio_player_service.dart';
import '../features/music/data/repositories/playlist_repository.dart';

final sl = GetIt.instance; // sl = Service Locator

void setupServiceLocator() {
  // Înregistrăm Repository-ul ca "Lazy Singleton"
  // (se creează doar când avem nevoie de el)
  sl.registerLazySingleton<MusicRepository>(() => MusicRepository());
  sl.registerLazySingleton<AudioPlayerService>(() => AudioPlayerService());
  sl.registerLazySingleton<PlaylistRepository>(() => PlaylistRepository());
}
