import 'package:equatable/equatable.dart';

abstract class MusicEvent extends Equatable {
  @override
  List<Object> get props => [];
}

// Evenimentul: "Utilizatorul vrea să caute o melodie"
class SearchMusicEvent extends MusicEvent {
  final String query;

  SearchMusicEvent(this.query);

  @override
  List<Object> get props => [query];
}