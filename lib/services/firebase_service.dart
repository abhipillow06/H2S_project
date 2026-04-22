import 'package:cloud_firestore/cloud_firestore.dart';

class LogEntry {
  final String id;
  final String type;
  final String time;
  final String location;
  final DateTime timestamp;

  LogEntry({
    required this.id,
    required this.type,
    required this.time,
    required this.location,
    required this.timestamp,
  });

  factory LogEntry.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>?;
    return LogEntry(
      id: doc.id,
      type: data?['type'] ?? 'Unknown',
      time: data?['time'] ?? '--:--',
      location: data?['location'] ?? '',
      timestamp: data?['timestamp'] != null 
          ? (data!['timestamp'] as Timestamp).toDate() 
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'type': type,
      'time': time,
      'location': location,
      'timestamp': FieldValue.serverTimestamp(),
    };
  }
}

class FirebaseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Get a stream of log entries ordered by most recent first
  Stream<List<LogEntry>> get logStream {
    return _db
        .collection('qr_logs')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => LogEntry.fromFirestore(doc)).toList());
  }

  /// Adds a new QR check-in/out log to Firestore
  Future<void> recordCheckInOut(String type, String time, String location) async {
    try {
      await _db.collection('qr_logs').add({
        'type': type,
        'time': time,
        'location': location,
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error recording check in/out: $e');
    }
  }
}
