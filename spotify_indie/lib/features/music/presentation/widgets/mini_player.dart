import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spotify_indie/features/music/presentation/widgets/add_to_playlist_sheet.dart';
import '../../domain/entities/song.dart';
import '../bloc/player/player_bloc.dart';
import '../bloc/player/player_event.dart';
import '../bloc/player/player_state.dart';
import '../pages/player_page.dart'; // Importul necesar pentru navigare

class MiniPlayer extends StatelessWidget {
  const MiniPlayer({super.key});

  @override
  Widget build(BuildContext context) {
    // Ascultăm starea PlayerBloc-ului
    return BlocBuilder<PlayerBloc, PlayerState>(
      builder: (context, state) {
        // 1. Dacă nu cântă nimic, widget-ul este invizibil
        if (state is PlayerInitial) {
          return const SizedBox.shrink();
        }

        // 2. Extragem datele despre melodie
        Song? song;
        bool isPlaying = false;

        if (state is PlayerPlaying) {
          song = state.currentSong;
          isPlaying = true;
        } else if (state is PlayerPaused) {
          song = state.currentSong;
          isPlaying = false;
        }

        if (song == null) return const SizedBox.shrink();

        // 3. UI-ul cu GestureDetector
        return GestureDetector(
          onTap: () {
            // Când apeși pe bară, deschidem PlayerPage
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const PlayerPage()),
            );
          },
          child: Container(
            height: 70, // Înălțimea barei
            decoration: BoxDecoration(
              color: Colors.grey[900], // Fundal închis (Spotify Grey)
              border: const Border(
                top: BorderSide(
                  color: Colors.white10,
                  width: 1,
                ), // Linie fină sus
              ),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: [
                // --- STÂNGA: Copertă + Text ---

                // Coperta
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: Image.network(
                    song.imageUrl,
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      color: Colors.grey[800],
                      width: 50,
                      height: 50,
                      child: const Icon(Icons.music_note, color: Colors.white),
                    ),
                  ),
                ),
                const SizedBox(width: 12),

                // Titlu și Artist
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        song.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        song.artist,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(color: Colors.grey[400], fontSize: 12),
                      ),
                    ],
                  ),
                ),

                // --- DREAPTA: Butoanele ---
                IconButton(
                  icon: const Icon(Icons.add, color: Colors.white),
                  onPressed: () {
                    // Deschidem meniul, dar trebuie să fim atenți la Context
                    showModalBottomSheet(
                      context: context,
                      // Folosim song-ul curent din variabila definită mai sus în build
                      builder: (_) => AddToPlaylistSheet(song: song!),
                    );
                  },
                ),
                // Buton Previous (Placeholder)
                IconButton(
                  icon: const Icon(Icons.skip_previous, color: Colors.white),
                  onPressed: () {
                    context.read<PlayerBloc>().add(SkipPreviousEvent());
                  },
                ),

                // Buton PLAY / PAUSE
                IconButton(
                  icon: Icon(
                    isPlaying ? Icons.pause : Icons.play_arrow,
                    color: Colors.white,
                    size: 32,
                  ),
                  onPressed: () {
                    // MODIFICARE: Nu mai folosim if/else aici.
                    // Trimitem doar comanda "Toggle", iar BLoC-ul știe ce are de făcut.
                    context.read<PlayerBloc>().add(TogglePlayPauseEvent());
                  },
                ),

                // Buton Next (Placeholder)
                IconButton(
                  icon: const Icon(Icons.skip_next, color: Colors.white),
                  onPressed: () {
                    context.read<PlayerBloc>().add(SkipNextEvent());
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
