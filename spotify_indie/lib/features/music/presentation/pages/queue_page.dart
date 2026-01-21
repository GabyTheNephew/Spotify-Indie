import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import '../../../../core/service_locator.dart';
import '../../../../core/services/audio_player_service.dart';
import '../../domain/entities/song.dart';

class QueuePage extends StatelessWidget {
  const QueuePage({super.key});

  @override
  Widget build(BuildContext context) {
    final audioService = sl<AudioPlayerService>();

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text("Queue"),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.keyboard_arrow_down, size: 30),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: StreamBuilder<SequenceState?>(
        stream: audioService.sequenceStateStream,
        builder: (context, snapshot) {
          final state = snapshot.data;
          final sequence = state?.sequence ?? [];
          final currentIndex = state?.currentIndex ?? 0;

          if (sequence.isEmpty) {
            return const Center(
              child: Text(
                "Queue is empty",
                style: TextStyle(color: Colors.grey),
              ),
            );
          }

          return ReorderableListView.builder(
            onReorder: (oldIndex, newIndex) {
              // Flutter ReorderableListView are un quirk: dacă muți de sus în jos, newIndex e decalat cu 1
              if (oldIndex < newIndex) newIndex -= 1;
              audioService.moveQueueItem(oldIndex, newIndex);
            },
            itemCount: sequence.length,
            itemBuilder: (context, index) {
              final audioSource = sequence[index];
              final metadata = audioSource.tag as MediaItem; // Luăm metadatele
              final isCurrent = index == currentIndex;

              return Dismissible(
                key: ValueKey(metadata.id + index.toString()), // Cheie unică
                direction:
                    DismissDirection.endToStart, // Swipe stânga pt ștergere
                background: Container(
                  color: Colors.red,
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 20),
                  child: const Icon(Icons.delete, color: Colors.white),
                ),
                onDismissed: (_) {
                  audioService.removeQueueItemAt(index);
                },
                child: Container(
                  color: isCurrent ? Colors.grey[900] : Colors.transparent,
                  child: ListTile(
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: Image.network(
                        metadata.artUri.toString(),
                        width: 50,
                        height: 50,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) =>
                            const Icon(Icons.music_note, color: Colors.white),
                      ),
                    ),
                    title: Text(
                      metadata.title,
                      style: TextStyle(
                        color: isCurrent ? Colors.green : Colors.white,
                        fontWeight: isCurrent
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                    subtitle: Text(
                      metadata.artist ?? '',
                      style: const TextStyle(color: Colors.grey),
                    ),
                    onTap: () {
                      // Apelăm funcția nouă din service
                      // Putem face asta direct (fiind o acțiune simplă de seek) sau printr-un Event în BLoC.
                      // Direct e mai rapid pentru seek:
                      audioService.jumpToQueueItem(index);

                      // Opțional: Închidem pagina de Queue
                      // Navigator.pop(context);
                    },
                    trailing: ReorderableDragStartListener(
                      index: index,
                      child: const Icon(Icons.drag_handle, color: Colors.grey),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
