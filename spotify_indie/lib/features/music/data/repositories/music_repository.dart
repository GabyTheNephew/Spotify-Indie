import 'package:dio/dio.dart';
import '../models/song_model.dart';

class MusicRepository {
  late final Dio _dio;

  MusicRepository() {
    // 1. Configurăm Dio cu opțiuni de bază și TIMEOUT
    _dio = Dio(
      BaseOptions(
        baseUrl: 'https://api.jamendo.com/v3.0',
        // Dacă serverul nu răspunde în 10 secunde, dăm eroare (nu așteptăm la infinit)
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
        // Parametrii care se trimit la FIECARE cerere (Client ID)
        queryParameters: {
          'client_id': 'db250ef7',
          'format': 'json',
          'include': 'musicinfo',
        },
      ),
    );

    // 2. AICI E SECRETUL: Adăugăm Interceptorul care scrie tot în consolă
    _dio.interceptors.add(
      LogInterceptor(
        request: true, // Arată cererea
        requestHeader: true, // Arată header-ele
        requestBody: true, // Arată ce trimitem
        responseHeader: true, // Arată ce primim
        responseBody: true, // Arată JSON-ul primit
        error: true, // Arată erorile detaliate
      ),
    );
  }

  Future<List<SongModel>> searchSongs(String query) async {
    try {
      // 3. Facem cererea (acum e mult mai simplu, nu mai repetăm URL-ul)
      final response = await _dio.get(
        '/tracks/',
        queryParameters: {
          'limit': 20,
          'search': query, // Adăugăm doar ce e specific acestei căutări
        },
      );

      if (response.statusCode == 200) {
        final data = response.data['results'] as List;
        return data.map((json) => SongModel.fromJson(json)).toList();
      } else {
        throw Exception('Server error: ${response.statusCode}');
      }
    } on DioException catch (e) {
      // 4. Prindem erorile specifice de rețea
      if (e.type == DioExceptionType.connectionTimeout) {
        throw Exception("Timeout: Serverul nu a răspuns în 10 secunde.");
      } else if (e.type == DioExceptionType.connectionError) {
        throw Exception("Eroare Conexiune: Verifică dacă ai internet.");
      }
      throw Exception('Eroare Dio: ${e.message}');
    } catch (e) {
      throw Exception('Eroare generală: $e');
    }
  }
}
