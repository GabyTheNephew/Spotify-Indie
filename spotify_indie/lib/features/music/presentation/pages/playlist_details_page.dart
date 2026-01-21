import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/playlist.dart';
import '../bloc/player/player_bloc.dart';
import '../bloc/player/player_event.dart';
import '../widgets/mini_player.dart'; // 1. IMPORTĂ MINI PLAYER

class PlaylistDetailsPage extends StatelessWidget {
  final Playlist playlist;

  const PlaylistDetailsPage({super.key, required this.playlist});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(playlist.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () {},
          ),
        ],
      ),
      // 2. MODIFICĂM BODY-UL SĂ FIE O COLOANĂ MARE
      body: Column(
        children: [
          // PARTEA DE SUS: Conținutul paginii (Header + Listă)
          // Folosim Expanded ca să ocupe tot spațiul rămas deasupra player-ului
          Expanded(
            child: Column(
              children: [
                // HEADER: Informații despre Playlist
                Container(
                  padding: const EdgeInsets.all(24),
                  width: double.infinity,
                  color: Colors.grey[900],
                  child: Column(
                    children: [
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          color: playlist.isDefault
                              ? Colors.green.withOpacity(0.2)
                              : Colors.grey[800],
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          playlist.isDefault ? Icons.favorite : Icons.music_note,
                          size: 50,
                          color: playlist.isDefault ? Colors.green : Colors.white,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        playlist.name,
                        style: const TextStyle(
                            fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        "${playlist.songs.length} songs",
                        style: TextStyle(color: Colors.grey[400]),
                      ),
                    ],
                  ),
                ),

                // LISTA DE MELODII
                Expanded(
                  child: playlist.songs.isEmpty
                      ? const Center(
                          child: Text(
                            "Playlist gol.\nAdaugă melodii din Search!",
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.grey),
                          ),
                        )
                      : ListView.builder(
                          itemCount: playlist.songs.length,
                          itemBuilder: (context, index) {
                            final song = playlist.songs[index];
                            return ListTile(
                              leading: ClipRRect(
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
                                    child: const Icon(Icons.music_note),
                                  ),
                                ),
                              ),
                              title: Text(song.title,
                                  maxLines: 1, overflow: TextOverflow.ellipsis),
                              subtitle: Text(song.artist),
                              trailing: IconButton(
                                icon: const Icon(Icons.play_circle_fill,
                                    color: Colors.green),
                                onPressed: () {
                                  context
                                      .read<PlayerBloc>()
                                      .add(PlaySongEvent(song));
                                },
                              ),
                              onTap: () {
                                context
                                    .read<PlayerBloc>()
                                    .add(PlaySongEvent(song));
                              },
                            );
                          },
                        ),
                ),
              ],
            ),
          ),

          // 3. JOS: MINI PLAYER-UL
          // Îl adăugăm fix aici. Deoarece conține deja logica de navigare
          // (GestureDetector -> PlayerPage), va funcționa la fel ca în ecranul principal.
          const MiniPlayer(),
        ],
      ),
    );
  }
}