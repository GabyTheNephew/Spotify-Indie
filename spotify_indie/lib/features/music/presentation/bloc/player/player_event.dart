import 'package:equatable/equatable.dart';
import '../../../domain/entities/song.dart';

abstract class PlayerEvent extends Equatable {
  @override
  List<Object> get props => [];
}

class PlaySongEvent extends PlayerEvent {
  final Song song;
  PlaySongEvent(this.song); // Utilizatorul a apăsat pe o melodie nouă
}

class PauseSongEvent extends PlayerEvent {} // A apăsat pauză

class ResumeSongEvent extends PlayerEvent {} // A apăsat play la loc

class TogglePlayPauseEvent extends PlayerEvent {}

class PlayerStateChanged extends PlayerEvent {
  final bool isPlaying;
  PlayerStateChanged(this.isPlaying);
}

// Adaugă o melodie în coadă
class AddToQueueEvent extends PlayerEvent {
  final Song song;
  AddToQueueEvent(this.song);
}

// Navigare Next/Prev
class SkipNextEvent extends PlayerEvent {}

class SkipPreviousEvent extends PlayerEvent {}

class UpdateCurrentSongInternalEvent extends PlayerEvent {
  final Song? song;
  UpdateCurrentSongInternalEvent(this.song);
}
