// lib/features/music/domain/entities/song.dart

class Song {
  final String id;
  final String title;    // În UI îi zicem "Title"
  final String artist;   // În UI îi zicem "Artist"
  final String imageUrl; // În UI îi zicem "ImageUrl"
  final String audioUrl;

  Song({
    required this.id,
    required this.title,
    required this.artist,
    required this.imageUrl,
    required this.audioUrl,
  });
}