// lib/features/music/data/models/song_model.dart

import '../../domain/entities/song.dart'; // Importăm părintele

// 1. Adăugăm "extends Song"
class SongModel extends Song {
  final String id;
  final String name;
  final String artistName;
  final String image;
  final String audioUrl;

  SongModel({
    required this.id,
    required this.name,
    required this.artistName,
    required this.image,
    required this.audioUrl,
  }) : super( // 2. Trimitem datele la clasa părinte (Song)
          id: id,
          title: name,        // Mapăm 'name' (din JSON) la 'title' (din Domain)
          artist: artistName, // Mapăm 'artistName' la 'artist'
          imageUrl: image,
          audioUrl: audioUrl,
        );

  factory SongModel.fromJson(Map<String, dynamic> json) {
    return SongModel(
      id: json['id'] ?? '',
      name: json['name'] ?? 'Unknown Track',
      artistName: json['artist_name'] ?? 'Unknown Artist',
      image: json['image'] ?? 'https://via.placeholder.com/150',
      audioUrl: json['audio'] ?? '',
    );
  }
}