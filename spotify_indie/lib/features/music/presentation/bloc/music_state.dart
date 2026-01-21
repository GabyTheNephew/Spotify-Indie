import 'package:equatable/equatable.dart';
import '../../domain/entities/song.dart';

abstract class MusicState extends Equatable {
  @override
  List<Object> get props => [];
}

class MusicInitial extends MusicState {} // Starea de start (ecran gol)

class MusicLoading extends MusicState {} // Se învârte rotița

class MusicLoaded extends MusicState {   // Avem datele!
  final List<Song> songs;
  MusicLoaded(this.songs);

  @override
  List<Object> get props => [songs];
}

class MusicFailure extends MusicState {  // A apărut o eroare
  final String error;
  MusicFailure(this.error);

  @override
  List<Object> get props => [error];
}