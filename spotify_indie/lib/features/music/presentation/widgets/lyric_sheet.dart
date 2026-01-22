import 'package:flutter/material.dart';
import 'package:spotify_indie/core/service_locator.dart';
import 'package:spotify_indie/core/services/audio_player_service.dart';
import 'package:spotify_indie/core/services/lyric_service.dart';
import '../../domain/entities/lyric.dart';
import '../../domain/entities/song.dart';

class LyricsSheet extends StatefulWidget {
  final Song song;
  const LyricsSheet({super.key, required this.song});

  @override
  State<LyricsSheet> createState() => _LyricsSheetState();
}

class _LyricsSheetState extends State<LyricsSheet> {
  // Serviciul nostru modificat
  final LyricsService _lyricsService = LyricsService();
  final AudioPlayerService _audioService = sl<AudioPlayerService>();

  List<Lyric> _lyrics = [];
  bool _isLoading = true;
  String _error = '';

  @override
  void initState() {
    super.initState();
    _fetchLyrics();
  }

  Future<void> _fetchLyrics() async {
    // Verificăm dacă avem URL valid
    if (widget.song.audioUrl.isEmpty) {
      if (mounted)
        setState(() {
          _error = "URL melodie invalid";
          _isLoading = false;
        });
      return;
    }

    try {
      // 1. Apelăm direct serviciul cu URL-ul melodiei
      // Nu mai descărcăm nimic local!
      final results = await _lyricsService.generateLyrics(widget.song.audioUrl);

      if (mounted) {
        setState(() {
          _lyrics = results;
          _isLoading = false;
        });
      }
    } catch (e) {
      print("Eroare în UI LyricsSheet: $e");
      if (mounted) {
        setState(() {
          _error = 'Eroare neașteptată.';
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 16),
          Container(width: 40, height: 4, color: Colors.grey[600]),
          const SizedBox(height: 20),
          Text(
            "AI Lyrics (Powered by Deepgram)",
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),

          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: Colors.green),
                  )
                : _error.isNotEmpty
                ? Center(
                    child: Text(
                      _error,
                      style: const TextStyle(color: Colors.redAccent),
                    ),
                  )
                : _lyrics.isEmpty
                ? const Center(
                    child: Text(
                      "Nu există versuri.",
                      style: TextStyle(color: Colors.white),
                    ),
                  )
                : StreamBuilder<Duration>(
                    stream: _audioService.positionStream,
                    builder: (context, snapshot) {
                      final currentPos = snapshot.data ?? Duration.zero;

                      return ListView.builder(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 20,
                        ),
                        itemCount: _lyrics.length,
                        itemBuilder: (context, index) {
                          final lyric = _lyrics[index];
                          final bool isActive =
                              currentPos >= lyric.startTime &&
                              currentPos < lyric.endTime;

                          return Padding(
                            padding: const EdgeInsets.only(bottom: 16.0),
                            child: AnimatedDefaultTextStyle(
                              duration: const Duration(milliseconds: 200),
                              style: TextStyle(
                                fontSize: isActive ? 24 : 18,
                                color: isActive
                                    ? Colors.white
                                    : Colors.grey[600],
                                fontWeight: isActive
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                              ),
                              child: Text(
                                lyric.text,
                                textAlign: TextAlign.center,
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
