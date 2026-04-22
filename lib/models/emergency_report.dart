class EmergencyReport {
  String disasterType;
  String severity;
  String textReport;
  List<String> mediaPaths; // image/video file paths
  String? voiceMemoPath;
  String? location;
  DateTime? timestamp;

  EmergencyReport({
    this.disasterType = 'Other',
    this.severity = 'Medium',
    this.textReport = '',
    List<String>? mediaPaths,
    this.voiceMemoPath,
    this.location,
    this.timestamp,
  }) : mediaPaths = mediaPaths ?? [];

  bool get hasText => textReport.trim().isNotEmpty;
  bool get hasMedia => mediaPaths.isNotEmpty;
  bool get hasVoice => voiceMemoPath != null && voiceMemoPath!.isNotEmpty;
  bool get hasLocation => location != null && location!.isNotEmpty;

  int get attachmentCount {
    int c = 0;
    if (hasText) c++;
    if (hasMedia) c += mediaPaths.length;
    if (hasVoice) c++;
    return c;
  }
}
