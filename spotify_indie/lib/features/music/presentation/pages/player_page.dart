import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spotify_indie/features/music/presentation/pages/queue_page.dart';
import 'package:spotify_indie/features/music/presentation/widgets/add_to_playlist_sheet.dart';
import '../../../../core/service_locator.dart'; // Pentru a accesa serviciul audio
import '../../../../core/services/audio_player_service.dart';
import '../../domain/entities/song.dart';
import '../bloc/player/player_bloc.dart';
import '../bloc/player/player_event.dart';
import '../bloc/player/player_state.dart';
import 'package:spotify_indie/features/music/presentation/widgets/lyric_sheet.dart';

class PlayerPage extends StatelessWidget {
  const PlayerPage({super.key});

  // Funcție helper pentru a formata timpul (ex: 65 secunde -> "1:05")
  String _formatDuration(Duration? duration) {
    if (duration == null) return '--:--';
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // Fundal complet negru sau gradient
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.keyboard_arrow_down, size: 30),
          onPressed: () =>
              Navigator.pop(context), // Închidem pagina (swipe down logic)
        ),
        title: const Text(
          "NOW PLAYING",
          style: TextStyle(fontSize: 12, letterSpacing: 2),
        ),
        centerTitle: true,
      ),
      body: BlocBuilder<PlayerBloc, PlayerState>(
        builder: (context, state) {
          // Verificăm ce melodie cântă
          Song? song;
          bool isPlaying = false;

          if (state is PlayerPlaying) {
            song = state.currentSong;
            isPlaying = true;
          } else if (state is PlayerPaused) {
            song = state.currentSong;
            isPlaying = false;
          }

          // Dacă nu avem date, nu arătăm nimic
          if (song == null) return const SizedBox.shrink();

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Spacer(),

                // 1. COPERTA MARE (ARTWORK)
                Center(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      song.imageUrl,
                      width: 320,
                      height: 320,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        width: 320,
                        height: 320,
                        color: Colors.grey[800],
                        child: const Icon(Icons.music_note, size: 80),
                      ),
                    ),
                  ),
                ),

                const Spacer(),

                // 2. TITLU ȘI ARTIST
                // 2. TITLU ȘI ARTIST + BUTON DREAPTA
                Row(
                  children: [
                    // Folosim Expanded ca textul să ocupe tot loc-ul din stânga
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            song.title,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow
                                .ellipsis, // Pune "..." dacă e prea lung
                          ),
                          const SizedBox(height: 8),
                          Text(
                            song.artist,
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.grey[400],
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),

                    // Butonul va fi împins automat în dreapta de către Expanded
                    IconButton(
                      icon: const Icon(
                        Icons
                            .add_circle_outline, // Sau Icons.favorite_border pentru inimioară
                        color: Colors.white,
                        size: 30,
                      ),
                      onPressed: () {
                        showModalBottomSheet(
                          context: context,
                          // Nu uita semnul !
                          builder: (_) => AddToPlaylistSheet(song: song!),
                        );
                      },
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // 3. BARA DE PROGRES (SLIDER)
                // Folosim StreamBuilder pentru a asculta direct serviciul audio (performanță maximă)
                StreamBuilder<Duration>(
                  stream: sl<AudioPlayerService>().positionStream,
                  builder: (context, snapshotPosition) {
                    final position = snapshotPosition.data ?? Duration.zero;

                    return StreamBuilder<Duration?>(
                      stream: sl<AudioPlayerService>().durationStream,
                      builder: (context, snapshotDuration) {
                        final duration = snapshotDuration.data ?? Duration.zero;

                        return Column(
                          children: [
                            SliderTheme(
                              data: SliderTheme.of(context).copyWith(
                                thumbShape: const RoundSliderThumbShape(
                                  enabledThumbRadius: 6,
                                ),
                                trackHeight: 4,
                                activeTrackColor: Colors.white,
                                inactiveTrackColor: Colors.grey[800],
                                thumbColor: Colors.white,
                              ),
                              child: Slider(
                                min: 0,
                                max: duration.inMilliseconds.toDouble(),
                                value: position.inMilliseconds.toDouble().clamp(
                                  0,
                                  duration.inMilliseconds.toDouble(),
                                ),
                                onChanged: (value) {
                                  // User-ul trage de bară -> facem seek
                                  sl<AudioPlayerService>().seek(
                                    Duration(milliseconds: value.toInt()),
                                  );
                                },
                              ),
                            ),

                            // Timpii (Stânga: Curent, Dreapta: Rămas)
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  _formatDuration(position),
                                  style: const TextStyle(
                                    color: Colors.grey,
                                    fontSize: 12,
                                  ),
                                ),
                                Text(
                                  _formatDuration(duration - position),
                                  style: const TextStyle(
                                    color: Colors.grey,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        );
                      },
                    );
                  },
                ),

                const SizedBox(height: 16),

                // 4. BUTOANELE DE CONTROL (Previous, Play, Next)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    IconButton(
                      iconSize: 40,
                      icon: const Icon(
                        Icons.skip_previous,
                        color: Colors.white,
                      ),
                      onPressed: () {
                        context.read<PlayerBloc>().add(SkipPreviousEvent());
                      },
                    ),

                    // Buton Play/Pause Mare
                    Container(
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                      ),
                      child: IconButton(
                        iconSize: 50,
                        icon: Icon(
                          isPlaying ? Icons.pause : Icons.play_arrow,
                          color: Colors.black,
                        ),
                        onPressed: () {
                          // MODIFICARE AICI:
                          context.read<PlayerBloc>().add(
                            TogglePlayPauseEvent(),
                          );
                        },
                      ),
                    ),

                    IconButton(
                      iconSize: 40,
                      icon: const Icon(Icons.skip_next, color: Colors.white),
                      onPressed: () {
                        context.read<PlayerBloc>().add(SkipNextEvent());
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween, // Dreapta
                  children: [
                    IconButton(
                      icon: const Icon(
                        Icons.mic_none,
                        color: Colors.white,
                        size: 28,
                      ),
                      onPressed: () {
                        if (song != null) {
                          showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            backgroundColor: Colors.transparent,
                            builder: (_) => LyricsSheet(song: song!),
                          );
                        }
                      },
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.queue_music,
                        color: Colors.white,
                        size: 28,
                      ),
                      onPressed: () {
                        // Deschidem QueuePage ca un modal/pagină nouă
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true, // Ca să ocupe tot ecranul
                          backgroundColor: Colors.black,
                          builder: (_) => const QueuePage(),
                        );
                      },
                    ),
                  ],
                ),

                const SizedBox(height: 48), // Padding jos
              ],
            ),
          );
        },
      ),
    );
  }
}
