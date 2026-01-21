import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repositories/music_repository.dart';
import 'music_event.dart';
import 'music_state.dart';

class MusicBloc extends Bloc<MusicEvent, MusicState> {
  final MusicRepository repository;

  // Injectăm repository-ul prin constructor (DI - 10 puncte)
  MusicBloc({required this.repository}) : super(MusicInitial()) {
    
    // Când primim evenimentul "SearchMusicEvent"...
    on<SearchMusicEvent>((event, emit) async {
      emit(MusicLoading()); // 1. Anunțăm UI-ul să arate Loading

      try {
        // 2. Cerem datele de la repository
        final songs = await repository.searchSongs(event.query);
        
        // 3. Dacă e succes, emitem starea Loaded
        emit(MusicLoaded(songs));
      } catch (e) {
        // 4. Dacă e eroare, emitem starea Failure
        emit(MusicFailure(e.toString()));
      }
    });
  }
}