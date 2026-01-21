import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart'; // Dacă nu ai pachetul, poți folosi un String random simplu
import '../../domain/entities/playlist.dart';
import '../../domain/entities/song.dart';
import '../models/song_model.dart'; // Importăm modelul pentru conversii

class PlaylistRepository {
  final Box _box = Hive.box('playlistsBox');

  // Încărcăm playlist-urile. Dacă e gol, creăm "Liked Songs"
  List<Playlist> getPlaylists() {
    if (_box.isEmpty) {
      _createDefaultPlaylist();
    }

    // Convertim datele brute din Hive în obiecte Playlist
    return _box.values.map((dynamic item) {
      final map = jsonDecode(jsonEncode(item)); // Trick rapid pentru conversie
      return Playlist(
        id: map['id'],
        name: map['name'],
        isDefault: map['isDefault'] ?? false,
        songs: (map['songs'] as List).map((s) => SongModel.fromJson(s)).toList(),
      );
    }).toList();
  }

  void _createDefaultPlaylist() {
    final likedSongs = {
      'id': 'liked_songs',
      'name': 'Liked Songs',
      'songs': [],
      'isDefault': true,
    };
    _box.put('liked_songs', likedSongs);
  }

  Future<void> createPlaylist(String name) async {
    final id = DateTime.now().millisecondsSinceEpoch.toString();
    final newPlaylist = {
      'id': id,
      'name': name,
      'songs': [],
      'isDefault': false,
    };
    await _box.put(id, newPlaylist);
  }

  // Adaugă sau Scoate o melodie dintr-un playlist
  Future<void> toggleSongInPlaylist(String playlistId, Song song) async {
    final playlistMap = Map<String, dynamic>.from(_box.get(playlistId));
    final List<dynamic> currentSongs = List.from(playlistMap['songs']);

    // Verificăm dacă melodia există deja (căutăm după ID)
    final existingIndex = currentSongs.indexWhere((s) => s['id'] == song.id);

    if (existingIndex >= 0) {
      // Există -> O ștergem (Debifare)
      currentSongs.removeAt(existingIndex);
    } else {
      // Nu există -> O adăugăm (Bifare)
      // Trebuie să salvăm melodia ca Map (JSON), nu ca obiect
      currentSongs.add({
        'id': song.id,
        'name': song.title,
        'artist_name': song.artist,
        'image': song.imageUrl,
        'audio': song.audioUrl,
      });
    }

    playlistMap['songs'] = currentSongs;
    await _box.put(playlistId, playlistMap);
  }
}