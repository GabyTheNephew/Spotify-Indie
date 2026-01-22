class Lyric {
  final String text;
  final Duration startTime;
  final Duration endTime;

  Lyric({
    required this.text,
    required this.startTime,
    required this.endTime,
  });

  factory Lyric.fromJson(Map<String, dynamic> json) {
    final timestamp = json['timestamp'];
    double startSeconds = 0.0;
    double endSeconds = 0.0;

    if (timestamp is List && timestamp.length >= 2) {
      startSeconds = (timestamp[0] as num).toDouble();
      endSeconds = (timestamp[1] as num?)?.toDouble() ?? (startSeconds + 3.0);
    }

    return Lyric(
      text: json['text'] ?? '',
      startTime: Duration(milliseconds: (startSeconds * 1000).toInt()),
      endTime: Duration(milliseconds: (endSeconds * 1000).toInt()),
    );
  }
}