import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:just_audio_background/just_audio_background.dart';
// 👇 AICI ESTE FIX-UL: Adăugăm "as just_audio"
import 'package:just_audio/just_audio.dart' as just_audio;
import '../../../../../core/services/audio_player_service.dart';
import '../../../domain/entities/song.dart';
import 'player_event.dart';
import 'player_state.dart'; // Acesta rămâne PlayerState-ul principal (al nostru)

class PlayerBloc extends Bloc<PlayerEvent, PlayerState> {
  final AudioPlayerService audioService;
  StreamSubscription? _playerSubscription;
  StreamSubscription? _currentIndexSubscription;

  PlayerBloc({required this.audioService}) : super(PlayerInitial()) {
    // 1. LISTENER PENTRU SINCRONIZARE (Play/Pause)
    _playerSubscription = audioService.playerStateStream.listen((playerState) {
      // playerState aici vine din just_audio, dar Dart deduce tipul automat
      add(PlayerStateChanged(playerState.playing));
    });

    // 2. LISTENER PENTRU SCHIMBAREA MELODIEI (Next/Prev automat)
    _currentIndexSubscription = audioService.currentIndexStream.listen((index) {
      _updateCurrentSongFromService(index);
    });

    // 3. HANDLER PENTRU UPDATE INTERN
    on<UpdateCurrentSongInternalEvent>((event, emit) {
      if (event.song != null) {
        emit(PlayerPlaying(event.song!));
      }
    });

    // 4. HANDLER PENTRU SCHIMBAREA STĂRII UI
    on<PlayerStateChanged>((event, emit) {
      final currentSong = state is PlayerPlaying
          ? (state as PlayerPlaying).currentSong
          : (state is PlayerPaused
                ? (state as PlayerPaused).currentSong
                : null);

      if (currentSong != null) {
        if (event.isPlaying) {
          emit(PlayerPlaying(currentSong));
        } else {
          emit(PlayerPaused(currentSong));
        }
      }
    });

    // 5. PLAY SONG
    on<PlaySongEvent>((event, emit) async {
      emit(PlayerPlaying(event.song));
      await audioService.playSong(event.song);
    });

    // 6. TOGGLE PLAY/PAUSE
    on<TogglePlayPauseEvent>((event, emit) async {
      if (state is PlayerPlaying) {
        await audioService.pause();
      } else if (state is PlayerPaused) {
        await audioService.resume();
      }
    });

    // 7. ADD TO QUEUE
    on<AddToQueueEvent>((event, emit) async {
      await audioService.addToQueue(event.song);
    });

    // 8. NEXT / PREV (Le-am conectat la service)
    on<SkipNextEvent>((event, emit) async => await audioService.skipToNext());
    on<SkipPreviousEvent>(
      (event, emit) async => await audioService.skipToPrevious(),
    );
  }

  void _updateCurrentSongFromService(int? index) async {
    if (index == null) return;

    // 👇 Folosim prefixul "just_audio" pentru SequenceState
    final just_audio.SequenceState? sequenceState =
        await audioService.sequenceStateStream.first;

    if (sequenceState != null && sequenceState.sequence.isNotEmpty) {
      final audioSource = sequenceState.sequence[index];
      final mediaItem = audioSource.tag as MediaItem;
      final song = mediaItem.extras?['song_model'] as Song?;

      final extras = mediaItem.extras;

      if (extras != null) {
        // Reconstruim obiectul Song manual
        final song = Song(
          id: extras['id'] as String? ?? '',
          title: mediaItem.title, // Putem lua titlul direct din MediaItem
          artist: mediaItem.artist ?? 'Unknown', // La fel și artistul
          imageUrl: extras['image'] as String? ?? '', // Imaginea din extras
          audioUrl: extras['audio'] as String? ?? '', // Audio URL din extras
        );

        add(UpdateCurrentSongInternalEvent(song));
      }

      if (song != null) {
        add(UpdateCurrentSongInternalEvent(song));
      }
    }
  }

  @override
  Future<void> close() {
    _playerSubscription?.cancel();
    _currentIndexSubscription?.cancel();
    return super.close();
  }
}
