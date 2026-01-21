import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/playlist/playlist_bloc.dart';
import '../bloc/playlist/playlist_event.dart';
import '../bloc/playlist/playlist_state.dart';
import 'playlist_details_page.dart';

class PlaylistsPage extends StatelessWidget {
  const PlaylistsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Library')),
      body: BlocBuilder<PlaylistBloc, PlaylistState>(
        builder: (context, state) {
          if (state is PlaylistLoaded) {
            // Dacă nu avem playlist-uri (în afară de Liked Songs)
            if (state.playlists.isEmpty) {
              return const Center(child: Text("No playlists yet."));
            }

            return ListView.builder(
              itemCount: state.playlists.length,
              itemBuilder: (context, index) {
                final playlist = state.playlists[index];
                return ListTile(
                  leading: Container(
                    width: 50,
                    height: 50,
                    color: playlist.isDefault ? Colors.green : Colors.grey[800],
                    child: Icon(
                      playlist.isDefault ? Icons.favorite : Icons.music_note,
                      color: Colors.white,
                    ),
                  ),
                  title: Text(playlist.name),
                  subtitle: Text('${playlist.songs.length} songs'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    // Navigăm către pagina de detalii
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            PlaylistDetailsPage(playlist: playlist),
                      ),
                    );
                  },
                );
              },
            );
          }
          return const Center(child: CircularProgressIndicator());
        },
      ),
      // Buton plutitor să creezi playlist direct de aici
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.green,
        child: const Icon(Icons.add),
        onPressed: () {
          // Putem refolosi logica de creare, dar simplificăm momentan
          context.read<PlaylistBloc>().add(
            CreatePlaylistEvent("New Playlist ${DateTime.now().second}"),
          );
        },
      ),
    );
  }
}
