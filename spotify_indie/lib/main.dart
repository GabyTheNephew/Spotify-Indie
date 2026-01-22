import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spotify_indie/features/music/data/repositories/playlist_repository.dart';
import 'package:spotify_indie/features/music/presentation/bloc/playlist/playlist_bloc.dart';
import 'package:spotify_indie/features/music/presentation/bloc/playlist/playlist_event.dart';
import 'core/service_locator.dart';
import 'features/music/data/repositories/music_repository.dart';
import 'features/music/presentation/bloc/music_bloc.dart';
import 'features/music/presentation/pages/home_page.dart';
import 'core/services/audio_player_service.dart';
import 'features/music/presentation/bloc/player/player_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'features/music/presentation/pages/main_screen.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();

  // 2. Deschidem cutia (baza de date) pentru playlist-uri
  await Hive.openBox('playlistsBox');

  try {
    await dotenv.load(fileName: ".env");
  } catch (e) {
    print("Nu s-a putut încărca fișierul .env: $e");
  }
  await JustAudioBackground.init(
    androidNotificationChannelId: 'com.ryanheise.bg_demo.channel.audio1',
    androidNotificationChannelName: 'Audio playback',
    androidNotificationOngoing: true,
    androidNotificationIcon: 'mipmap/ic_launcher',
  );

  if (await Permission.notification.isDenied) {
    await Permission.notification.request();
  }

  setupServiceLocator(); // Inițializăm DI
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Schimbăm BlocProvider simplu în MultiBlocProvider
    return MultiBlocProvider(
      providers: [
        // 1. BLoC-ul pentru Căutare (existent)
        BlocProvider<MusicBloc>(
          create: (context) => MusicBloc(repository: sl<MusicRepository>()),
        ),

        // 2. BLoC-ul pentru Player (NOU)
        BlocProvider<PlayerBloc>(
          create: (context) =>
              PlayerBloc(audioService: sl<AudioPlayerService>()),
        ),
        BlocProvider<PlaylistBloc>(
          create: (context) =>
              PlaylistBloc(repository: sl<PlaylistRepository>())
                ..add(LoadPlaylistsEvent()),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Spotify Clone',
        theme: ThemeData.dark(),
        home: const MainScreen(),
      ),
    );
  }
}
