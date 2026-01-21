import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/music_bloc.dart';
import '../bloc/music_event.dart';
import '../bloc/music_state.dart';
import '../bloc/player/player_bloc.dart';
import '../bloc/player/player_event.dart';
import '../widgets/mini_player.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Spotify Clone Indie')),
      body: Column(
        children: [
          // 1. Bara de Căutare (Rămâne la fel)
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              decoration: const InputDecoration(
                hintText: 'Caută o melodie (ex: Rock)',
                border: OutlineInputBorder(),
                suffixIcon: Icon(Icons.search),
              ),
              onSubmitted: (value) {
                context.read<MusicBloc>().add(SearchMusicEvent(value));
              },
            ),
          ),

          // 2. Lista de Melodii (Expanded ca să ocupe tot spațiul rămas)
          Expanded(
            child: BlocBuilder<MusicBloc, MusicState>(
              builder: (context, state) {
                if (state is MusicLoading) {
                  return const Center(child: CircularProgressIndicator());
                } else if (state is MusicLoaded) {
                  return ListView.builder(
                    itemCount: state.songs.length,
                    itemBuilder: (context, index) {
                      final song = state.songs[index];
                      return Dismissible(
                        key: Key(
                          song.id + DateTime.now().toString(),
                        ), // Cheie unică
                        direction: DismissDirection
                            .startToEnd, // Doar stânga -> dreapta (ca pe Spotify)
                        background: Container(
                          color: Colors.green, // Culoarea de fundal la swipe
                          alignment: Alignment.centerLeft,
                          padding: const EdgeInsets.only(left: 20),
                          child: const Icon(
                            Icons.queue_music,
                            color: Colors.white,
                            size: 30,
                          ),
                        ),
                        onDismissed: (direction) {
                          // 1. Adăugăm în Queue
                          context.read<PlayerBloc>().add(AddToQueueEvent(song));

                          // 2. Afișăm confirmarea
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text("${song.title} added to queue"),
                              duration: const Duration(seconds: 1),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );

                          // NOTĂ: Dismissible șterge vizual elementul, dar noi nu vrem să-l ștergem din listă.
                          // De aceea, în mod normal am reîncărca lista, dar un truc e să folosim confirmDismiss:
                        },
                        confirmDismiss: (direction) async {
                          // Executăm logica, dar returnăm false ca să NU dispară elementul din listă
                          context.read<PlayerBloc>().add(AddToQueueEvent(song));
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text("${song.title} added to queue"),
                              duration: const Duration(seconds: 1),
                            ),
                          );
                          return false; // Elementul revine la loc (doar animația se execută)
                        },

                        child: ListTile(
                          // ... conținutul tău vechi (leading, title, subtitle, onTap) ...
                          leading: Image.network(
                            song.imageUrl,
                            width: 50,
                            errorBuilder: (_, __, ___) =>
                                const Icon(Icons.music_note),
                          ),
                          title: Text(song.title, maxLines: 1),
                          subtitle: Text(song.artist),
                          trailing: const Icon(Icons.play_arrow, size: 20),
                          onTap: () {
                            // Aici pornește muzica
                            context.read<PlayerBloc>().add(PlaySongEvent(song));
                          },
                        ),
                      );
                    },
                  );
                } else if (state is MusicFailure) {
                  return Center(child: Text('Eroare: ${state.error}'));
                }
                return const Center(child: Text('Caută ceva pentru a începe!'));
              },
            ),
          ),

          // 3. AICI VINE MINI PLAYER-UL 👇
          // El stă jos. Dacă nu cântă nimic, are înălțime 0.
          // const MiniPlayer(),
        ],
      ),
    );
  }
}
