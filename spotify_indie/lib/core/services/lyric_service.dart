import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../../features/music/domain/entities/lyric.dart';

class LyricsService {
  final Dio _dio = Dio();

  // URL SCHIMBAT:
  // 1. language=en -> Forțăm engleza (mult mai stabil pentru muzică decât detectarea automată)
  // 2. punctuate=true -> Avem nevoie de punctuație ca să putem sparge textul brut în propoziții
  // 3. utterances=true -> Cerem sincronizare, dar avem backup dacă eșuează
  // 4. model=nova-2 -> Cel mai bun model general
  final String _apiUrl =
      'https://api.deepgram.com/v1/listen?model=nova-2&smart_format=true&utterances=true&language=en&punctuate=true';

  Future<List<Lyric>> generateLyrics(String audioUrl) async {
    final apiKey = dotenv.env['DEEPGRAM_API_KEY'] ?? '';
    if (apiKey.isEmpty) return _getFallbackLyrics("Cheia API lipsește.");

    try {
      print("[LyricsService] 1. Descărcăm (User-Agent activ)...");

      // PASUL 1: Download Audio
      final downloadResponse = await _dio.get(
        audioUrl,
        options: Options(
          responseType: ResponseType.bytes,
          headers: {
            // Header critic pentru Jamendo
            'User-Agent':
                'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36',
            'Accept': '*/*',
          },
          receiveTimeout: const Duration(minutes: 2),
        ),
      );

      final Uint8List fileBytes = downloadResponse.data;

      // PASUL 2: Trimitem la Deepgram
      print(
        "[LyricsService] 2. Trimitem la Deepgram (${fileBytes.lengthInBytes} bytes)...",
      );

      final response = await _dio.post(
        _apiUrl,
        options: Options(
          headers: {
            'Authorization': 'Token $apiKey',
            'Content-Type': 'audio/mpeg',
          },
          validateStatus: (status) => status! < 500,
          sendTimeout: const Duration(minutes: 2),
          receiveTimeout: const Duration(minutes: 2),
        ),
        data: fileBytes,
      );

      if (response.statusCode == 200) {
        final data = response.data;

        if (data['results'] != null) {
          // --- METODA A: Versuri Sincronizate (Ideal) ---
          if (data['results']['utterances'] != null) {
            final List<dynamic> utterances = data['results']['utterances'];

            // Folosim această metodă DOAR dacă avem un număr decent de versuri detectate (> 2)
            if (utterances.length > 2) {
              print(
                "[LyricsService] Succes: S-au găsit ${utterances.length} versuri sincronizate.",
              );
              return utterances.map((u) {
                return Lyric(
                  text: u['transcript'] ?? '',
                  startTime: Duration(
                    milliseconds: ((u['start'] as num) * 1000).toInt(),
                  ),
                  endTime: Duration(
                    milliseconds: ((u['end'] as num) * 1000).toInt(),
                  ),
                );
              }).toList();
            }
          }

          // --- METODA B: Backup Text Brut (Dacă sincronizarea eșuează) ---
          // Dacă muzica e prea tare, AI-ul pierde timpii, dar înțelege cuvintele.
          // Luăm textul brut și îl "feliem" noi.
          if (data['results']['channels'] != null &&
              data['results']['channels'][0]['alternatives'] != null) {
            final alt = data['results']['channels'][0]['alternatives'][0];
            final String transcript = alt['transcript'] ?? '';

            if (transcript.isNotEmpty) {
              print(
                "[LyricsService] Fallback: Folosim textul brut (nesincronizat).",
              );
              return _splitTranscriptToLyrics(transcript);
            }
          }
        }
      }

      print("[LyricsService] Răspuns gol de la API.");
      return [];
    } catch (e) {
      print("[LyricsService] EXCEPȚIE: $e");
      return [];
    }
  }

  // Funcție care sparge un text lung în "versuri" de câte 4 secunde
  // Astfel utilizatorul vede ceva mișcându-se pe ecran
  List<Lyric> _splitTranscriptToLyrics(String fullText) {
    // Împărțim după punctuație (. ? !)
    RegExp sentenceSplitter = RegExp(r'(?<=[.?!])\s+');
    List<String> sentences = fullText.split(sentenceSplitter);

    // Dacă nu are punctuație, împărțim la fiecare 7 cuvinte
    if (sentences.length < 2) {
      sentences = [];
      List<String> words = fullText.split(' ');
      String buffer = "";
      for (int i = 0; i < words.length; i++) {
        buffer += "${words[i]} ";
        if ((i + 1) % 7 == 0) {
          sentences.add(buffer);
          buffer = "";
        }
      }
      if (buffer.isNotEmpty) sentences.add(buffer);
    }

    List<Lyric> result = [];
    int currentTimeMs = 0;
    const int durationPerLineMs = 4000; // 4 secunde per rând

    for (var sentence in sentences) {
      if (sentence.trim().isEmpty) continue;

      result.add(
        Lyric(
          text: sentence.trim(),
          startTime: Duration(milliseconds: currentTimeMs),
          endTime: Duration(milliseconds: currentTimeMs + durationPerLineMs),
        ),
      );

      currentTimeMs += durationPerLineMs;
    }

    return result;
  }

  List<Lyric> _getFallbackLyrics(String reason) {
    return [
      Lyric(
        text: reason,
        startTime: Duration.zero,
        endTime: const Duration(seconds: 5),
      ),
    ];
  }
}
