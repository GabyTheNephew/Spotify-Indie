import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/song.dart';
import '../bloc/playlist/playlist_bloc.dart';
import '../bloc/playlist/playlist_event.dart';
import '../bloc/playlist/playlist_state.dart';

class AddToPlaylistSheet extends StatelessWidget {
  final Song song;

  const AddToPlaylistSheet({super.key, required this.song});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 400, // Înălțimea meniului
      color: Colors.grey[900],
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Header
          const Text(
            "Add to Playlist",
            style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          // Buton "Create New Playlist"
          ListTile(
            leading: Container(
              width: 50, height: 50,
              color: Colors.grey[800],
              child: const Icon(Icons.add, color: Colors.white),
            ),
            title: const Text("New Playlist", style: TextStyle(color: Colors.white)),
            onTap: () {
              // Dialog simplu pentru nume
              _showCreateDialog(context);
            },
          ),
          const Divider(color: Colors.grey),

          // Lista de Playlist-uri existente
          Expanded(
            child: BlocBuilder<PlaylistBloc, PlaylistState>(
              builder: (context, state) {
                if (state is PlaylistLoaded) {
                  return ListView.builder(
                    itemCount: state.playlists.length,
                    itemBuilder: (context, index) {
                      final playlist = state.playlists[index];
                      
                      // Verificăm dacă melodia e deja în acest playlist
                      final isSelected = playlist.songs.any((s) => s.id == song.id);

                      return CheckboxListTile(
                        activeColor: Colors.green,
                        checkColor: Colors.black,
                        title: Text(playlist.name, style: const TextStyle(color: Colors.white)),
                        secondary: playlist.isDefault 
                            ? const Icon(Icons.favorite, color: Colors.green) // Inima pt Liked Songs
                            : const Icon(Icons.music_note, color: Colors.white),
                        value: isSelected,
                        onChanged: (bool? value) {
                          // Trimitem evenimentul de Toggle
                          context.read<PlaylistBloc>().add(
                            ToggleSongInPlaylistEvent(playlist.id, song),
                          );
                        },
                      );
                    },
                  );
                }
                return const Center(child: CircularProgressIndicator());
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showCreateDialog(BuildContext context) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text("Playlist Name", style: TextStyle(color: Colors.white)),
        content: TextField(
          controller: controller,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(hintText: "My Cool Playlist", hintStyle: TextStyle(color: Colors.grey)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                context.read<PlaylistBloc>().add(CreatePlaylistEvent(controller.text));
                Navigator.pop(ctx);
              }
            },
            child: const Text("Create", style: TextStyle(color: Colors.green)),
          ),
        ],
      ),
    );
  }
}