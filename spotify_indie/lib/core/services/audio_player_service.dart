import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import '../../features/music/domain/entities/song.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import '../../features/music/domain/entities/song.dart';

class AudioPlayerService {
  final AudioPlayer _audioPlayer = AudioPlayer();

  // Lista internă de redare (Playlist-ul curent al player-ului)
  ConcatenatingAudioSource? _playlist;

  bool get isPlaying => _audioPlayer.playing;
  Stream<PlayerState> get playerStateStream => _audioPlayer.playerStateStream;
  Stream<Duration> get positionStream => _audioPlayer.positionStream;
  Stream<Duration?> get durationStream => _audioPlayer.durationStream;

  // Stream pentru a vedea ce melodie e curentă (indexul)
  Stream<int?> get currentIndexStream => _audioPlayer.currentIndexStream;
  // Stream pentru a vedea lista completă (pentru pagina de Queue)
  Stream<SequenceState?> get sequenceStateStream =>
      _audioPlayer.sequenceStateStream;

  Future<void> seek(Duration position) async {
    await _audioPlayer.seek(position);
  }

  // 1. PLAY NORMAL (Înlocuiește coada cu o melodie nouă sau un playlist întreg)
  Future<void> playSong(Song song) async {
    // Creăm sursa audio
    final audioSource = _createAudioSource(song);

    // Inițializăm un playlist nou cu o singură melodie (resetăm coada veche)
    _playlist = ConcatenatingAudioSource(children: [audioSource]);

    await _audioPlayer.setAudioSource(_playlist!);
    await _audioPlayer.play();
  }

  // 2. ADD TO QUEUE (Adaugă la finalul cozii curente)
  Future<void> addToQueue(Song song) async {
    final audioSource = _createAudioSource(song);

    if (_playlist == null) {
      // Dacă nu cântă nimic, pornim melodia asta
      await playSong(song);
    } else {
      // Dacă cântă ceva, o adăugăm la final fără să întrerupem
      await _playlist!.add(audioSource);
    }
  }

  Future<void> jumpToQueueItem(int index) async {
    await _audioPlayer.seek(Duration.zero, index: index);
    await _audioPlayer.play();
  }

  // Helper pentru a crea sursa cu metadate
  AudioSource _createAudioSource(Song song) {
    return AudioSource.uri(
      Uri.parse(song.audioUrl),
      tag: MediaItem(
        id: song.id,
        title: song.title,
        artist: song.artist,
        artUri: Uri.parse(song.imageUrl),
        // Salvăm obiectul Song original în extras pentru a-l recupera ușor în UI
        extras: {'song_model': song},
      ),
    );
  }

  // Metode de control
  Future<void> pause() async => await _audioPlayer.pause();
  Future<void> resume() async => await _audioPlayer.play();
  Future<void> skipToNext() async {
    if (_audioPlayer.hasNext) {
      await _audioPlayer.seekToNext();
    }
  }

  Future<void> skipToPrevious() async {
    // 1. Verificăm cât timp a trecut din melodie
    final position = _audioPlayer.position;

    // Dacă au trecut mai mult de 5 secunde, dăm restart la melodie
    if (position.inSeconds > 5) {
      await _audioPlayer.seek(Duration.zero);
    }
    // Altfel, încercăm să mergem la melodia anterioară
    else {
      // just_audio are o protecție internă: dacă nu există previous, seekToPrevious nu face nimic
      // dar noi vrem să fim siguri că dăm restart dacă suntem la prima melodie
      if (_audioPlayer.hasPrevious) {
        await _audioPlayer.seekToPrevious();
      } else {
        await _audioPlayer.seek(Duration.zero);
      }
    }
  }

  // Metode pentru Drag & Drop și Ștergere
  Future<void> removeQueueItemAt(int index) async {
    await _playlist?.removeAt(index);
  }

  Future<void> moveQueueItem(int oldIndex, int newIndex) async {
    await _playlist?.move(oldIndex, newIndex);
  }
}
