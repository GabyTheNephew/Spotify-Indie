import '../../../domain/entities/playlist.dart';

abstract class PlaylistState {}

class PlaylistLoading extends PlaylistState {}

class PlaylistLoaded extends PlaylistState {
  final List<Playlist> playlists;
  // Putem avea un timestamp ca să forțăm UI-ul să se actualizeze
  final int lastUpdated; 

  PlaylistLoaded(this.playlists) : lastUpdated = DateTime.now().millisecondsSinceEpoch;
}