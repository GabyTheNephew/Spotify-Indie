abstract class PlaylistEvent {}

class LoadPlaylistsEvent extends PlaylistEvent {}

class CreatePlaylistEvent extends PlaylistEvent {
  final String name;
  CreatePlaylistEvent(this.name);
}

class ToggleSongInPlaylistEvent extends PlaylistEvent {
  final String playlistId;
  final dynamic song; // Folosim dynamic sau Song
  ToggleSongInPlaylistEvent(this.playlistId, this.song);
}