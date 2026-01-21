import 'song.dart';

class Playlist {
  final String id;
  final String name;
  final List<Song> songs;
  final bool isDefault; // Va fi true doar pentru "Liked Songs"

  Playlist({
    required this.id,
    required this.name,
    required this.songs,
    this.isDefault = false,
  });
}