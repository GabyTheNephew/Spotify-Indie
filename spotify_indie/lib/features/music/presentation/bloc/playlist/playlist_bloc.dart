import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/repositories/playlist_repository.dart';
import 'playlist_event.dart';
import 'playlist_state.dart';

class PlaylistBloc extends Bloc<PlaylistEvent, PlaylistState> {
  final PlaylistRepository repository;

  PlaylistBloc({required this.repository}) : super(PlaylistLoading()) {
    
    on<LoadPlaylistsEvent>((event, emit) {
      final playlists = repository.getPlaylists();
      emit(PlaylistLoaded(playlists));
    });

    on<CreatePlaylistEvent>((event, emit) async {
      await repository.createPlaylist(event.name);
      add(LoadPlaylistsEvent()); // Reîncărcăm lista după creare
    });

    on<ToggleSongInPlaylistEvent>((event, emit) async {
      await repository.toggleSongInPlaylist(event.playlistId, event.song);
      add(LoadPlaylistsEvent()); // Reîncărcăm lista pentru a vedea modificările
    });
  }
}